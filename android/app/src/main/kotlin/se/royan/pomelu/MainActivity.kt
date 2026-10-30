package se.royan.pomelu

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.content.IntentCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import java.util.concurrent.Executors

/**
 * Hands Dart the shares of ACTION_SEND / ACTION_SEND_MULTIPLE as a list of
 * `{type, text?, path?, mime?, name?}` maps, a first `{type: target,
 * profile}` when the share went to a bot of the top row, plus a last
 * `{type: skipped, count}` for files left out ([SharedFiles] copies, caps and refuses them,
 * off the main thread). A share or a link is handled once: an intent Android replays
 * (from Recents after a process death, or from saved state) is stripped
 * before Flutter or a plugin reads it. State is touched on the main thread.
 */
class MainActivity : FlutterActivity() {
    private var sink: EventChannel.EventSink? = null

    /** Dart's `initial` call, parked while the first share still copies. */
    private var initialWaiter: MethodChannel.Result? = null

    /** This app's own providers: a share may not open a stream through one. */
    private val ownAuthorities: Set<String> by lazy {
        val info = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(PackageManager.GET_PROVIDERS.toLong()),
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, PackageManager.GET_PROVIDERS)
            }
        } catch (e: PackageManager.NameNotFoundException) {
            Log.w(TAG, "own providers unreadable", e)
            null
        }
        info?.providers.orEmpty()
            .flatMap { it.authority?.split(';').orEmpty() }
            .filter { it.isNotBlank() }
            .toSet()
    }

    /** This app's private folders, which no shared path may name. */
    private val privateDirs: List<String> by lazy {
        listOfNotNull(
            applicationInfo.dataDir,
            filesDir.parentFile?.absolutePath,
            applicationInfo.deviceProtectedDataDir,
        ).distinct()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Before super: the engine and the plugins read the intent there.
        if (isReplay(intent, savedInstanceState)) {
            intent = Intent(intent).apply {
                action = Intent.ACTION_MAIN
                data = null
                replaceExtras(Bundle())
            }
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, SHARE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initial") deliverInitial(result) else result.notImplemented()
        }
        EventChannel(messenger, SHARE_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    sink = events
                }

                override fun onCancel(arguments: Any?) {
                    sink = null
                }
            },
        )
        MethodChannel(messenger, SERVICE_CHANNEL)
            .setMethodCallHandler(ConnectionService.handler(applicationContext))
        MethodChannel(messenger, SHORTCUTS_CHANNEL)
            .setMethodCallHandler(BotShortcuts.handler(applicationContext))
        MethodChannel(messenger, PUSH_CHANNEL)
            .setMethodCallHandler(PushBridge.handler(applicationContext))
        EventChannel(messenger, PUSH_EVENTS).setStreamHandler(PushBridge.events)
        current = WeakReference(this)
        io.execute { SharedFiles.cleanUp(cacheDir) }
        handleShare(intent)
    }

    /** The socket goes with the engine: a "connected" row would be a lie. */
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        ConnectionService.stop(applicationContext)
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onResume() {
        super.onResume()
        PushBridge.foreground = true
    }

    override fun onPause() {
        PushBridge.foreground = false
        super.onPause()
    }

    override fun onDestroy() {
        if (current?.get() === this) current = null
        super.onDestroy()
    }

    /** A share is never a Flutter route. */
    override fun getInitialRoute(): String? =
        if (isShare(intent)) "/" else super.getInitialRoute()

    override fun onNewIntent(intent: Intent) {
        if (isShare(intent)) {
            handleShare(intent)
            // Flutter would push `intent.data` as a route.
            intent.data = null
        }
        super.onNewIntent(intent)
        setIntent(intent)
    }

    private fun isShare(intent: Intent?): Boolean =
        intent?.action == Intent.ACTION_SEND || intent?.action == Intent.ACTION_SEND_MULTIPLE

    /** Relaunched from Recents, or recreated from saved state; not a plain launch. */
    private fun isReplay(intent: Intent?, savedInstanceState: Bundle?): Boolean {
        if (intent == null) return false
        if (intent.action == Intent.ACTION_MAIN && intent.data == null) return false
        val fromHistory = intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0
        return fromHistory || savedInstanceState != null
    }

    private fun handleShare(intent: Intent?) {
        if (intent == null || !isShare(intent)) return
        // A CharSequence: getStringExtra drops styled text, which many apps share.
        val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
            ?.takeIf { it.isNotBlank() }
        val uris = streams(intent)
        // A bot of the share sheet's top row (Direct Share, BotShortcuts).
        val bot = intent.getStringExtra(Intent.EXTRA_SHORTCUT_ID)?.takeIf { it.isNotBlank() }
        // Consumed, so a configuration change does not deliver it again.
        intent.action = Intent.ACTION_MAIN
        intent.data = null
        intent.removeExtra(Intent.EXTRA_STREAM)
        intent.removeExtra(Intent.EXTRA_TEXT)
        intent.removeExtra(Intent.EXTRA_SHORTCUT_ID)
        if (text == null && uris.isEmpty()) return

        copying++
        io.execute {
            val items = mutableListOf<Map<String, Any?>>()
            if (bot != null) items.add(mapOf("type" to "target", "profile" to bot))
            if (text != null) items.add(mapOf("type" to "text", "text" to text))
            var skipped = maxOf(0, uris.size - SharedFiles.MAX_FILES)
            try {
                var budget = SharedFiles.MAX_TOTAL_BYTES
                for (uri in uris.take(SharedFiles.MAX_FILES)) {
                    val copy = if (SharedFiles.accepts(uri, ownAuthorities, privateDirs)) {
                        SharedFiles.copy(contentResolver, cacheDir, uri, budget)
                    } else {
                        Log.w(TAG, "refused a shared stream (scheme ${uri.scheme})")
                        null
                    }
                    if (copy == null) {
                        skipped++
                    } else {
                        budget -= copy.bytes
                        items.add(copy.map)
                    }
                }
            } catch (e: Exception) {
                // Never leave Dart (and `copying`) waiting for this share.
                Log.w(TAG, "share copy failed", e)
            } finally {
                if (skipped > 0) items.add(mapOf("type" to "skipped", "count" to skipped))
                main.post { shareReady(items) }
            }
        }
    }

    /** `IntentCompat` picks the typed API on Android 13+ and the old one below. */
    private fun streams(intent: Intent): List<Uri> =
        try {
            if (intent.action == Intent.ACTION_SEND) {
                listOfNotNull(
                    IntentCompat.getParcelableExtra(intent, Intent.EXTRA_STREAM, Uri::class.java),
                )
            } else {
                IntentCompat.getParcelableArrayListExtra(intent, Intent.EXTRA_STREAM, Uri::class.java)
                    ?.filterNotNull().orEmpty()
            }
        } catch (e: RuntimeException) {
            Log.w(TAG, "unreadable shared streams", e)
            emptyList()
        }

    /** On the activity that is current now: the one that started the copy may be gone. */
    private fun shareReady(items: List<Map<String, Any?>>) {
        copying--
        val activity = current?.get()
        if (activity == null) {
            if (items.isNotEmpty()) pending = pending.orEmpty() + items
            return
        }
        activity.deliver(items)
    }

    private fun deliver(items: List<Map<String, Any?>>) {
        val waiter = initialWaiter
        when {
            waiter != null -> {
                initialWaiter = null
                waiter.success(items.ifEmpty { null })
            }
            items.isEmpty() -> Unit
            else -> {
                val events = sink
                // Nobody listens yet: kept with any share still waiting, as on iOS.
                if (events != null) events.success(items) else pending = pending.orEmpty() + items
            }
        }
    }

    private fun deliverInitial(result: MethodChannel.Result) {
        val ready = pending
        when {
            ready != null -> {
                pending = null
                result.success(ready)
            }
            copying > 0 -> {
                initialWaiter?.success(null)
                initialWaiter = result
            }
            else -> result.success(null)
        }
    }

    companion object {
        private const val TAG = "MainActivity"
        private val main = Handler(Looper.getMainLooper())

        /**
         * Process-wide, so a copy still running when the activity goes (a
         * configuration change, the user leaving) is not lost: its share waits
         * in [pending] for the next activity's `initial`.
         */
        private val io = Executors.newSingleThreadExecutor()
        private var copying = 0

        /** A finished share nobody asked for yet. */
        private var pending: List<Map<String, Any?>>? = null
        private var current: WeakReference<MainActivity>? = null

        /**
         * `PlatformChannels` in Dart (prefixed with `AppConfig.appId`);
         * `ShareBridge.swift` spells the share pair. Change them together.
         */
        private const val PREFIX = "se.royan.pomelu"
        private const val SHARE_CHANNEL = "$PREFIX/share"
        private const val SHARE_EVENTS = "$PREFIX/share/events"
        private const val SERVICE_CHANNEL = "$PREFIX/connection_service"
        private const val SHORTCUTS_CHANNEL = "$PREFIX/shortcuts"
        private const val PUSH_CHANNEL = "$PREFIX/push"
        private const val PUSH_EVENTS = "$PREFIX/push/events"
    }
}

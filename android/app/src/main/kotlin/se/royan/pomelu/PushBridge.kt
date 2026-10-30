package se.royan.pomelu

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Base64
import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import org.json.JSONObject

/**
 * Push through Google (FCM) for the Pomelu Hermes plugin. Dart's
 * `ChannelPushBridge`: `register {newKey}` gives `{platform, token, key,
 * sandbox}` (null without the Firebase config or Play services), and the
 * events send `{type: token}` when FCM renews the token. The key is this
 * phone's own (AES-256): the plugin seals each message with it, and only
 * [open] reads it. A tap opens the bot's chat link, as any deep link, so
 * `launchBot` is always null here.
 */
object PushBridge {
    private const val TAG = "PushBridge"
    private const val PREFS = "pomelu.push"
    private const val KEY = "key"
    private val main = Handler(Looper.getMainLooper())

    /** The app is on screen: it shows what comes itself. */
    @Volatile
    var foreground = false

    private var sink: EventChannel.EventSink? = null

    /** A build with the Firebase config. */
    private val configured: Boolean
        get() = BuildConfig.FIREBASE_APP_ID.isNotEmpty()

    /** Firebase up, for the app and for a process FCM starts to deliver. */
    fun start(context: Context) {
        if (!configured || FirebaseApp.getApps(context).isNotEmpty()) return
        val options = FirebaseOptions.Builder()
            .setApplicationId(BuildConfig.FIREBASE_APP_ID)
            .setApiKey(BuildConfig.FIREBASE_API_KEY)
            .setProjectId(BuildConfig.FIREBASE_PROJECT_ID)
            .setGcmSenderId(BuildConfig.FIREBASE_SENDER_ID)
            .build()
        FirebaseApp.initializeApp(context, options)
    }

    fun handler(context: Context) = MethodChannel.MethodCallHandler { call, result ->
        when (call.method) {
            "register" -> register(context, call.argument<Boolean>("newKey") == true, result)
            "launchBot" -> result.success(null)
            else -> result.notImplemented()
        }
    }

    val events = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            sink = events
        }

        override fun onCancel(arguments: Any?) {
            sink = null
        }
    }

    fun tokenChanged() {
        main.post { sink?.success(mapOf("type" to "token")) }
    }

    private fun register(context: Context, newKey: Boolean, result: MethodChannel.Result) {
        if (!configured) return result.success(null)
        try {
            start(context)
            val key = key(context, newKey)
            // Off until the user has push: no token for an app that never asked.
            FirebaseMessaging.getInstance().isAutoInitEnabled = true
            FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
                val token = task.result.takeIf { task.isSuccessful }
                if (token == null) {
                    Log.w(TAG, "no FCM token", task.exception)
                    result.success(null)
                } else {
                    result.success(
                        mapOf("platform" to "android", "token" to token, "key" to key, "sandbox" to false),
                    )
                }
            }
        } catch (e: RuntimeException) {
            // No Play services, or Firebase refused the config.
            Log.w(TAG, "push unavailable", e)
            result.success(null)
        }
    }

    /** This phone's key (base64), made once, or anew for another account. */
    @Synchronized
    private fun key(context: Context, renew: Boolean): String {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        prefs.getString(KEY, null)?.takeUnless { renew }?.let { return it }
        val bytes = ByteArray(32).also { SecureRandom().nextBytes(it) }
        val key = Base64.encodeToString(bytes, Base64.NO_WRAP)
        prefs.edit().putString(KEY, key).apply()
        return key
    }

    /** A message the plugin sealed: `{bot, title, body}`; null when this key cannot open it. */
    fun open(context: Context, sealed: String): Message? {
        val key = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
            ?: return null
        return try {
            val raw = Base64.decode(sealed, Base64.DEFAULT)
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(
                Cipher.DECRYPT_MODE,
                SecretKeySpec(Base64.decode(key, Base64.DEFAULT), "AES"),
                GCMParameterSpec(128, raw, 0, 12),
            )
            val json = JSONObject(String(cipher.doFinal(raw, 12, raw.size - 12), Charsets.UTF_8))
            Message(json.getString("bot"), json.optString("title"), json.optString("body"))
        } catch (e: Exception) {
            // Sealed for an old key (another account), or not ours.
            Log.w(TAG, "push not opened", e)
            null
        }
    }

    data class Message(val bot: String, val title: String, val body: String)
}

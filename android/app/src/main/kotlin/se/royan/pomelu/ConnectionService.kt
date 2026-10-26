package se.royan.pomelu

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.ServiceCompat
import io.flutter.plugin.common.MethodChannel

/**
 * "Stay connected": a foreground service that keeps the process, and with it
 * the Dart-side gateway socket, alive with the screen off. It only owns the
 * ongoing row Android asks for in exchange.
 *
 * Type `specialUse` (Android 14+; subtype in the manifest): a standing,
 * user-chosen connection to the user's own server fits no other type, and
 * `dataSync` is timed out on Android 15. Dart starts it only in the
 * foreground (Android 12+ refuses a start from the background) and asks
 * `isRunning` on resume, since the system can end it while the app is away.
 */
class ConnectionService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // The latest words: an `update` may have come between the start and now.
        val notification = buildNotification(this, title, body)
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        } else {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST
        }
        try {
            ServiceCompat.startForeground(this, NOTIFICATION_ID, notification, type)
            running = true
        } catch (e: RuntimeException) {
            // Started from the background, or the type's permission is missing.
            // startForeground is the first thing done, so there is no earlier
            // exit; after a refusal, stopping is all that is left.
            Log.w(TAG, "startForeground refused", e)
            stopSelf()
        }
        // Not sticky: a restart after a low-memory kill would have no Flutter
        // engine, so its row would claim a connection that is gone.
        return START_NOT_STICKY
    }

    /** Android 15+: a time-limited type ran out (a safety net for `specialUse`). */
    override fun onTimeout(startId: Int, fgsType: Int) = shutDown()

    /** The app was swiped away: the engine, and the socket, go too. */
    override fun onTaskRemoved(rootIntent: Intent?) {
        shutDown()
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        running = false
        super.onDestroy()
    }

    private fun shutDown() {
        running = false
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    companion object {
        private const val TAG = "ConnectionService"

        /** `NotificationChannels.connection` in Dart. */
        private const val CHANNEL_ID = "hermes.connection"
        private const val NOTIFICATION_ID = 1001

        @Volatile
        var running = false
            private set

        /** What the row says; set by `start` and `update`, read by every start. */
        @Volatile
        private var title: String? = null

        @Volatile
        private var body: String? = null

        /** The Dart side of [PlatformChannels.connectionService]. */
        fun handler(context: Context) = MethodChannel.MethodCallHandler { call, result ->
            when (call.method) {
                "start" -> try {
                    title = call.argument("title")
                    body = call.argument("body")
                    context.startForegroundService(Intent(context, ConnectionService::class.java))
                    result.success(true)
                } catch (e: RuntimeException) {
                    // Not allowed from the background (API 31+), or denied.
                    Log.w(TAG, "foreground service start refused", e)
                    result.error("refused", e.message, null)
                }
                // Same id: the row is replaced in place, no new start. Before the
                // service is up (`running` is set in onStartCommand) the start
                // itself shows the new words.
                "update" -> {
                    title = call.argument("title")
                    body = call.argument("body")
                    if (running) {
                        context.getSystemService(NotificationManager::class.java)
                            ?.notify(NOTIFICATION_ID, buildNotification(context, title, body))
                    }
                    result.success(true)
                }
                "stop" -> {
                    stop(context)
                    result.success(true)
                }
                "isRunning" -> result.success(running)
                else -> result.notImplemented()
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, ConnectionService::class.java))
            running = false
        }

        private fun buildNotification(context: Context, title: String?, body: String?): Notification {
            ensureChannel(context)
            val launch = Intent(context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
            val pending = PendingIntent.getActivity(
                context,
                0,
                launch,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            return Notification.Builder(context, CHANNEL_ID)
                .setContentTitle(title ?: context.getString(R.string.connection_default_title))
                .setContentText(body ?: context.getString(R.string.connection_default_body))
                .setSmallIcon(R.drawable.ic_stat_notify)
                .setContentIntent(pending)
                .setOngoing(true)
                .setShowWhen(false)
                .setCategory(Notification.CATEGORY_SERVICE)
                .build()
        }

        /**
         * Low importance: no sound, no heads-up. Dart creates the channel first
         * with its own strings; this is the fallback, so a start never meets a
         * missing channel.
         */
        private fun ensureChannel(context: Context) {
            val manager = context.getSystemService(NotificationManager::class.java) ?: return
            if (manager.getNotificationChannel(CHANNEL_ID) != null) return
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    context.getString(R.string.connection_channel_name),
                    NotificationManager.IMPORTANCE_LOW,
                ).apply {
                    description = context.getString(R.string.connection_channel_description)
                    setShowBadge(false)
                    enableVibration(false)
                    setSound(null, null)
                },
            )
        }
    }
}

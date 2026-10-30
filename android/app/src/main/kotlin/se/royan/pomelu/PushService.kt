package se.royan.pomelu

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * A bot's message by push (FCM, data only): opened with the phone's key and
 * posted as the bot's message row, the same id and tag Dart's
 * `NotificationPolicy.forMessage` uses, so a later one replaces it. Quiet
 * while the app is on screen, or while Stay connected holds the socket: the
 * app posts then, and a message rings once.
 */
class PushService : FirebaseMessagingService() {

    override fun onNewToken(token: String) = PushBridge.tokenChanged()

    override fun onMessageReceived(message: RemoteMessage) {
        val sealed = message.data["enc"] ?: return
        if (PushBridge.foreground || ConnectionService.running) return
        val opened = PushBridge.open(this, sealed) ?: return
        val notifications = NotificationManagerCompat.from(this)
        if (!notifications.areNotificationsEnabled()) return
        ensureChannel()
        val tag = "message/${opened.bot}"
        val id = stableHash(tag)
        val link = Uri.Builder().scheme("pomelu").authority("chat")
            .appendQueryParameter("profile", opened.bot).build()
        val tap = PendingIntent.getActivity(
            this,
            id,
            Intent(Intent.ACTION_VIEW, link, this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val row = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_notify)
            .setContentTitle(opened.title.ifEmpty { opened.bot })
            .setContentText(opened.body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(opened.body))
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(tap)
            .build()
        try {
            notifications.notify(tag, id, row)
        } catch (e: SecurityException) {
            // The grant went between the check and the post.
        }
    }

    /** Dart makes it with its localized name; this is for a push before that. */
    private fun ensureChannel() {
        val manager = getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Messages", NotificationManager.IMPORTANCE_HIGH),
        )
    }

    companion object {
        /** `NotificationChannels.messages` in Dart. */
        private const val CHANNEL_ID = "hermes.messages"

        /** Dart's `AppNotification.idFor`: the same 31-bit hash, never 0. */
        fun stableHash(text: String): Int {
            var hash = 0L
            for (unit in text) hash = (hash * 31 + unit.code) and 0x7fffffff
            return if (hash == 0L) 1 else hash.toInt()
        }
    }
}

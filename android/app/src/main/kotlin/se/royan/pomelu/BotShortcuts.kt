package se.royan.pomelu

import android.app.Person
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.BitmapFactory
import android.graphics.drawable.Icon
import android.net.Uri
import android.util.Log
import io.flutter.plugin.common.MethodChannel

/**
 * One dynamic shortcut per bot, with the bot's own avatar as Dart draws it:
 * an adaptive bitmap, clear around the round avatar, so the launcher adds
 * no tile of its own. The app icon's menu lists them, and a pick opens the
 * bot's `pomelu://chat` link, which the app takes as any deep link. They
 * are also Direct Share targets (`res/xml/shortcuts.xml`): the share
 * sheet's top row, whose share names the bot in [Intent.EXTRA_SHORTCUT_ID].
 */
object BotShortcuts {
    private const val TAG = "BotShortcuts"

    /** The category `res/xml/shortcuts.xml` shares to. */
    private const val SHARE_CATEGORY = "se.royan.pomelu.category.BOT_SHARE"

    /**
     * `set {items: [{id, title, link, icon?}]}`, at most the launcher's
     * count; `used {id}`: the user wrote to that bot, which the share sheet
     * ranks its top row by.
     */
    fun handler(context: Context) = MethodChannel.MethodCallHandler { call, result ->
        val manager = context.getSystemService(ShortcutManager::class.java)
        when {
            manager == null -> result.success(false)
            call.method == "set" -> set(context, manager, call.argument("items"), result)
            call.method == "used" -> {
                call.argument<String>("id")?.let(manager::reportShortcutUsed)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun set(
        context: Context,
        manager: ShortcutManager,
        items: List<Map<String, Any?>>?,
        result: MethodChannel.Result,
    ) {
        val shortcuts = items.orEmpty().take(manager.maxShortcutCountPerActivity).mapIndexedNotNull { rank, item ->
            val id = item["id"] as? String ?: return@mapIndexedNotNull null
            val title = (item["title"] as? String)?.takeIf { it.isNotBlank() } ?: id
            val link = item["link"] as? String ?: return@mapIndexedNotNull null
            val icon = icon(context, item["icon"] as? ByteArray)
            ShortcutInfo.Builder(context, id)
                .setShortLabel(title)
                .setIcon(icon)
                .setRank(rank)
                // A share target must outlive the menu's next change, and
                // stand for someone the user talks to.
                .setLongLived(true)
                .setPerson(Person.Builder().setKey(id).setName(title).setIcon(icon).build())
                .setCategories(setOf(SHARE_CATEGORY))
                .setIntent(
                    Intent(Intent.ACTION_VIEW, Uri.parse(link), context, MainActivity::class.java),
                )
                .build()
        }
        try {
            manager.dynamicShortcuts = shortcuts
            result.success(true)
        } catch (e: IllegalStateException) {
            // Rate-limited (the app is in the background): the next change sets them.
            Log.w(TAG, "shortcuts not set", e)
            result.success(false)
        }
    }

    private fun icon(context: Context, png: ByteArray?): Icon {
        val bitmap = png?.let { BitmapFactory.decodeByteArray(it, 0, it.size) }
        return if (bitmap != null) {
            Icon.createWithAdaptiveBitmap(bitmap)
        } else {
            Icon.createWithResource(context, R.drawable.ic_shortcut_bot)
        }
    }
}

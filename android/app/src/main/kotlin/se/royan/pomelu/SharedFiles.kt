package se.royan.pomelu

import android.content.ContentResolver
import android.net.Uri
import android.provider.OpenableColumns
import android.util.Log
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID

/**
 * Copies shared streams into the app cache before Dart sees them: the grant
 * of a content URI ends with the task. Blocking I/O, run off the main thread.
 *
 * A stream is opened with this app's rights, so only a `content://` URI of
 * another app's provider is accepted ([accepts]): a `file://` URI, or one of
 * this app's own providers, could hand its private files (tokens) to a chat.
 * The caps mirror the Dart side (`HermesLimits`).
 */
object SharedFiles {
    private const val TAG = "SharedFiles"
    private const val DIR = "shared"
    const val MAX_FILE_BYTES = 50L * 1024 * 1024
    const val MAX_TOTAL_BYTES = 64L * 1024 * 1024
    const val MAX_FILES = 10
    private const val MAX_AGE_MS = 3L * 24 * 60 * 60 * 1000

    /** A copy on disk; [map] is what Dart's `SharedItem` reads. */
    class Copied(val map: Map<String, Any?>, val bytes: Long)

    /** A `content://` URI not of [ownAuthorities] nor naming [privateDirs]. */
    fun accepts(uri: Uri, ownAuthorities: Set<String>, privateDirs: List<String>): Boolean {
        if (uri.scheme != ContentResolver.SCHEME_CONTENT) return false
        val authority = uri.authority ?: return false
        if (authority in ownAuthorities) return false
        val path = uri.path ?: return true
        return privateDirs.none { it.isNotEmpty() && path.contains(it) }
    }

    /**
     * Copies [uri], or null when it cannot be read or is over
     * [MAX_FILE_BYTES] or the rest of [budget]; a partial copy is deleted.
     * Never throws.
     */
    fun copy(resolver: ContentResolver, cacheDir: File, uri: Uri, budget: Long): Copied? {
        var target: File? = null
        return try {
            val limit = minOf(MAX_FILE_BYTES, budget)
            val declared = column(resolver, uri, OpenableColumns.SIZE)?.toLongOrNull()
            if (declared != null && declared > limit) {
                Log.w(TAG, "skipped a shared file of $declared bytes (limit $limit)")
                return null
            }
            val name = column(resolver, uri, OpenableColumns.DISPLAY_NAME)?.takeIf { it.isNotBlank() }
                ?: uri.lastPathSegment?.substringAfterLast('/')
                ?: "shared"
            // The display name goes to Dart; on disk only a UUID and the type.
            val ext = name.substringAfterLast('.', "").takeIf {
                it.length in 1..16 && it.all(Char::isLetterOrDigit)
            }
            val file = File(File(cacheDir, DIR).apply { mkdirs() }, UUID.randomUUID().toString() +
                (ext?.let { ".$it" } ?: ""))
            target = file
            val copied = resolver.openInputStream(uri)?.use { input ->
                file.outputStream().use { output -> copyLimited(input, output, limit) }
            } ?: return null
            if (copied < 0) {
                Log.w(TAG, "skipped a shared file over $limit bytes")
                file.delete()
                return null
            }
            Copied(
                mapOf(
                    "type" to "file",
                    "path" to file.absolutePath,
                    "mime" to resolver.getType(uri),
                    "name" to name,
                ),
                copied,
            )
        } catch (e: Exception) {
            Log.w(TAG, "could not copy a shared file", e)
            target?.delete()
            null
        }
    }

    /** At most [limit] bytes; -1 when the stream is longer. */
    private fun copyLimited(input: InputStream, output: OutputStream, limit: Long): Long {
        val buffer = ByteArray(64 * 1024)
        var total = 0L
        while (true) {
            val read = input.read(buffer)
            if (read < 0) return total
            total += read
            if (total > limit) return -1
            output.write(buffer, 0, read)
        }
    }

    /** Deletes copies older than three days. */
    fun cleanUp(cacheDir: File) {
        val cutoff = System.currentTimeMillis() - MAX_AGE_MS
        File(cacheDir, DIR).listFiles()?.forEach { if (it.lastModified() < cutoff) it.delete() }
    }

    private fun column(resolver: ContentResolver, uri: Uri, name: String): String? =
        resolver.query(uri, arrayOf(name), null, null, null)?.use { c ->
            val idx = c.getColumnIndex(name)
            if (idx >= 0 && c.moveToFirst() && !c.isNull(idx)) c.getString(idx) else null
        }
}

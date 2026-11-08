package com.firad.jatra

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import java.io.File
import java.io.IOException

/**
 * The folder automatic backups go to, through the Storage Access Framework.
 *
 * The user grants this one folder in the system picker. It needs no manifest
 * permission, and the grant survives restarts once taken as persistable.
 * Policy (when to back up, what to prune) stays in Dart.
 */
object BackupFolder {
    private const val JSON = "application/json"

    private val GRANT_FLAGS =
        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION

    fun pickIntent(): Intent =
        Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(
            GRANT_FLAGS or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
        )

    /** Keeps access to [tree] and returns the name to show for it. */
    fun persist(context: Context, tree: Uri): Map<String, String> {
        context.contentResolver.takePersistableUriPermission(tree, GRANT_FLAGS)
        return mapOf("uri" to tree.toString(), "label" to label(context, tree))
    }

    fun hasAccess(context: Context, tree: Uri): Boolean =
        context.contentResolver.persistedUriPermissions.any {
            it.uri == tree && it.isWritePermission
        }

    fun write(context: Context, tree: Uri, name: String, sourcePath: String) {
        val resolver = context.contentResolver
        val created = DocumentsContract.createDocument(resolver, root(tree), JSON, name)
            ?: throw IOException("The folder refused a new file")
        try {
            val output = resolver.openOutputStream(created)
                ?: throw IOException("The new file could not be opened")
            output.use { sink ->
                File(sourcePath).inputStream().use { it.copyTo(sink) }
            }
        } catch (e: Exception) {
            // Never leave a truncated file that looks like a good backup.
            runCatching { DocumentsContract.deleteDocument(resolver, created) }
            throw e
        }
    }

    fun list(context: Context, tree: Uri): List<String> = children(context, tree).map { it.second }

    fun delete(context: Context, tree: Uri, name: String) {
        val id = children(context, tree).firstOrNull { it.second == name }?.first ?: return
        DocumentsContract.deleteDocument(
            context.contentResolver,
            DocumentsContract.buildDocumentUriUsingTree(tree, id),
        )
    }

    private fun root(tree: Uri): Uri =
        DocumentsContract.buildDocumentUriUsingTree(
            tree,
            DocumentsContract.getTreeDocumentId(tree),
        )

    private fun label(context: Context, tree: Uri): String {
        val column = DocumentsContract.Document.COLUMN_DISPLAY_NAME
        context.contentResolver.query(root(tree), arrayOf(column), null, null, null)?.use {
            if (it.moveToFirst()) return it.getString(0)
        }
        return tree.lastPathSegment ?: tree.toString()
    }

    /** (document id, display name) of everything directly in the folder. */
    private fun children(context: Context, tree: Uri): List<Pair<String, String>> {
        val uri = DocumentsContract.buildChildDocumentsUriUsingTree(
            tree,
            DocumentsContract.getTreeDocumentId(tree),
        )
        val columns = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
        )
        val found = mutableListOf<Pair<String, String>>()
        context.contentResolver.query(uri, columns, null, null, null)?.use {
            while (it.moveToNext()) found += it.getString(0) to it.getString(1)
        }
        return found
    }
}

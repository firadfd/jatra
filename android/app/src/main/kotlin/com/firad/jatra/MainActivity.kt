package com.firad.jatra

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    private val backupExecutor = Executors.newSingleThreadExecutor()
    private var pendingFolderPick: MethodChannel.Result? = null

    /**
     * The home-screen widgets' only bridge.
     *
     * Three calls, all driven from Dart: which widgets are worth drawing
     * for, here is one face, and now put them on screen. Everything else —
     * what each panel says, how it is laid out, which theme it wears, which
     * shapes exist — stays in Dart alongside the rest of the app, so there
     * is exactly one definition of what a kilometre costs.
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HOME_WIDGET_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "placedPanels" -> result.success(JatraWidgets.placed(applicationContext))

                "update" -> {
                    val panel = call.argument<String>("panel")
                    val shape = call.argument<String>("shape")
                    val aspect = call.argument<Double>("aspect")
                    val png = call.argument<ByteArray>("png")
                    if (panel == null || shape == null || aspect == null || png == null) {
                        result.error(
                            "bad_args",
                            "panel, shape, aspect and png are required",
                            null,
                        )
                    } else {
                        WidgetImages.write(
                            applicationContext,
                            panel,
                            shape,
                            aspect.toFloat(),
                            png,
                        )
                        result.success(null)
                    }
                }

                // Once, after the whole set has landed, rather than after
                // each shape — otherwise every widget on the home screen
                // visibly flickers through several wrong proportions.
                "redraw" -> {
                    JatraWidgets.renderAll(applicationContext)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BACKUP_FOLDER_CHANNEL,
        ).setMethodCallHandler(::onBackupFolderCall)
    }

    private fun onBackupFolderCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "pick") {
            if (pendingFolderPick != null) {
                result.error("busy", "A folder picker is already open", null)
                return
            }
            pendingFolderPick = result
            startActivityForResult(BackupFolder.pickIntent(), PICK_BACKUP_FOLDER)
            return
        }

        // Storage providers can be slow, and a backup can be tens of MB.
        backupExecutor.execute {
            try {
                val tree = Uri.parse(call.argument<String>("uri"))
                val reply: Any? = when (call.method) {
                    "hasAccess" -> BackupFolder.hasAccess(applicationContext, tree)
                    "list" -> BackupFolder.list(applicationContext, tree)
                    "write" -> BackupFolder.write(
                        applicationContext,
                        tree,
                        call.argument<String>("name")!!,
                        call.argument<String>("sourcePath")!!,
                    )
                    "delete" -> BackupFolder.delete(
                        applicationContext,
                        tree,
                        call.argument<String>("name")!!,
                    )
                    else -> {
                        runOnUiThread { result.notImplemented() }
                        return@execute
                    }
                }
                runOnUiThread { result.success(if (reply is Unit) null else reply) }
            } catch (e: Exception) {
                runOnUiThread { result.error("backup_folder", e.message, null) }
            }
        }
    }

    @Deprecated("FlutterActivity is a plain Activity; this is its result callback")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_BACKUP_FOLDER) return

        val result = pendingFolderPick ?: return
        pendingFolderPick = null
        val tree = data?.data
        if (resultCode != RESULT_OK || tree == null) {
            result.success(null)
            return
        }
        try {
            result.success(BackupFolder.persist(applicationContext, tree))
        } catch (e: Exception) {
            result.error("backup_folder", e.message, null)
        }
    }

    private companion object {
        const val HOME_WIDGET_CHANNEL = "com.firad.jatra/home_widget"
        const val BACKUP_FOLDER_CHANNEL = "com.firad.jatra/backup_folder"
        const val PICK_BACKUP_FOLDER = 4107
    }
}

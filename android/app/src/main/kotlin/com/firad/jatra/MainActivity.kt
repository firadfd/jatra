package com.firad.jatra

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

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
    }

    private companion object {
        const val HOME_WIDGET_CHANNEL = "com.firad.jatra/home_widget"
    }
}

package com.firad.jatra

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.graphics.drawable.Icon
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import java.io.File
import kotlin.math.abs
import kotlin.math.ln

/**
 * Jatra's home-screen widgets.
 *
 * Five of them, so a rider can put a single chart on a home screen without
 * the other two and four figures coming along. They are all the same code:
 * the only thing that separates one from the next is its [panel] name, which
 * Flutter uses to decide what to draw.
 *
 * None of them builds its own face. `RemoteViews` has no chart primitive and
 * no access to the app's bundled fonts, so drawing a chart and four tabular
 * figures natively would mean reimplementing the design — and it would drift
 * from the app the first time either side changed. Instead Flutter rasterises
 * each face and hands it over through [WidgetImages]; this only puts the
 * right one on screen.
 *
 * "The right one" is the point. Flutter draws every panel once per shape — a
 * strip, a block, a column — and this picks whichever was drawn closest to
 * the aspect ratio the launcher is currently giving the widget. That is what
 * makes resizing work: the user drags a handle, the widget is redrawn
 * immediately from a bitmap already on disk, and the app never has to run.
 */
abstract class JatraWidgetProvider(private val panel: String) : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { render(context, appWidgetManager, panel, it) }
    }

    /** Fired on every resize, and the whole reason the shapes exist. */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        render(context, appWidgetManager, panel, appWidgetId)
    }

    /** The last widget of this kind off the home screen takes its faces with it. */
    override fun onDisabled(context: Context) {
        WidgetImages.clear(context, panel)
    }

    companion object {

        fun render(
            context: Context,
            appWidgetManager: AppWidgetManager,
            panel: String,
            appWidgetId: Int,
        ) {
            val views = RemoteViews(context.packageName, R.layout.jatra_widget)
            val png = WidgetImages.bestFor(
                context,
                panel,
                aspectOf(appWidgetManager, appWidgetId),
            )

            if (png == null) {
                views.setViewVisibility(R.id.jatra_widget_image, View.GONE)
                views.setViewVisibility(R.id.jatra_widget_placeholder, View.VISIBLE)
            } else {
                // The PNG travels to the launcher compressed, as icon data,
                // rather than as a decoded bitmap. A face is tens of
                // kilobytes this way and several megabytes the other, which
                // is the difference between fitting in a binder transaction
                // and not.
                views.setImageViewIcon(
                    R.id.jatra_widget_image,
                    Icon.createWithData(png, 0, png.size),
                )
                views.setViewVisibility(R.id.jatra_widget_image, View.VISIBLE)
                views.setViewVisibility(R.id.jatra_widget_placeholder, View.GONE)
            }

            views.setOnClickPendingIntent(R.id.jatra_widget_root, launchIntent(context))
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        /**
         * The widget's current width ÷ height, in dp, or 0 when the launcher
         * has not said.
         *
         * Portrait dimensions: `MIN_WIDTH` is the width the widget has when
         * the home screen is upright and `MAX_HEIGHT` the height, which is
         * the orientation a home screen is in essentially always.
         */
        private fun aspectOf(manager: AppWidgetManager, appWidgetId: Int): Float {
            val options = manager.getAppWidgetOptions(appWidgetId)
            val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)
            return if (width > 0 && height > 0) width.toFloat() / height else 0f
        }

        private fun launchIntent(context: Context): PendingIntent {
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            return PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}

// Android needs a distinct component per widget, so each panel gets a class
// of its own and an entry in the manifest. The names must match
// `WidgetPanel` in Dart — that enum is the source of truth for what each one
// draws, and renaming either side without the other orphans the widgets
// people have already placed.

class JatraStatsWidget : JatraWidgetProvider(JatraWidgets.ALL)

class JatraInfoWidget : JatraWidgetProvider(JatraWidgets.INFO)

class JatraSpendWidget : JatraWidgetProvider(JatraWidgets.SPEND)

class JatraDistanceWidget : JatraWidgetProvider(JatraWidgets.DISTANCE)

class JatraFuelCostWidget : JatraWidgetProvider(JatraWidgets.FUEL_COST)

/** The panel-to-component table, and the only place it appears. */
object JatraWidgets {

    const val ALL = "all"
    const val INFO = "info"
    const val SPEND = "spend"
    const val DISTANCE = "distance"
    const val FUEL_COST = "fuelCost"

    private val providers = mapOf(
        ALL to JatraStatsWidget::class.java,
        INFO to JatraInfoWidget::class.java,
        SPEND to JatraSpendWidget::class.java,
        DISTANCE to JatraDistanceWidget::class.java,
        FUEL_COST to JatraFuelCostWidget::class.java,
    )

    fun idsFor(context: Context, panel: String): IntArray {
        val provider = providers[panel] ?: return IntArray(0)
        return AppWidgetManager.getInstance(context)
            .getAppWidgetIds(ComponentName(context, provider))
    }

    /** Panels with at least one widget on a home screen. */
    fun placed(context: Context): List<String> =
        providers.keys.filter { idsFor(context, it).isNotEmpty() }

    /** Redraws everything placed, from whatever faces are already stored. */
    fun renderAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        providers.keys.forEach { panel ->
            idsFor(context, panel).forEach { id ->
                JatraWidgetProvider.render(context, manager, panel, id)
            }
        }
    }
}

/**
 * The rendered faces — one per panel per shape — and the aspect ratio each
 * was drawn at.
 *
 * Flutter owns the shape table; this only stores what it is given and
 * matches against it, so there is no second copy of those numbers to drift
 * out of step.
 *
 * The files live in the app's private storage and never leave the sandbox —
 * the launcher is handed the bytes through the system, not the path. Each is
 * a picture of the user's data, never the data itself.
 */
object WidgetImages {

    private const val DIRECTORY = "home_widget"
    private const val PREFS = "jatra_home_widget"

    private fun directory(context: Context, panel: String) =
        File(File(context.filesDir, DIRECTORY), panel)

    private fun fileFor(context: Context, panel: String, shape: String) =
        File(directory(context, panel), "$shape.png")

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun key(panel: String, shape: String) = "$panel/$shape"

    fun write(
        context: Context,
        panel: String,
        shape: String,
        aspect: Float,
        png: ByteArray,
    ) {
        directory(context, panel).mkdirs()
        fileFor(context, panel, shape).writeBytes(png)
        prefs(context).edit().putFloat(key(panel, shape), aspect).apply()
    }

    /**
     * The stored face for [panel] whose aspect ratio is nearest [aspect].
     *
     * Compared as a ratio rather than a difference — `ln` turns "twice as
     * wide" into the same distance whichever side it falls on, so a widget
     * halfway between two shapes is not pulled towards the wider one.
     *
     * Falls back to the tallest stored face when the launcher reports no
     * size, which is roughly what the providers ask for by default.
     */
    fun bestFor(context: Context, panel: String, aspect: Float): ByteArray? {
        val prefix = "$panel/"
        val stored = prefs(context).all.entries
            .filter { it.key.startsWith(prefix) }
            .mapNotNull { entry ->
                (entry.value as? Float)?.let { entry.key.removePrefix(prefix) to it }
            }
        if (stored.isEmpty()) return null

        val match = if (aspect > 0f) {
            stored.minByOrNull { abs(ln(aspect.toDouble()) - ln(it.second.toDouble())) }
        } else {
            stored.minByOrNull { it.second }
        }

        return match?.let {
            fileFor(context, panel, it.first).takeIf(File::exists)?.readBytes()
        }
    }

    fun clear(context: Context, panel: String) {
        directory(context, panel).deleteRecursively()

        val prefix = "$panel/"
        val editor = prefs(context).edit()
        prefs(context).all.keys.filter { it.startsWith(prefix) }.forEach(editor::remove)
        editor.apply()
    }
}

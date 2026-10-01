package com.nepali.patro.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews
import com.nepali.patro.R
import com.nepali.patro.today.PatroPrefs
import com.nepali.patro.today.TodayRefresher
import com.nepali.patro.today.openAppPendingIntent
import java.time.LocalDate

/** Common plumbing: every Patro widget renders from the prefs + today's date and opens the app on tap. */
abstract class PatroWidgetProvider : AppWidgetProvider() {

    protected abstract fun render(context: Context, prefs: PatroPrefs, today: LocalDate): RemoteViews

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        update(context, manager, ids, PatroPrefs(context), LocalDate.now())
        TodayRefresher.scheduleNextMidnight(context)
    }

    private fun update(context: Context, manager: AppWidgetManager, ids: IntArray, prefs: PatroPrefs, today: LocalDate) {
        if (ids.isEmpty()) return
        val views = render(context, prefs, today)
        views.setOnClickPendingIntent(R.id.widget_root, context.openAppPendingIntent())
        manager.updateAppWidget(ids, views)
    }

    companion object {
        private fun providers() = listOf(
            TodayWidgetProvider(),
            DeskWidgetProvider(),
            AgendaWidgetProvider(),
            WeekWidgetProvider(),
            MonthWidgetProvider(),
        )

        /** Re-renders every placed widget. Returns whether any widget is placed. */
        fun updateAll(context: Context, prefs: PatroPrefs, today: LocalDate): Boolean {
            val manager = AppWidgetManager.getInstance(context)
            return providers().fold(false) { anyPlaced, provider ->
                val ids = manager.getAppWidgetIds(ComponentName(context, provider.javaClass))
                provider.update(context, manager, ids, prefs, today)
                anyPlaced || ids.isNotEmpty()
            }
        }
    }
}

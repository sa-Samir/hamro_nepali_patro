package com.nepali.patro.today

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.content.getSystemService
import com.nepali.patro.widget.PatroWidgetProvider
import java.time.LocalDate
import java.time.ZoneId

/** Brings the notification and all widgets up to date and keeps the midnight alarm armed. */
object TodayRefresher {
    private const val MIDNIGHT_SLACK_SECONDS = 5L

    fun refreshAll(context: Context) {
        val prefs = PatroPrefs(context)
        val today = LocalDate.now()
        TodayNotification.update(context, prefs, today)
        val hasWidgets = PatroWidgetProvider.updateAll(context, prefs, today)
        if (hasWidgets || prefs.notificationEnabled) scheduleNextMidnight(context) else cancelMidnight(context)
    }

    /**
     * Exact when allowed (USE_EXACT_ALARM on 33+), otherwise inexact — which
     * Android may defer by up to an hour, leaving yesterday's date showing.
     */
    fun scheduleNextMidnight(context: Context) {
        val alarms = context.getSystemService<AlarmManager>() ?: return
        val triggerAt = LocalDate.now().plusDays(1)
            .atStartOfDay(ZoneId.systemDefault())
            .plusSeconds(MIDNIGHT_SLACK_SECONDS)
            .toInstant()
            .toEpochMilli()
        val canBeExact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()
        if (canBeExact) {
            alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, midnightIntent(context))
        } else {
            alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, midnightIntent(context))
        }
    }

    private fun cancelMidnight(context: Context) {
        context.getSystemService<AlarmManager>()?.cancel(midnightIntent(context))
    }

    private fun midnightIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
        context,
        0,
        Intent(context, DayChangeReceiver::class.java).setAction(DayChangeReceiver.ACTION_MIDNIGHT),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )
}

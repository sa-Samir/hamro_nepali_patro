package com.nepali.patro.today

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Fires on the midnight alarm and on boot/update/clock/timezone/locale changes (see manifest). */
class DayChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action in HANDLED_ACTIONS) TodayRefresher.refreshAll(context)
    }

    companion object {
        const val ACTION_MIDNIGHT = "com.nepali.patro.action.MIDNIGHT"

        private val HANDLED_ACTIONS = setOf(
            ACTION_MIDNIGHT,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_LOCALE_CHANGED,
        )
    }
}

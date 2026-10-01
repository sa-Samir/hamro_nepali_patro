package com.nepali.patro.widget

import android.content.Context
import android.widget.RemoteViews
import com.nepali.patro.R
import com.nepali.patro.today.PatroPrefs
import java.time.LocalDate

/** Small: today as a tear-off desk-calendar page. */
class DeskWidgetProvider : PatroWidgetProvider() {
    override fun render(context: Context, prefs: PatroPrefs, today: LocalDate): RemoteViews {
        val d = WidgetDay(context, prefs, today)
        return RemoteViews(context.packageName, R.layout.widget_desk).apply {
            setTextViewText(R.id.month_year, d.monthYear)
            setTextViewText(R.id.day, d.day)
            setTextViewText(R.id.weekday, d.weekday)
            setOptionalText(R.id.tithi, d.tithi)
            applyTheme(
                context, d, PHOTO_SIZE, PHOTO_SIZE,
                listOf(R.id.day to Role.NUMBER, R.id.weekday to Role.TEXT, R.id.tithi to Role.GOLD),
            )
            setInt(R.id.month_year, "setBackgroundResource", d.palette.deskStrip)
            setTextColor(R.id.month_year, d.palette.deskStripText)
        }
    }

    private companion object {
        const val PHOTO_SIZE = 420
    }
}

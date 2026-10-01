package com.nepali.patro.widget

import android.content.Context
import android.view.View
import android.widget.RemoteViews
import com.nepali.patro.R
import com.nepali.patro.today.MoonIcon
import com.nepali.patro.today.PatroPrefs
import java.time.LocalDate

/** Small: big day number, the moon's phase and tithi. */
class TodayWidgetProvider : PatroWidgetProvider() {
    override fun render(context: Context, prefs: PatroPrefs, today: LocalDate): RemoteViews {
        val d = WidgetDay(context, prefs, today)
        return RemoteViews(context.packageName, R.layout.widget_today).apply {
            setTextViewText(R.id.month_year, d.monthYear)
            setTextViewText(R.id.day, d.day)
            setTextViewText(R.id.weekday, d.weekday)
            setOptionalText(R.id.tithi, d.tithi)
            setTextViewText(R.id.ad_date, d.format.adLong(today))
            applyTheme(
                context, d, PHOTO_SIZE, PHOTO_SIZE,
                listOf(
                    R.id.month_year to Role.NUMBER,
                    R.id.day to Role.NUMBER,
                    R.id.weekday to Role.TEXT,
                    R.id.tithi to Role.GOLD,
                    R.id.ad_date to Role.MUTED,
                ),
            )
            if (d.tithiNumber != null) {
                setImageViewBitmap(R.id.moon, MoonIcon.create(d.tithiNumber))
            } else {
                setViewVisibility(R.id.moon, View.GONE)
            }
        }
    }

    private companion object {
        const val PHOTO_SIZE = 420
    }
}

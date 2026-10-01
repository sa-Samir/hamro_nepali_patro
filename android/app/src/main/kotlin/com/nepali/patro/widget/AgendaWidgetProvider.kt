package com.nepali.patro.widget

import android.content.Context
import android.graphics.Typeface
import android.text.SpannableString
import android.text.style.StyleSpan
import android.view.View
import android.widget.RemoteViews
import com.nepali.patro.R
import com.nepali.patro.today.PatroPrefs
import java.time.LocalDate

/** Medium "Upcoming": today on the left, countdowns to what's next on the right. */
class AgendaWidgetProvider : PatroWidgetProvider() {
    override fun render(context: Context, prefs: PatroPrefs, today: LocalDate): RemoteViews {
        val d = WidgetDay(context, prefs, today)
        val events = d.upcoming.take(MAX_EVENTS)
        return RemoteViews(context.packageName, R.layout.widget_agenda).apply {
            setTextViewText(R.id.month_year, d.monthYear)
            setTextViewText(R.id.day, d.day)
            setTextViewText(R.id.weekday, d.weekday)
            setOptionalText(R.id.tithi, d.tithi)
            setTextViewText(R.id.empty, d.format.text("Nothing coming up", "आगामी कार्यक्रम छैन"))
            setViewVisibility(R.id.empty, if (events.isEmpty()) View.VISIBLE else View.GONE)
            val p = d.palette
            applyTheme(
                context, d, PHOTO_WIDTH, PHOTO_HEIGHT,
                listOf(
                    R.id.month_year to Role.NUMBER,
                    R.id.day to Role.NUMBER,
                    R.id.weekday to Role.TEXT,
                    R.id.tithi to Role.GOLD,
                    R.id.empty to Role.MUTED,
                ),
            )
            setInt(R.id.divider, "setBackgroundColor", p.hair)
            if (d.theme == WidgetTheme.MARIGOLD) {
                // Today sits on a maroon panel, as in the notification's desk page.
                setInt(R.id.left_panel, "setBackgroundResource", R.drawable.widget_panel_maroon)
                setViewVisibility(R.id.divider, View.GONE)
                setTextColor(R.id.month_year, MARIGOLD_ON_MAROON)
                setTextColor(R.id.day, WHITE)
                setTextColor(R.id.weekday, WHITE)
                setTextColor(R.id.tithi, MARIGOLD_ON_MAROON)
            }
            removeAllViews(R.id.events)
            for (event in events) {
                val row = RemoteViews(context.packageName, R.layout.widget_agenda_row)
                val title = SpannableString(event.title)
                if (d.theme != WidgetTheme.CREAM) {
                    row.setTextColor(R.id.title, p.text)
                    row.setTextColor(R.id.date, p.muted)
                }
                if (event.isHoliday) {
                    title.setSpan(StyleSpan(Typeface.BOLD), 0, title.length, 0)
                    row.setTextColor(R.id.title, p.holiday)
                    row.setTextColor(R.id.date, p.holiday)
                }
                row.setTextViewText(R.id.title, title)
                row.setTextViewText(R.id.date, d.format.shortCountdown(d.daysUntil(event)))
                addView(R.id.events, row)
            }
        }
    }

    private companion object {
        const val MAX_EVENTS = 3
        const val PHOTO_WIDTH = 840
        const val PHOTO_HEIGHT = 400
        const val WHITE = 0xFFFFFFFF.toInt()
        const val MARIGOLD_ON_MAROON = 0xFFF6D58E.toInt()
    }
}

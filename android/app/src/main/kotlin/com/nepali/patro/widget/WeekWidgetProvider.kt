package com.nepali.patro.widget

import android.content.Context
import android.text.SpannableStringBuilder
import android.text.style.ForegroundColorSpan
import android.widget.RemoteViews
import com.nepali.patro.R
import com.nepali.patro.bs.BsConverter
import com.nepali.patro.today.PatroPrefs
import java.time.LocalDate

/** Medium "This week": today, Sunday–Saturday with today marked, the next event. */
class WeekWidgetProvider : PatroWidgetProvider() {
    override fun render(context: Context, prefs: PatroPrefs, today: LocalDate): RemoteViews {
        val d = WidgetDay(context, prefs, today)
        val sunday = today.minusDays(d.weekdayIndex.toLong())
        val holidays = prefs.events().filter { it.isHoliday }.mapTo(HashSet()) { it.date }
        return RemoteViews(context.packageName, R.layout.widget_week).apply {
            setTextViewText(R.id.day, d.day)
            setTextViewText(R.id.title, "${d.monthYear} · ${d.weekday}")
            setTextViewText(R.id.tithi, listOfNotNull(d.tithi, d.adShort).joinToString(" · "))
            val p = d.palette
            applyTheme(
                context, d, PHOTO_WIDTH, PHOTO_HEIGHT,
                listOf(R.id.day to Role.NUMBER, R.id.title to Role.TEXT, R.id.tithi to Role.GOLD, R.id.next to Role.MUTED),
            )
            for (i in 0..6) {
                val date = sunday.plusDays(i.toLong())
                setTextViewText(LABEL_IDS[i], d.format.weekdayShort(i))
                setTextColor(LABEL_IDS[i], if (i == SATURDAY) p.saturday else p.muted)
                setTextViewText(DAY_IDS[i], d.format.number(BsConverter.toBs(date).day))
                val textColor = when {
                    date == today -> p.todayText
                    date in holidays -> p.holiday
                    i == SATURDAY -> p.saturday
                    else -> p.text
                }
                setTextColor(DAY_IDS[i], textColor)
                // Set every cell: the layout carries a sample highlight for the picker preview.
                setInt(DAY_IDS[i], "setBackgroundResource", if (date == today) p.todayCell else 0)
            }
            val next = d.upcoming.firstOrNull()
            setOptionalText(
                R.id.next,
                next?.let {
                    val dotColor = if (it.isHoliday) p.holiday else p.muted
                    SpannableStringBuilder("● ").apply {
                        setSpan(ForegroundColorSpan(dotColor), 0, 1, 0)
                        append(d.format.countdown(it.title, d.daysUntil(it)))
                    }
                },
            )
        }
    }

    private companion object {
        const val SATURDAY = 6
        const val PHOTO_WIDTH = 840
        const val PHOTO_HEIGHT = 400
        val LABEL_IDS = intArrayOf(R.id.w0, R.id.w1, R.id.w2, R.id.w3, R.id.w4, R.id.w5, R.id.w6)
        val DAY_IDS = intArrayOf(R.id.d0, R.id.d1, R.id.d2, R.id.d3, R.id.d4, R.id.d5, R.id.d6)
    }
}

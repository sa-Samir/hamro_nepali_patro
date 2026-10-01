package com.nepali.patro.widget

import android.content.Context
import android.text.SpannableStringBuilder
import android.text.style.ForegroundColorSpan
import android.view.View
import android.widget.RemoteViews
import com.nepali.patro.R
import com.nepali.patro.bs.BsConverter
import com.nepali.patro.bs.BsDate
import com.nepali.patro.bs.BsFormat
import com.nepali.patro.today.PatroPrefs
import java.time.LocalDate

class MonthWidgetProvider : PatroWidgetProvider() {
    override fun render(context: Context, prefs: PatroPrefs, today: LocalDate): RemoteViews {
        val d = WidgetDay(context, prefs, today)
        val format = d.format
        val bs = d.bs
        // Holidays are fixed dates, so earlier ones in the visible month stay valid.
        val holidays = prefs.events()
            .filter { it.isHoliday }
            .map { BsConverter.toBs(it.date) }
            .filter { it.year == bs.year && it.month == bs.month }
            .mapTo(HashSet()) { it.day }
        // In the photo theme only the header is a photo; the grid stays on cream.
        val header = d.palette
        val colors = if (d.theme == WidgetTheme.PHOTO) WidgetTheme.CREAM.palette(context) else d.palette

        return RemoteViews(context.packageName, R.layout.widget_month).apply {
            setTextViewText(R.id.month_year, d.monthYear)
            setTextViewText(R.id.ad_range, "${adRange(format, bs.year, bs.month)} · ${format.season(bs.month)}")
            setTextViewText(R.id.today_label, "${format.text("Today", "आज")} ${d.day} · ${d.weekday}")
            setOptionalText(R.id.tithi, d.tithi)
            setInt(R.id.widget_root, "setBackgroundResource", colors.background)
            val photo = if (d.theme == WidgetTheme.PHOTO) {
                SeasonPhoto.load(context, bs.month, PHOTO_WIDTH, PHOTO_HEIGHT, prefs.seasonOverride)
            } else {
                null
            }
            if (photo != null) setImageViewBitmap(R.id.bg_photo, photo)
            setViewVisibility(R.id.bg_photo, if (photo != null) View.VISIBLE else View.GONE)
            if (d.theme != WidgetTheme.CREAM) {
                setTextColor(R.id.month_year, header.number)
                setTextColor(R.id.ad_range, header.muted)
                setTextColor(R.id.today_label, header.text)
                setTextColor(R.id.tithi, header.gold)
                setTextColor(R.id.next_title, colors.text)
                setTextColor(R.id.next_when, colors.muted)
            }
            setInt(R.id.next_divider, "setBackgroundColor", colors.hair)
            WEEKDAY_HEADER_IDS.forEachIndexed { weekday, id ->
                setTextViewText(id, format.weekdayShort(weekday))
                val headerColor = when (weekday) {
                    0 -> colors.sunday
                    SATURDAY -> colors.saturday
                    else -> colors.muted
                }
                setTextColor(id, headerColor)
            }

            // The next holiday if there is one in the data, otherwise the next event.
            val next = d.upcoming.firstOrNull { it.isHoliday } ?: d.upcoming.firstOrNull()
            val nextVisibility = if (next == null) View.GONE else View.VISIBLE
            setViewVisibility(R.id.next_divider, nextVisibility)
            setViewVisibility(R.id.next_row, nextVisibility)
            if (next != null) {
                val dotColor = if (next.isHoliday) colors.holiday else colors.muted
                setTextViewText(
                    R.id.next_title,
                    SpannableStringBuilder("● ").apply {
                        setSpan(ForegroundColorSpan(dotColor), 0, 1, 0)
                        append(next.title)
                    },
                )
                val nextBs = BsConverter.toBs(next.date)
                setTextViewText(
                    R.id.next_when,
                    "${format.month(nextBs.month)} ${format.number(nextBs.day)} · ${format.inDays(d.daysUntil(next))}",
                )
            }

            removeAllViews(R.id.grid)
            val leading = BsConverter.firstWeekday(bs.year, bs.month)
            val length = BsConverter.daysInMonth(bs.year, bs.month)
            val weeks = (leading + length + 6) / 7
            for (week in 0 until weeks) {
                val row = RemoteViews(context.packageName, R.layout.widget_month_row)
                for (weekday in 0 until 7) {
                    val day = week * 7 + weekday - leading + 1
                    val cell = RemoteViews(context.packageName, R.layout.widget_month_cell)
                    if (day in 1..length) {
                        cell.setTextViewText(R.id.cell, format.number(day))
                        val cellColor = when {
                            day == bs.day -> colors.todayText
                            day in holidays -> colors.holiday
                            weekday == SATURDAY -> colors.saturday
                            else -> colors.text
                        }
                        cell.setTextColor(R.id.cell, cellColor)
                        if (day == bs.day) cell.setInt(R.id.cell, "setBackgroundResource", colors.todayCell)
                    }
                    row.addView(R.id.row, cell)
                }
                addView(R.id.grid, row)
            }
        }
    }

    /** e.g. "Sep/Oct 2026" or "Dec 2026/Jan 2027". */
    private fun adRange(format: BsFormat, year: Int, month: Int): String {
        val start = BsConverter.toAd(BsDate(year, month, 1))
        val end = start.plusDays(BsConverter.daysInMonth(year, month) - 1L)
        return if (start.year == end.year) {
            "${format.adMonth(start.monthValue)}/${format.adMonth(end.monthValue)} ${format.number(end.year)}"
        } else {
            "${format.adMonth(start.monthValue)} ${format.number(start.year)}/${format.adMonth(end.monthValue)} ${format.number(end.year)}"
        }
    }

    private companion object {
        const val SATURDAY = 6
        const val PHOTO_WIDTH = 840
        const val PHOTO_HEIGHT = 230
        val WEEKDAY_HEADER_IDS = intArrayOf(R.id.wd0, R.id.wd1, R.id.wd2, R.id.wd3, R.id.wd4, R.id.wd5, R.id.wd6)
    }
}

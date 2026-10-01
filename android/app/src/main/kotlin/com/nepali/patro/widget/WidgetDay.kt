package com.nepali.patro.widget

import android.content.Context
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import com.nepali.patro.R
import com.nepali.patro.bs.BsConverter
import com.nepali.patro.bs.BsDate
import com.nepali.patro.bs.BsFormat
import com.nepali.patro.today.PatroEvent
import com.nepali.patro.today.PatroPrefs
import java.time.LocalDate
import java.time.temporal.ChronoUnit

/** What the widgets show about today, computed once per render. */
internal class WidgetDay(context: Context, val prefs: PatroPrefs, val today: LocalDate) {
    val format: BsFormat = prefs.format
    val bs: BsDate = BsConverter.toBs(today)
    val weekdayIndex: Int = BsConverter.sundayIndex(today)
    val weekday: String = format.weekdayFull(weekdayIndex)
    val monthYear: String = format.bsMonthYear(bs)
    val day: String = format.number(bs.day)
    val tithiNumber: Int? = prefs.tithiOn(today)
    val tithi: String? = tithiNumber?.let(format::tithi)
    val upcoming: List<PatroEvent> by lazy { prefs.eventsFrom(today) }
    val theme: WidgetTheme = WidgetTheme.from(prefs.widgetTheme)
    val palette: WidgetPalette by lazy { theme.palette(context) }

    fun daysUntil(event: PatroEvent): Long = ChronoUnit.DAYS.between(today, event.date)

    /** "AD date" in the short "Oct 1" form. */
    val adShort: String get() = "${format.adMonth(today.monthValue)} ${format.number(today.dayOfMonth)}"
}

internal fun RemoteViews.setOptionalText(id: Int, text: CharSequence?) {
    setTextViewText(id, text ?: "")
    setViewVisibility(id, if (text.isNullOrEmpty()) View.GONE else View.VISIBLE)
}

internal fun color(context: Context, id: Int) = ContextCompat.getColor(context, id)

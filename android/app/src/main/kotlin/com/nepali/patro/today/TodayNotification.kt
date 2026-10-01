package com.nepali.patro.today

import android.Manifest
import android.app.Notification
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.nepali.patro.R
import com.nepali.patro.bs.BsConverter
import com.nepali.patro.bs.BsDate
import com.nepali.patro.bs.BsFormat
import java.time.LocalDate
import java.time.temporal.ChronoUnit

/**
 * The ongoing "today" notification. The user picks one of several styles
 * (`pn_style`); all of them read from the same [TodayInfo].
 */
object TodayNotification {
    private const val CHANNEL_ID = "today_ongoing"

    // A tag keeps this id from colliding with ids chosen by flutter_local_notifications.
    private const val TAG = "patro_today"
    private const val ID = 1
    private const val MAX_EVENTS = 3

    fun update(context: Context, prefs: PatroPrefs, today: LocalDate) {
        val manager = NotificationManagerCompat.from(context)
        if (!prefs.notificationEnabled) {
            manager.cancel(TAG, ID)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        ensureChannel(context, manager)
        manager.notify(TAG, ID, build(context, TodayInfo(prefs, today)))
    }

    private fun build(context: Context, info: TodayInfo): Notification {
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            // Always Devanagari: the icon is meant to read like a Nepali wall calendar.
            .setSmallIcon(DayIcon.create(BsFormat("ne", "ne").number(info.bs.day)))
            .setColor(ContextCompat.getColor(context, R.color.patro_primary))
            // Plain text is also what the lock screen, accessibility and wearables use.
            .setContentTitle(info.headline)
            .setContentText(info.summary)
            .setContentIntent(context.openAppPendingIntent())
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        val views = when (info.style) {
            "page" -> page(context, info)
            "moon" -> moon(context, info) ?: number(context, info)
            "week" -> week(context, info)
            "countdown" -> countdown(context, info) ?: number(context, info)
            "plain" -> null
            else -> number(context, info)
        }
        if (views == null) {
            builder.setStyle(NotificationCompat.BigTextStyle().bigText(info.plainLines.joinToString("\n")))
        } else {
            builder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(views.first)
                .setCustomBigContentView(views.second)
        }
        return builder.build()
    }

    /** Big maroon day number beside the month and weekday. */
    private fun number(context: Context, info: TodayInfo): Pair<RemoteViews, RemoteViews> = with(info) {
        val monthYear = format.bsMonthYear(bs)
        RemoteViews(context.packageName, R.layout.notification_number).apply {
            setTextViewText(R.id.day, format.number(bs.day))
            setTextViewText(R.id.title, "$monthYear · $weekday")
            setTextViewText(R.id.subtitle, join(tithi, adDate))
        } to RemoteViews(context.packageName, R.layout.notification_number_big).apply {
            setTextViewText(R.id.day, format.number(bs.day))
            setTextViewText(R.id.title, monthYear)
            setTextViewText(R.id.subtitle, join(weekday, adDate))
            setOptionalText(R.id.tithi, tithi)
            fillEvents(context, info, events)
        }
    }

    /** A tear-off desk-calendar page: month on the strip, the day below. */
    private fun page(context: Context, info: TodayInfo): Pair<RemoteViews, RemoteViews> = with(info) {
        fun RemoteViews.fillPage() = apply {
            setTextViewText(R.id.month, format.month(bs.month))
            setTextViewText(R.id.day, format.number(bs.day))
        }
        RemoteViews(context.packageName, R.layout.notification_page).fillPage().apply {
            setTextViewText(R.id.title, weekday)
            setTextViewText(R.id.subtitle, join(tithi, adDate))
        } to RemoteViews(context.packageName, R.layout.notification_page_big).fillPage().apply {
            setTextViewText(R.id.year, format.number(bs.year))
            setTextViewText(R.id.title, weekday)
            setTextViewText(R.id.subtitle, adDate ?: format.bsLong(bs))
            setOptionalText(R.id.tithi, tithi)
            fillEvents(context, info, events)
        }
    }

    /** The lunar day first, with the moon's phase drawn. Null without tithi data. */
    private fun moon(context: Context, info: TodayInfo): Pair<RemoteViews, RemoteViews>? = with(info) {
        val tithiNumber = tithiNumber ?: return null
        val moonImage = MoonIcon.create(tithiNumber)
        val dates = join(weekday, format.bsLong(bs))
        RemoteViews(context.packageName, R.layout.notification_moon).apply {
            setImageViewBitmap(R.id.moon, moonImage)
            setTextViewText(R.id.title, tithi)
            setTextViewText(R.id.subtitle, dates)
        } to RemoteViews(context.packageName, R.layout.notification_moon_big).apply {
            setImageViewBitmap(R.id.moon, moonImage)
            setTextViewText(R.id.title, tithi)
            setTextViewText(R.id.subtitle, join(dates, adDate))
            setOptionalText(R.id.tithi, nextMoons)
            fillEvents(context, info, events)
        }
    }

    /** This week, Sunday to Saturday, with today marked. */
    private fun week(context: Context, info: TodayInfo): Pair<RemoteViews, RemoteViews> = with(info) {
        val title = "${format.bsLong(bs)}, $weekday"
        val subtitle = join(tithi, adDate)
        val sunday = today.minusDays(BsConverter.sundayIndex(today).toLong())
        val holidays = prefs.events().filter { it.isHoliday }.map { it.date }.toSet()
        RemoteViews(context.packageName, R.layout.notification_text).apply {
            setTextViewText(R.id.title, title)
            setTextViewText(R.id.subtitle, subtitle)
        } to RemoteViews(context.packageName, R.layout.notification_week_big).apply {
            setTextViewText(R.id.title, title)
            setTextViewText(R.id.subtitle, subtitle)
            for (i in 0..6) {
                val date = sunday.plusDays(i.toLong())
                setTextViewText(WEEKDAY_IDS[i], format.weekdayShort(i))
                setTextViewText(DAY_IDS[i], format.number(BsConverter.toBs(date).day))
                val color = when {
                    date == today -> R.color.patro_on_primary
                    date in holidays -> R.color.notification_holiday
                    i == 6 -> R.color.notification_saturday
                    else -> null
                }
                if (color != null) setTextColor(DAY_IDS[i], ContextCompat.getColor(context, color))
                if (date == today) setInt(DAY_IDS[i], "setBackgroundResource", R.drawable.notification_week_today)
            }
            fillEvents(context, info, events.take(1))
        }
    }

    /** Days until the next holiday, festival or reminder, today's date below. Null if none. */
    private fun countdown(context: Context, info: TodayInfo): Pair<RemoteViews, RemoteViews>? = with(info) {
        val next = events.firstOrNull() ?: return null
        val days = ChronoUnit.DAYS.between(today, next.date)
        val todayLine = join("${format.bsLong(bs)}, $weekday", tithi, adDate)
        RemoteViews(context.packageName, R.layout.notification_text).apply {
            setTextViewText(R.id.title, format.countdown(next.title, days))
            setTextViewText(R.id.subtitle, todayLine)
        } to RemoteViews(context.packageName, R.layout.notification_countdown_big).apply {
            if (days > 1) {
                setTextViewText(R.id.day, format.number(days.toInt()))
                setTextViewText(R.id.title, format.text("days until ${next.title}", "दिनमा ${next.title}"))
            } else {
                setViewVisibility(R.id.day, View.GONE)
                setTextViewText(R.id.title, format.countdown(next.title, days))
            }
            if (next.isHoliday) setTextColor(R.id.day, ContextCompat.getColor(context, R.color.notification_holiday))
            setTextViewText(R.id.subtitle, todayLine)
            fillEvents(context, info, events.drop(1))
        }
    }

    private fun RemoteViews.setOptionalText(id: Int, text: String?) {
        setTextViewText(id, text.orEmpty())
        setViewVisibility(id, if (text == null) View.GONE else View.VISIBLE)
    }

    private fun RemoteViews.fillEvents(context: Context, info: TodayInfo, events: List<PatroEvent>) {
        removeAllViews(R.id.events)
        events.forEach { addView(R.id.events, eventRow(context, info.format, it, info.today)) }
        setViewVisibility(R.id.events, if (events.isEmpty()) View.GONE else View.VISIBLE)
    }

    private fun eventRow(context: Context, format: BsFormat, event: PatroEvent, today: LocalDate): RemoteViews {
        val color = when (event.kind) {
            "holiday" -> R.color.notification_holiday
            "note" -> R.color.notification_note
            else -> R.color.notification_event
        }
        return RemoteViews(context.packageName, R.layout.notification_event_row).apply {
            setInt(R.id.bar, "setColorFilter", ContextCompat.getColor(context, color))
            setTextViewText(R.id.`when`, format.relativeDay(event.date, today))
            setTextViewText(R.id.title, event.title)
        }
    }

    private fun ensureChannel(context: Context, manager: NotificationManagerCompat) {
        val channel = NotificationChannelCompat.Builder(CHANNEL_ID, NotificationManagerCompat.IMPORTANCE_LOW)
            .setName(context.getString(R.string.notification_channel_name))
            .setDescription(context.getString(R.string.notification_channel_description))
            .setShowBadge(false)
            .setSound(null, null)
            .setVibrationEnabled(false)
            .build()
        manager.createNotificationChannel(channel)
    }

    private val WEEKDAY_IDS = intArrayOf(R.id.w0, R.id.w1, R.id.w2, R.id.w3, R.id.w4, R.id.w5, R.id.w6)
    private val DAY_IDS = intArrayOf(R.id.d0, R.id.d1, R.id.d2, R.id.d3, R.id.d4, R.id.d5, R.id.d6)
}

/** Everything the notification styles may show, computed once per refresh. */
private class TodayInfo(val prefs: PatroPrefs, val today: LocalDate) {
    val format: BsFormat = prefs.format
    val style: String = prefs.notificationStyle
    val bs: BsDate = BsConverter.toBs(today)
    val weekday: String = format.weekdayFull(BsConverter.sundayIndex(today))
    val tithiNumber: Int? = prefs.tithiOn(today)
    val tithi: String? = tithiNumber?.let(format::tithi)
    val adDate: String? = format.adLong(today).takeIf { prefs.notificationShowsAd }
    val events: List<PatroEvent> =
        if (prefs.notificationShowsEvents) prefs.eventsFrom(today).take(MAX_EVENTS) else emptyList()

    /** Title and text for the plain style, the lock screen and accessibility. */
    val headline = "${format.bsLong(bs)} · $weekday"
    val summary: String = join(
        tithi,
        events.firstOrNull()?.let { "${format.relativeDay(it.date, today)}: ${it.title}" } ?: adDate,
    )
    val plainLines: List<String> = listOfNotNull(tithi, adDate) +
        events.map { "${format.relativeDay(it.date, today)}: ${it.title}" }

    /** "औंसी १० दिनमा · पूर्णिमा २५ दिनमा", soonest first. */
    val nextMoons: String? by lazy {
        val aunsi = daysUntilTithi(30)
        val purnima = daysUntilTithi(15)
        listOfNotNull(
            aunsi?.let { it to "${format.text("Aunsi", "औंसी")} ${format.inDays(it)}" },
            purnima?.let { it to "${format.text("Purnima", "पूर्णिमा")} ${format.inDays(it)}" },
        ).sortedBy { it.first }.joinToString(" · ") { it.second }.ifEmpty { null }
    }

    /**
     * Days until [target] (15 or 30) is the sunrise tithi, also catching the
     * day it is skipped (the tithi count passes over it).
     */
    private fun daysUntilTithi(target: Int): Long? {
        var previous = tithiNumber ?: return null
        for (d in 1L..31L) {
            val t = prefs.tithiOn(today.plusDays(d)) ?: return null
            val passed = if (target == 30) t < previous else previous < 15 && t > 15
            if (t == target || passed) return d
            previous = t
        }
        return null
    }

    private companion object {
        const val MAX_EVENTS = 3
    }
}

private fun join(vararg parts: String?): String = parts.filterNotNull().joinToString(" · ")

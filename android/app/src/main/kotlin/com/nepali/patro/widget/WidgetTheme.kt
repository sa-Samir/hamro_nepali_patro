package com.nepali.patro.widget

import android.content.Context
import android.view.View
import android.widget.RemoteViews
import androidx.annotation.DrawableRes
import com.nepali.patro.R

/** Text roles a widget view can take; each theme maps them to a colour. */
internal enum class Role { TEXT, MUTED, NUMBER, GOLD, HOLIDAY, SATURDAY, SUNDAY }

/** Colours and backgrounds of one widget theme. */
internal class WidgetPalette(
    val text: Int,
    val muted: Int,
    val number: Int,
    val gold: Int,
    val holiday: Int,
    val saturday: Int,
    val sunday: Int,
    val hair: Int,
    val todayText: Int,
    @DrawableRes val todayCell: Int,
    @DrawableRes val background: Int,
    @DrawableRes val deskStrip: Int,
    val deskStripText: Int,
) {
    fun of(role: Role): Int = when (role) {
        Role.TEXT -> text
        Role.MUTED -> muted
        Role.NUMBER -> number
        Role.GOLD -> gold
        Role.HOLIDAY -> holiday
        Role.SATURDAY -> saturday
        Role.SUNDAY -> sunday
    }
}

/** The user's widget theme (`widget_theme`, set in the app's Settings). */
internal enum class WidgetTheme(private val key: String) {
    /** Cream card; the only theme with a separate dark-mode version (values-night). */
    CREAM("cream"),

    /** The season's photo under a dark wash, like the app header. */
    PHOTO("photo"),
    MAROON("maroon"),
    MARIGOLD("marigold"),
    ;

    fun palette(context: Context): WidgetPalette = when (this) {
        CREAM -> WidgetPalette(
            text = color(context, R.color.widget_text),
            muted = color(context, R.color.widget_muted),
            number = color(context, R.color.widget_number),
            gold = color(context, R.color.widget_gold),
            holiday = color(context, R.color.widget_holiday),
            saturday = color(context, R.color.widget_gold),
            sunday = color(context, R.color.widget_number),
            hair = color(context, R.color.widget_hair),
            todayText = WHITE,
            todayCell = R.drawable.notification_week_today,
            background = R.drawable.widget_bg,
            deskStrip = R.drawable.widget_desk_strip,
            deskStripText = WHITE,
        )
        PHOTO -> WidgetPalette(
            text = WHITE,
            muted = 0xFFEADBD2.toInt(),
            number = WHITE,
            gold = MARIGOLD_ACCENT,
            holiday = 0xFFFFB4A9.toInt(),
            saturday = MARIGOLD_ACCENT,
            sunday = WHITE,
            hair = 0x55FFFFFF,
            todayText = 0xFF3A1A0E.toInt(),
            todayCell = R.drawable.widget_today_marigold,
            background = R.drawable.widget_bg_photo,
            deskStrip = R.drawable.widget_desk_strip_glass,
            deskStripText = WHITE,
        )
        MAROON -> WidgetPalette(
            text = WHITE,
            muted = 0xFFE8C9C0.toInt(),
            number = WHITE,
            gold = MARIGOLD_ACCENT,
            holiday = 0xFFFFB4A9.toInt(),
            saturday = MARIGOLD_ACCENT,
            sunday = 0xFFFFD8CF.toInt(),
            hair = 0x40FFFFFF,
            todayText = 0xFF3A1A0E.toInt(),
            todayCell = R.drawable.widget_today_marigold,
            background = R.drawable.widget_bg_maroon,
            deskStrip = R.drawable.widget_desk_strip_marigold,
            deskStripText = 0xFF6E1B1B.toInt(),
        )
        MARIGOLD -> WidgetPalette(
            text = 0xFF3A1A0E.toInt(),
            muted = 0xFF6B4A2E.toInt(),
            number = 0xFF7A1F1F.toInt(),
            gold = 0xFF8A3B12.toInt(),
            holiday = 0xFFA3201A.toInt(),
            saturday = 0xFF8A3B12.toInt(),
            sunday = 0xFF7A1F1F.toInt(),
            hair = 0x337A1F1F,
            todayText = WHITE,
            todayCell = R.drawable.notification_week_today,
            background = R.drawable.widget_bg_marigold,
            deskStrip = R.drawable.widget_desk_strip,
            deskStripText = WHITE,
        )
    }

    companion object {
        private const val WHITE = 0xFFFFFFFF.toInt()
        private const val MARIGOLD_ACCENT = 0xFFF2C66D.toInt()

        fun from(key: String?): WidgetTheme = entries.firstOrNull { it.key == key } ?: CREAM
    }
}

/**
 * Background and text colours for a widget whose root is `widget_root` with an
 * optional `bg_photo` layer. Cream leaves the XML colours alone so the
 * launcher can still switch them for dark mode.
 */
internal fun RemoteViews.applyTheme(
    context: Context,
    day: WidgetDay,
    photoWidth: Int,
    photoHeight: Int,
    roles: List<Pair<Int, Role>>,
) {
    val theme = day.theme
    val palette = day.palette
    setInt(R.id.widget_root, "setBackgroundResource", palette.background)
    val photo = if (theme == WidgetTheme.PHOTO) SeasonPhoto.load(context, day.bs.month, photoWidth, photoHeight, day.prefs.seasonOverride) else null
    if (photo != null) setImageViewBitmap(R.id.bg_photo, photo)
    setViewVisibility(R.id.bg_photo, if (photo != null) View.VISIBLE else View.GONE)
    if (theme != WidgetTheme.CREAM) roles.forEach { (id, role) -> setTextColor(id, palette.of(role)) }
}

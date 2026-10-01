package com.nepali.patro.today

import android.content.Context
import com.nepali.patro.bs.BsConverter
import com.nepali.patro.bs.BsFormat
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.time.LocalDate
import java.time.format.DateTimeParseException

data class PatroEvent(val date: LocalDate, val title: String, val kind: String) {
    val isHoliday: Boolean get() = kind == "holiday"
}

/** Read-only view of the values Flutter writes through `home_widget` (see docs/NATIVE_CONTRACT.md). */
class PatroPrefs(context: Context) {
    private val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

    init {
        BsConverter.applyOverrides(prefs.getString("bs_overrides", null))
    }

    val format: BsFormat = BsFormat(
        lang = prefs.getString("lang", null) ?: "ne",
        numerals = prefs.getString("numerals", null) ?: "ne",
    )
    val notificationEnabled: Boolean get() = prefs.getBoolean("pn_enabled", false)
    val notificationShowsAd: Boolean get() = prefs.getBoolean("pn_show_ad", true)
    val notificationShowsEvents: Boolean get() = prefs.getBoolean("pn_show_events", true)

    /** Season photo to show instead of the current one, e.g. "basanta"; null follows the calendar. */
    val seasonOverride: String? get() = prefs.getString("season_override", null)?.takeIf { it.isNotEmpty() }

    /** Home-screen widget theme: "cream", "photo", "maroon" or "marigold". */
    val widgetTheme: String? get() = prefs.getString("widget_theme", null)

    /** Notification layout: "number", "page", "moon", "week", "countdown" or "plain". */
    val notificationStyle: String get() = prefs.getString("pn_style", null) ?: "number"

    /** All stored events in date order. Malformed entries are skipped. */
    fun events(): List<PatroEvent> {
        val array = try {
            JSONArray(prefs.getString("events", null) ?: return emptyList())
        } catch (e: JSONException) {
            return emptyList()
        }
        return (0 until array.length())
            .mapNotNull { index -> array.optJSONObject(index)?.let(::parseEvent) }
            .sortedBy { it.date }
    }

    /** Events on or after [today], in date order. */
    /** Sunrise tithi (1–30) for [date], if the app has published it. */
    fun tithiOn(date: LocalDate): Int? {
        val json = prefs.getString("tithis", null) ?: return null
        return try {
            JSONObject(json).optInt(date.toString(), 0).takeIf { it in 1..30 }
        } catch (_: JSONException) {
            null
        }
    }

    fun eventsFrom(today: LocalDate): List<PatroEvent> = events().filter { !it.date.isBefore(today) }

    private fun parseEvent(json: JSONObject): PatroEvent? {
        val title = json.optString("title").takeIf { it.isNotBlank() } ?: return null
        val date = try {
            LocalDate.parse(json.optString("ad"))
        } catch (e: DateTimeParseException) {
            return null
        }
        return PatroEvent(date, title, json.optString("kind"))
    }
}

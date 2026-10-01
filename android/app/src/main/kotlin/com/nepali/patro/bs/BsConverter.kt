package com.nepali.patro.bs

import org.json.JSONException
import org.json.JSONObject
import java.time.LocalDate
import java.time.temporal.ChronoUnit

/** A Bikram Sambat date. [month] is 1-based (1 = Baisakh). */
data class BsDate(val year: Int, val month: Int, val day: Int)

object BsConverter {
    private val epoch: LocalDate =
        LocalDate.of(BsData.EPOCH_AD_YEAR, BsData.EPOCH_AD_MONTH, BsData.EPOCH_AD_DAY)

    // Bundled table, with rows replaced by official corrections the app downloaded.
    @Volatile private var table: Array<IntArray> = BsData.MONTH_LENGTHS
    @Volatile private var yearLengths: IntArray = totals(table)
    private var appliedOverrides: String? = null

    /**
     * Applies `{"2084": [31, 32, …]}` corrections written by the Flutter app.
     * Invalid rows are ignored, so bad data can't break the widgets.
     */
    fun applyOverrides(json: String?) {
        if (json == appliedOverrides) return
        val rows = BsData.MONTH_LENGTHS.copyOf()
        try {
            val obj = JSONObject(json ?: "{}")
            for (key in obj.keys()) {
                val year = key.toIntOrNull() ?: continue
                val array = obj.optJSONArray(key) ?: continue
                val row = IntArray(array.length()) { array.optInt(it) }
                if (year in BsData.FIRST_YEAR..BsData.LAST_YEAR && isValidYear(row)) {
                    rows[year - BsData.FIRST_YEAR] = row
                }
            }
        } catch (_: JSONException) {
            return
        }
        table = rows
        yearLengths = totals(rows)
        appliedOverrides = json
    }

    private fun isValidYear(row: IntArray) = row.size == 12 && row.all { it in 29..32 } && row.sum() in 365..366

    private fun totals(rows: Array<IntArray>) = IntArray(rows.size) { rows[it].sum() }

    fun daysInMonth(year: Int, month: Int): Int = monthsOf(year)[month - 1]

    fun toBs(date: LocalDate): BsDate {
        var remaining = ChronoUnit.DAYS.between(epoch, date)
        require(remaining >= 0) { "$date is before the supported BS range" }
        var yearIndex = 0
        val yearLengths = yearLengths
        while (remaining >= yearLengths[yearIndex]) {
            remaining -= yearLengths[yearIndex]
            yearIndex++
            require(yearIndex < yearLengths.size) { "$date is after the supported BS range" }
        }
        val months = table[yearIndex]
        var month = 0
        while (remaining >= months[month]) {
            remaining -= months[month]
            month++
        }
        return BsDate(BsData.FIRST_YEAR + yearIndex, month + 1, remaining.toInt() + 1)
    }

    fun toAd(date: BsDate): LocalDate {
        val months = monthsOf(date.year)
        require(date.day in 1..months[date.month - 1]) { "Invalid BS date $date" }
        val yearIndex = date.year - BsData.FIRST_YEAR
        val yearLengths = yearLengths
        val days = (0 until yearIndex).sumOf { yearLengths[it].toLong() } +
            (0 until date.month - 1).sumOf { months[it].toLong() } +
            (date.day - 1)
        return epoch.plusDays(days)
    }

    /** Weekday of the 1st of the BS month, 0 = Sunday … 6 = Saturday. */
    fun firstWeekday(year: Int, month: Int): Int = sundayIndex(toAd(BsDate(year, month, 1)))

    /** 0 = Sunday … 6 = Saturday. */
    fun sundayIndex(date: LocalDate): Int = date.dayOfWeek.value % 7

    private fun monthsOf(year: Int): IntArray {
        require(year in BsData.FIRST_YEAR..BsData.LAST_YEAR) { "BS year $year out of range" }
        return table[year - BsData.FIRST_YEAR]
    }
}

package com.nepali.patro.bs

import java.time.LocalDate

/** Localized names and numerals. [lang] and [numerals] take "ne" or "en". */
class BsFormat(lang: String, numerals: String) {
    val isNepali = lang == "ne"
    private val devanagari = numerals == "ne"

    fun number(value: Int): String {
        val western = value.toString()
        if (!devanagari) return western
        return western.map { if (it in '0'..'9') DEVANAGARI_ZERO + (it - '0') else it }.joinToString("")
    }

    fun month(month: Int): String = (if (isNepali) MONTHS_NE else MONTHS_EN)[month - 1]

    /** [weekday] is 0 = Sunday … 6 = Saturday. */
    fun weekdayShort(weekday: Int): String = (if (isNepali) WEEKDAYS_SHORT_NE else WEEKDAYS_SHORT_EN)[weekday]

    fun weekdayFull(weekday: Int): String = (if (isNepali) WEEKDAYS_FULL_NE else WEEKDAYS_FULL_EN)[weekday]

    /** e.g. "असोज १४, २०८३". */
    fun bsLong(date: BsDate): String = "${month(date.month)} ${number(date.day)}, ${number(date.year)}"

    /** e.g. "असोज २०८३". */
    fun bsMonthYear(date: BsDate): String = "${month(date.month)} ${number(date.year)}"

    fun adMonth(month: Int): String = (if (isNepali) AD_MONTHS_NE else AD_MONTHS_EN)[month - 1]

    /** e.g. "Sep 30, 2026" or "सेप्टेम्बर ३०, २०२६". */
    fun adLong(date: LocalDate): String = "${adMonth(date.monthValue)} ${number(date.dayOfMonth)}, ${number(date.year)}"

    /** "Today" / "Tomorrow", otherwise the BS month and day, e.g. "कात्तिक २५". */
    fun relativeDay(date: LocalDate, today: LocalDate): String = when (date) {
        today -> text("Today", "आज")
        today.plusDays(1) -> text("Tomorrow", "भोलि")
        else -> BsConverter.toBs(date).let { "${month(it.month)} ${number(it.day)}" }
    }

    fun text(en: String, ne: String): String = if (isNepali) ne else en

    /** "आज" / "भोलि" / "१० दिनमा". */
    fun inDays(days: Long): String = when (days) {
        0L -> text("today", "आज")
        1L -> text("tomorrow", "भोलि")
        else -> text("in ${number(days.toInt())} days", "${number(days.toInt())} दिनमा")
    }

    /** Compact countdown for lists: "आज" / "भोलि" / "३ दिन". */
    fun shortCountdown(days: Long): String = when (days) {
        0L -> text("Today", "आज")
        1L -> text("Tomorrow", "भोलि")
        else -> text("${number(days.toInt())} days", "${number(days.toInt())} दिन")
    }

    /** The ritu of a BS month: Chaitra–Baisakh Basanta, then two months each. */
    fun season(month: Int): String {
        val index = (month % 12) / 2
        return (if (isNepali) SEASONS_NE else SEASONS_EN)[index]
    }

    /** "घटस्थापना १० दिनमा" / "Ghatasthapana in 10 days". */
    fun countdown(title: String, days: Long): String = when (days) {
        0L -> text("Today: $title", "आज $title")
        1L -> text("$title tomorrow", "भोलि $title")
        else -> text("$title in ${number(days.toInt())} days", "$title ${number(days.toInt())} दिनमा")
    }

    /** Tithi 1–30 as "कृष्ण पञ्चमी" / "Krishna Panchami"; full and new moon stand alone. */
    fun tithi(number: Int): String = when (number) {
        15 -> text("Purnima", "पूर्णिमा")
        30 -> text("Aunsi", "औंसी")
        else -> {
            val paksha = if (number < 15) text("Shukla", "शुक्ल") else text("Krishna", "कृष्ण")
            "$paksha ${(if (isNepali) TITHIS_NE else TITHIS_EN)[(number - 1) % 15]}"
        }
    }

    private companion object {
        const val DEVANAGARI_ZERO = '०'
        val MONTHS_NE = listOf("बैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज", "कात्तिक", "मंसिर", "पुस", "माघ", "फागुन", "चैत")
        val MONTHS_EN = listOf("Baisakh", "Jestha", "Asar", "Shrawan", "Bhadra", "Ashwin", "Kartik", "Mangsir", "Poush", "Magh", "Falgun", "Chaitra")
        val WEEKDAYS_SHORT_NE = listOf("आइत", "सोम", "मंगल", "बुध", "बिहि", "शुक्र", "शनि")
        val SEASONS_NE = listOf("बसन्त ऋतु", "ग्रीष्म ऋतु", "वर्षा ऋतु", "शरद ऋतु", "हेमन्त ऋतु", "शिशिर ऋतु")
        val SEASONS_EN = listOf("Spring", "Summer", "Monsoon", "Autumn", "Early winter", "Winter")
        val TITHIS_NE = listOf(
            "प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पञ्चमी", "षष्ठी", "सप्तमी",
            "अष्टमी", "नवमी", "दशमी", "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी",
        )
        val TITHIS_EN = listOf(
            "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami", "Shashthi", "Saptami",
            "Ashtami", "Navami", "Dashami", "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi",
        )
        val WEEKDAYS_FULL_NE = listOf("आइतबार", "सोमबार", "मंगलबार", "बुधबार", "बिहीबार", "शुक्रबार", "शनिबार")
        val WEEKDAYS_SHORT_EN = listOf("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
        val WEEKDAYS_FULL_EN = listOf("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
        val AD_MONTHS_NE = listOf("जनवरी", "फेब्रुअरी", "मार्च", "अप्रिल", "मे", "जुन", "जुलाई", "अगस्ट", "सेप्टेम्बर", "अक्टोबर", "नोभेम्बर", "डिसेम्बर")
        val AD_MONTHS_EN = listOf("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
    }
}

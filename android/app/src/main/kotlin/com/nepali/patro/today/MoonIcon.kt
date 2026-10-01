package com.nepali.patro.today

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import androidx.core.graphics.createBitmap
import kotlin.math.abs
import kotlin.math.cos

/** Draws the moon's phase for a tithi (1–30): waxing in shukla, waning in krishna. */
object MoonIcon {
    private const val SIZE_PX = 144
    private const val DARK = 0xFF44403C.toInt()
    private const val LIGHT = 0xFFF3E2B3.toInt()

    fun create(tithi: Int): Bitmap {
        val bitmap = createBitmap(SIZE_PX, SIZE_PX)
        val canvas = Canvas(bitmap)
        val r = SIZE_PX / 2f - 2
        val c = SIZE_PX / 2f
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        paint.color = DARK
        canvas.drawCircle(c, c, r, paint)

        // Phase angle: 0° new moon (aunsi), 180° full moon (purnima).
        val phase = Math.toRadians(tithi * 12.0)
        val waxing = tithi < 15
        val terminator = (r * abs(cos(phase))).toFloat()
        val disc = RectF(c - r, c - r, c + r, c + r)
        val lit = Path().apply {
            // The lit half: right side while waxing, left while waning.
            addArc(disc, if (waxing) -90f else 90f, 180f)
        }
        paint.color = LIGHT
        if (tithi == 30) return bitmap
        if (tithi == 15) {
            canvas.drawCircle(c, c, r, paint)
            return bitmap
        }
        canvas.drawPath(lit, paint)
        // Crescent: darken part of the lit half; gibbous: light part of the dark half.
        val crescent = cos(phase) > 0
        paint.color = if (crescent) DARK else LIGHT
        canvas.drawOval(RectF(c - terminator, c - r, c + terminator, c + r), paint)
        return bitmap
    }
}

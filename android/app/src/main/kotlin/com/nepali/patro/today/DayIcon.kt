package com.nepali.patro.today

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.Typeface
import androidx.core.graphics.createBitmap
import androidx.core.graphics.drawable.IconCompat

/**
 * Status-bar icon showing a day number, e.g. "१५". The system tints small
 * icons, so it's drawn white on transparent and only the alpha matters.
 */
object DayIcon {
    private const val SIZE_PX = 96

    fun create(text: String): IconCompat = IconCompat.createWithBitmap(draw(text))

    private fun draw(text: String): Bitmap {
        val bitmap = createBitmap(SIZE_PX, SIZE_PX)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            typeface = Typeface.DEFAULT_BOLD
            textAlign = Paint.Align.CENTER
            textSize = SIZE_PX.toFloat()
        }
        // Shrink until the glyphs fit; Devanagari digits are taller than Latin ones.
        val bounds = Rect()
        paint.getTextBounds(text, 0, text.length, bounds)
        val scale = minOf(SIZE_PX * 0.96f / bounds.width(), SIZE_PX * 0.86f / bounds.height())
        paint.textSize *= scale
        paint.getTextBounds(text, 0, text.length, bounds)
        Canvas(bitmap).drawText(text, SIZE_PX / 2f, SIZE_PX / 2f - bounds.exactCenterY(), paint)
        return bitmap
    }
}

package com.nepali.patro.widget

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.Shader
import android.util.LruCache
import androidx.core.graphics.createBitmap
import java.io.IOException

/**
 * The season photo the app shows in its header, cropped for a widget and
 * darkened towards maroon so white text stays readable. The JPEGs are the
 * Flutter assets already in the APK (assets/seasons/).
 */
internal object SeasonPhoto {
    private val SEASONS = listOf("basanta", "grishma", "barsha", "sharad", "hemanta", "shishir")
    private val cache = LruCache<String, Bitmap>(4)

    /** [override] (a season name from the app's "Preview season") wins over [bsMonth]. */
    fun load(context: Context, bsMonth: Int, width: Int, height: Int, override: String? = null): Bitmap? {
        val season = override?.takeIf { it in SEASONS } ?: SEASONS[(bsMonth % 12) / 2]
        val key = "$season-$width-$height"
        cache.get(key)?.let { return it }
        val source = try {
            context.assets.open("flutter_assets/assets/seasons/$season.jpg").use(BitmapFactory::decodeStream)
        } catch (_: IOException) {
            null
        } ?: return null

        // Centre-crop to the requested aspect ratio.
        val targetRatio = width.toFloat() / height
        val crop = if (source.width.toFloat() / source.height > targetRatio) {
            val w = (source.height * targetRatio).toInt()
            Rect((source.width - w) / 2, 0, (source.width + w) / 2, source.height)
        } else {
            val h = (source.width / targetRatio).toInt()
            Rect(0, (source.height - h) / 2, source.width, (source.height + h) / 2)
        }
        val out = createBitmap(width, height)
        val canvas = Canvas(out)
        canvas.drawBitmap(source, crop, Rect(0, 0, width, height), Paint(Paint.FILTER_BITMAP_FLAG))
        source.recycle()
        canvas.drawPaint(Paint().apply {
            shader = LinearGradient(
                0f, 0f, 0f, height.toFloat(),
                intArrayOf(0x8C1A0606.toInt(), 0x8C3A0E0E.toInt(), 0xD93A0E0E.toInt()),
                floatArrayOf(0f, 0.45f, 1f),
                Shader.TileMode.CLAMP,
            )
        })
        cache.put(key, out)
        return out
    }
}

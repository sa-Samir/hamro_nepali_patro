package com.nepali.patro.today

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.nepali.patro.MainActivity

/** Opens (or brings to front) the app the same way the launcher icon does. */
fun Context.openAppPendingIntent(): PendingIntent {
    val intent = Intent(this, MainActivity::class.java)
        .setAction(Intent.ACTION_MAIN)
        .addCategory(Intent.CATEGORY_LAUNCHER)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
    return PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
}

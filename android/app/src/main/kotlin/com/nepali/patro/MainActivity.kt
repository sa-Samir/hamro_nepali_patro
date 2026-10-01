package com.nepali.patro

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import com.nepali.patro.today.TodayRefresher
import com.nepali.patro.widget.AgendaWidgetProvider
import com.nepali.patro.widget.DeskWidgetProvider
import com.nepali.patro.widget.MonthWidgetProvider
import com.nepali.patro.widget.TodayWidgetProvider
import com.nepali.patro.widget.WeekWidgetProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "refreshAll" -> {
                    TodayRefresher.refreshAll(applicationContext)
                    result.success(null)
                }
                "requestPinWidget" -> result.success(requestPinWidget(call.argument<String>("kind")))
                else -> result.notImplemented()
            }
        }
    }

    private fun requestPinWidget(kind: String?): Boolean {
        val provider = when (kind) {
            "today" -> TodayWidgetProvider::class.java
            "desk" -> DeskWidgetProvider::class.java
            "agenda" -> AgendaWidgetProvider::class.java
            "week" -> WeekWidgetProvider::class.java
            "month" -> MonthWidgetProvider::class.java
            else -> return false
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val manager = AppWidgetManager.getInstance(this)
        return manager.isRequestPinAppWidgetSupported &&
            manager.requestPinAppWidget(ComponentName(this, provider), null, null)
    }

    private companion object {
        const val CHANNEL = "com.nepali.patro/native"
    }
}

package com.khotwaty.khotwaty.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.khotwaty.khotwaty.MainActivity
import com.khotwaty.khotwaty.R
import com.khotwaty.khotwaty.tracking.StepTrackingService
import java.util.Locale

class StepWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        updateAll(context)
    }

    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, StepWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            val data = StepTrackingService.snapshot(context)
            val steps = data["steps"] as Int
            val distance = data["distanceKm"] as Double
            val calories = data["calories"] as Double
            ids.forEach { id ->
                val views = RemoteViews(context.packageName, R.layout.widget_steps)
                views.setTextViewText(R.id.widget_steps, String.format(Locale.US, "%,d", steps))
                views.setTextViewText(R.id.widget_distance, String.format(Locale.US, "%.2f كم", distance))
                views.setTextViewText(R.id.widget_calories, String.format(Locale.US, "%.0f كالوري", calories))
                val launch = PendingIntent.getActivity(
                    context, 0, Intent(context, MainActivity::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT or if (android.os.Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0
                )
                views.setOnClickPendingIntent(R.id.widget_root, launch)
                manager.updateAppWidget(id, views)
            }
        }
    }
}

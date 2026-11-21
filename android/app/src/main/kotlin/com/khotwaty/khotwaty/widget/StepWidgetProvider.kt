package com.khotwaty.khotwaty.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews
import com.khotwaty.khotwaty.R
import com.khotwaty.khotwaty.tracking.StepTrackingService

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
                views.setTextViewText(R.id.widget_steps, String.format("%,d", steps))
                views.setTextViewText(R.id.widget_distance, String.format(Locale.US, "%.2f كم", distance))
                views.setTextViewText(R.id.widget_calories, String.format(Locale.US, "%.0f كالوري", calories))
                manager.updateAppWidget(id, views)
            }
        }
    }
}

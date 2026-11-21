package com.khotwaty.khotwaty.tracking

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_BOOT_COMPLETED) return
        val prefs = context.getSharedPreferences(StepTrackingService.PREFS, Context.MODE_PRIVATE)
        if (prefs.getBoolean("trackingEnabled", false)) {
            val service = Intent(context, StepTrackingService::class.java)
                .setAction(StepTrackingService.ACTION_START)
            ContextCompat.startForegroundService(context, service)
        }
    }
}

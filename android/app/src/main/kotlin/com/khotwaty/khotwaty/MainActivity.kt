package com.khotwaty.khotwaty

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.khotwaty.khotwaty.tracking.StepTrackingService

class MainActivity : FlutterActivity() {
    private val channelName = "com.khotwaty/tracker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSensorAvailable" -> result.success(hasStepSensor())
                    "requiresActivityPermission" -> result.success(Build.VERSION.SDK_INT >= 29)
                    "startTracking" -> {
                        if (Build.VERSION.SDK_INT >= 29 &&
                            ContextCompat.checkSelfPermission(this, Manifest.permission.ACTIVITY_RECOGNITION) != PackageManager.PERMISSION_GRANTED) {
                            result.success(false)
                        } else if (!hasStepSensor()) {
                            result.success(false)
                        } else {
                            val intent = Intent(this, StepTrackingService::class.java).setAction(StepTrackingService.ACTION_START)
                            ContextCompat.startForegroundService(this, intent)
                            result.success(true)
                        }
                    }
                    "stopTracking" -> {
                        val intent = Intent(this, StepTrackingService::class.java).setAction(StepTrackingService.ACTION_STOP)
                        startService(intent)
                        result.success(null)
                    }
                    "getSnapshot" -> result.success(StepTrackingService.snapshot(this))
                    "saveProfile" -> {
                        val prefs = getSharedPreferences(StepTrackingService.PREFS, Context.MODE_PRIVATE)
                        prefs.edit()
                            .putFloat("heightCm", (call.argument<Double>("heightCm") ?: 170.0).toFloat())
                            .putFloat("weightKg", (call.argument<Double>("weightKg") ?: 70.0).toFloat())
                            .apply()
                        StepTrackingService.refreshWidget(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasStepSensor(): Boolean {
        val manager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        return manager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) != null
    }
}

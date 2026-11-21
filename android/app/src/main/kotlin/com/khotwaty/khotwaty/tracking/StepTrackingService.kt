package com.khotwaty.khotwaty.tracking

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.khotwaty.khotwaty.MainActivity
import com.khotwaty.khotwaty.R
import com.khotwaty.khotwaty.widget.StepWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class StepTrackingService : Service(), SensorEventListener {
    companion object {
        const val ACTION_START = "com.khotwaty.action.START"
        const val ACTION_STOP = "com.khotwaty.action.STOP"
        const val PREFS = "KhotwatyTracker"
        private const val CHANNEL_ID = "khotwaty_tracking"
        private const val NOTIFICATION_ID = 4101
        private const val HISTORY_LIMIT = 365

        fun snapshot(context: Context): Map<String, Any> {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val date = today()
            val steps = if (prefs.getString("activeDate", date) == date) prefs.getInt("todaySteps", 0) else 0
            val height = prefs.getFloat("heightCm", 170f).toDouble()
            val weight = prefs.getFloat("weightKg", 70f).toDouble()
            val distance = steps * (height * 0.415 / 100.0) / 1000.0
            val calories = distance * weight * 0.5
            val history = JSONArray(prefs.getString("history", "[]") ?: "[]")
            val records = mutableListOf<Map<String, Any>>()
            var hasToday = false
            for (i in 0 until history.length()) {
                val item = history.optJSONObject(i) ?: continue
                if (item.optString("date") == date) hasToday = true
                records.add(mapOf(
                    "date" to item.optString("date"),
                    "steps" to item.optInt("steps"),
                    "distanceKm" to item.optDouble("distanceKm"),
                    "calories" to item.optDouble("calories")
                ))
            }
            if (!hasToday) {
                records.add(mapOf(
                    "date" to date, "steps" to steps,
                    "distanceKm" to distance, "calories" to calories
                ))
            }
            val sensor = (context.getSystemService(Context.SENSOR_SERVICE) as SensorManager)
                .getDefaultSensor(Sensor.TYPE_STEP_COUNTER) != null
            return mapOf(
                "today" to date, "steps" to steps, "distanceKm" to distance,
                "calories" to calories, "isTracking" to prefs.getBoolean("trackingEnabled", false),
                "sensorAvailable" to sensor, "history" to records
            )
        }

        fun refreshWidget(context: Context) {
            StepWidgetProvider.updateAll(context)
        }

        private fun today(): String = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
    }

    private lateinit var sensorManager: SensorManager
    private var stepSensor: Sensor? = null
    private var lastSensorValue = -1f
    private var currentDate = ""
    private val prefs by lazy { getSharedPreferences(PREFS, Context.MODE_PRIVATE) }

    override fun onCreate() {
        super.onCreate()
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopTracking()
                return START_NOT_STICKY
            }
            else -> startTracking()
        }
        return START_STICKY
    }

    private fun startTracking() {
        if (stepSensor == null) {
            prefs.edit().putBoolean("trackingEnabled", false).apply()
            stopSelf()
            return
        }
        startForeground(NOTIFICATION_ID, buildNotification())
        prefs.edit().putBoolean("trackingEnabled", true).apply()
        currentDate = prefs.getString("activeDate", today()) ?: today()
        lastSensorValue = prefs.getFloat("lastSensorValue", -1f)
        sensorManager.unregisterListener(this)
        sensorManager.registerListener(this, stepSensor, SensorManager.SENSOR_DELAY_NORMAL)
        refreshNotificationAndWidget()
    }

    private fun stopTracking() {
        sensorManager.unregisterListener(this)
        prefs.edit().putBoolean("trackingEnabled", false).apply()
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NOTIFICATION_ID)
        stopForeground(STOP_FOREGROUND_REMOVE)
        refreshWidget(this)
        stopSelf()
    }

    override fun onSensorChanged(event: SensorEvent?) {
        val total = event?.values?.firstOrNull() ?: return
        val date = today()
        val editor = prefs.edit()
        if (currentDate != date) {
            currentDate = date
            lastSensorValue = total
            editor.putString("activeDate", date).putInt("todaySteps", 0)
        } else if (lastSensorValue < 0f) {
            lastSensorValue = total
            editor.putString("activeDate", date)
        } else if (total >= lastSensorValue) {
            val delta = (total - lastSensorValue).toInt()
            if (delta > 0) editor.putInt("todaySteps", prefs.getInt("todaySteps", 0) + delta)
            lastSensorValue = total
        } else {
            lastSensorValue = total
        }
        editor.putFloat("lastSensorValue", lastSensorValue).apply()
        saveTodayToHistory()
        refreshNotificationAndWidget()
    }

    private fun saveTodayToHistory() {
        val steps = prefs.getInt("todaySteps", 0)
        val height = prefs.getFloat("heightCm", 170f).toDouble()
        val weight = prefs.getFloat("weightKg", 70f).toDouble()
        val distance = steps * (height * 0.415 / 100.0) / 1000.0
        val calories = distance * weight * 0.5
        val old = JSONArray(prefs.getString("history", "[]") ?: "[]")
        val updated = JSONArray()
        var replaced = false
        for (i in 0 until old.length()) {
            val item = old.optJSONObject(i) ?: continue
            if (item.optString("date") == today()) {
                updated.put(recordJson(steps, distance, calories))
                replaced = true
            } else {
                updated.put(item)
            }
        }
        if (!replaced) updated.put(recordJson(steps, distance, calories))
        val trimmed = JSONArray()
        val start = (updated.length() - HISTORY_LIMIT).coerceAtLeast(0)
        for (i in start until updated.length()) trimmed.put(updated.get(i))
        prefs.edit().putString("history", trimmed.toString()).apply()
    }

    private fun recordJson(steps: Int, distance: Double, calories: Double) = JSONObject()
        .put("date", today()).put("steps", steps)
        .put("distanceKm", distance).put("calories", calories)

    private fun refreshNotificationAndWidget() {
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, buildNotification())
        val steps = prefs.getInt("todaySteps", 0)
        listOf(5000, 10000, 15000, 20000).forEach { milestone ->
            val key = "milestone_${today()}_$milestone"
            if (steps >= milestone && !prefs.getBoolean(key, false)) {
                val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                    .setSmallIcon(R.drawable.ic_stat_walk)
                    .setContentTitle("إنجاز جديد من خُطوتي!")
                    .setContentText("مبروك! وصلت إلى $milestone خطوة النهارده.")
                    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                    .setAutoCancel(true)
                    .build()
                manager.notify(milestone, notification)
                prefs.edit().putBoolean(key, true).apply()
            }
        }
        refreshWidget(this)
    }

    private fun buildNotification(): Notification {
        val steps = prefs.getInt("todaySteps", 0)
        val openApp = PendingIntent.getActivity(
            this, 0, Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_walk)
            .setContentTitle("خُطوتي • التتبع يعمل")
            .setContentText("$steps خطوة مسجلة اليوم")
            .setContentIntent(openApp)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "تتبع الخطوات", NotificationManager.IMPORTANCE_LOW
            ).apply { description = "إشعار دائم أثناء تسجيل خطواتك" }
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        super.onDestroy()
    }
}

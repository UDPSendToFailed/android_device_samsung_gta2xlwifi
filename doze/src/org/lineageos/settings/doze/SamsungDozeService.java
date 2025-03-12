/*
 * Copyright (c) 2015 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings.doze;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.PowerManager;
import android.os.SystemClock;
import android.os.UserHandle;
import android.util.Log;

import static java.lang.Math.sqrt;

public class SamsungDozeService extends Service {
    private static final String TAG = "SamsungDozeService";
    private static final boolean DEBUG = false;

    private static final String DOZE_INTENT = "com.android.systemui.doze.pulse";
    private static final int MIN_PULSE_INTERVAL_MS = 5000;

    private Context mContext;
    private AccelerometerPickUpSensor mPickUpSensor;
    private PowerManager mPowerManager;
    /**
     * Inner class for handling accelerometer-based pickup detection.
     * Sensor events are delivered on a dedicated HandlerThread.
     */
    class AccelerometerPickUpSensor implements SensorEventListener {
        private SensorManager mSensorManager;
        private Sensor mSensor;
        private HandlerThread mHandlerThread;
        private Handler mHandler;

        private long lastPulseTimestamp;
        private float lastMagnitude = 0f;
        private float lastZValue = 0f;

        private float pickupThresholdMagnitude = 9.8f;
        private float pickupThresholdChange = 1.0f;
        private float zAxisPickupThresholdChange = -2.5f;
        private float zAxisMinimumMagnitude = 2.0f;

        public AccelerometerPickUpSensor(Context context) {
            mSensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
            mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
            if (mSensor == null) {
                Log.e(TAG, "Accelerometer sensor not available");
            }
            mHandlerThread = new HandlerThread("AccelSensorThread");
            mHandlerThread.start();
            mHandler = new Handler(mHandlerThread.getLooper());
        }

        /**
         * Enables sensor monitoring.
         * Registers this as a listener on a dedicated HandlerThread.
         */
        protected void enable() {
            lastPulseTimestamp = SystemClock.elapsedRealtime();
            mSensorManager.registerListener(this, mSensor, SensorManager.SENSOR_DELAY_NORMAL, mHandler);
            Log.d(TAG, "Accelerometer Pickup Sensor Enabled");
        }

        /**
         * Disables sensor monitoring.
         * Unregisters this listener and stops the HandlerThread.
         */
        protected void disable() {
            mSensorManager.unregisterListener(this, mSensor);
            Log.d(TAG, "Accelerometer Pickup Sensor Disabled");
        }

        /**
         * Shuts down the sensor thread to clean up resources.
         */
        protected void shutdown() {
            if (mHandlerThread != null) {
                mHandlerThread.quitSafely();
                mHandlerThread = null;
            }
        }

        @Override
        public void onSensorChanged(SensorEvent event) {
            if (DEBUG) {
                Log.d(TAG, "Accelerometer event: x=" + event.values[0] +
                        ", y=" + event.values[1] + ", z=" + event.values[2]);
            }

            long currentTime = SystemClock.elapsedRealtime();

            if (currentTime - lastPulseTimestamp < MIN_PULSE_INTERVAL_MS) {
                return;
            }

            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];

            float magnitude = (float) sqrt(x * x + y * y + z * z);
            float accelerationChange = magnitude - lastMagnitude;
            lastMagnitude = magnitude;

            float zChange = z - lastZValue;
            lastZValue = z;

            if (DEBUG) {
                Log.d(TAG, "Magnitude: " + magnitude + ", Change: " + accelerationChange +
                        ", Z-Change: " + zChange + ", Z-Value: " + z);
            }

            if (isPickupDetected(magnitude, accelerationChange, zChange, z)) {
                if (DEBUG) { Log.d(TAG, "Pickup Detected - WAKE UP"); }
                lastPulseTimestamp = SystemClock.elapsedRealtime();
                wakeOrLaunchDozePulse();
                }
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {}

        /**
         * Determines if the pickup gesture is detected based on sensor data.
         */
        private boolean isPickupDetected(float magnitude, float accelerationChange, float zChange, float zValue) {
            return (magnitude > pickupThresholdMagnitude && accelerationChange > pickupThresholdChange) ||
                   (zChange < zAxisPickupThresholdChange && zValue > zAxisMinimumMagnitude);
        }
    }

    @Override
    public void onCreate() {
        if (DEBUG) Log.d(TAG, "SamsungDozeService onCreate");
        mContext = this;
        mPowerManager = (PowerManager) mContext.getSystemService(Context.POWER_SERVICE);
        mPickUpSensor = new AccelerometerPickUpSensor(mContext);
        if (!isInteractive()) {
            mPickUpSensor.enable();
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (DEBUG) Log.d(TAG, "Starting service");
        IntentFilter screenStateFilter = new IntentFilter(Intent.ACTION_SCREEN_ON);
        screenStateFilter.addAction(Intent.ACTION_SCREEN_OFF);
        mContext.registerReceiver(mScreenStateReceiver, screenStateFilter);
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        if (DEBUG) Log.d(TAG, "SamsungDozeService onDestroy");
        mContext.unregisterReceiver(mScreenStateReceiver);
        mPickUpSensor.disable();
        mPickUpSensor.shutdown();
        super.onDestroy();
    }

    private void wakeOrLaunchDozePulse() {
        if (Utils.isWakeOnGestureEnabled(mContext)) {
            if (DEBUG) Log.d(TAG, "Wake up display");
            try{
                mPowerManager.wakeUp(SystemClock.uptimeMillis(), PowerManager.WAKE_REASON_GESTURE, TAG);
            } catch (Exception e) {
                Log.e(TAG, "Error waking up display", e);
            }
        } else {
            if (DEBUG) Log.d(TAG, "Launch doze pulse");
            mContext.sendBroadcastAsUser(new Intent(DOZE_INTENT), new UserHandle(UserHandle.USER_CURRENT));
        }
    }

    private boolean isInteractive() {
        return mPowerManager.isInteractive();
    }

    private void onDisplayOn() {
        if (DEBUG) Log.d(TAG, "Display on");
        if (Utils.isPickUpGestureEnabled(this)) {
            mPickUpSensor.disable();
        }
    }

    private void onDisplayOff() {
        if (DEBUG) Log.d(TAG, "Display off");
        if (Utils.isPickUpGestureEnabled(this)) {
            mPickUpSensor.enable();
        }
    }

    private final BroadcastReceiver mScreenStateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (Intent.ACTION_SCREEN_OFF.equals(intent.getAction())) {
                onDisplayOff();
            } else if (Intent.ACTION_SCREEN_ON.equals(intent.getAction())) {
                onDisplayOn();
            }
        }
    };
}
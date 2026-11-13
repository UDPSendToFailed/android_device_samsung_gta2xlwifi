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

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

import static java.lang.Math.sqrt;

public class SamsungDozeService extends Service {
    private static final String TAG = "SamsungDozeService";
    private static final boolean DEBUG = false;

    private static final String DOZE_INTENT = "com.android.systemui.doze.pulse";
    private static final int MIN_PULSE_INTERVAL_MS = 5000;

    private static final String SAR_SENSOR_ENABLE_PATH = "/sys/class/input/input6/enable";

    private Context mContext;
    private AccelerometerPickUpSensor mPickUpSensor;
    private PowerManager mPowerManager;
    private boolean mScreenReceiverRegistered = false;

    /**
     * Inner class for handling accelerometer-based pickup detection.
     * Sensor events are delivered on a dedicated HandlerThread.
     */
    class AccelerometerPickUpSensor implements SensorEventListener {
        private static final float PICKUP_THRESHOLD_MAGNITUDE = 9.8f;
        private static final float PICKUP_THRESHOLD_CHANGE = 1.0f;
        private static final float Z_AXIS_PICKUP_THRESHOLD_CHANGE = -2.5f;
        private static final float Z_AXIS_MINIMUM_MAGNITUDE = 2.0f;

        private final SensorManager mSensorManager;
        private final Sensor mSensor;
        private HandlerThread mHandlerThread;
        private Handler mHandler;

        private boolean mRegistered = false;
        private boolean mHasBaseline = false;
        private long mLastPulseTimestamp;
        private float mLastMagnitude = 0f;
        private float mLastZValue = 0f;

        public AccelerometerPickUpSensor(Context context) {
            mSensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
            mSensor = mSensorManager != null
                    ? mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
                    : null;
            if (mSensor == null) {
                Log.e(TAG, "Accelerometer sensor not available");
            } else {
                mHandlerThread = new HandlerThread("AccelSensorThread");
                mHandlerThread.start();
                mHandler = new Handler(mHandlerThread.getLooper());
            }
        }

        /**
         * Enables sensor monitoring on a dedicated HandlerThread.
         */
        protected synchronized void enable() {
            if (mSensorManager == null || mSensor == null || mHandler == null) {
                Log.w(TAG, "Cannot enable Accelerometer: Sensor or Handler not initialized.");
                return;
            }
            if (mRegistered) {
                return;
            }
            mHasBaseline = false;
            mLastPulseTimestamp = SystemClock.elapsedRealtime();
            mRegistered = mSensorManager.registerListener(
                    this, mSensor, SensorManager.SENSOR_DELAY_NORMAL, mHandler);
            if (DEBUG) Log.d(TAG, "Accelerometer Pickup Sensor Enabled: " + mRegistered);
        }

        /**
         * Disables sensor monitoring.
         */
        protected synchronized void disable() {
            if (mSensorManager == null || mSensor == null || !mRegistered) {
                return;
            }
            try {
                mSensorManager.unregisterListener(this, mSensor);
                if (DEBUG) Log.d(TAG, "Accelerometer Pickup Sensor Disabled");
            } catch (Exception e) {
                Log.w(TAG, "Error unregistering accelerometer listener", e);
            } finally {
                mRegistered = false;
                mHasBaseline = false;
            }
        }

        /**
         * Shuts down the sensor thread to clean up resources.
         */
        protected void shutdown() {
            disable();
            if (mHandlerThread != null) {
                mHandlerThread.quitSafely();
                mHandlerThread = null;
                mHandler = null;
            }
        }

        @Override
        public void onSensorChanged(SensorEvent event) {
            if (DEBUG) {
                Log.d(TAG, "Accelerometer event: x=" + event.values[0]
                        + ", y=" + event.values[1] + ", z=" + event.values[2]);
            }

            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];
            float magnitude = (float) sqrt(x * x + y * y + z * z);

            if (!mHasBaseline) {
                mLastMagnitude = magnitude;
                mLastZValue = z;
                mHasBaseline = true;
                return;
            }

            float accelerationChange = magnitude - mLastMagnitude;
            mLastMagnitude = magnitude;

            float zChange = z - mLastZValue;
            mLastZValue = z;

            long currentTime = SystemClock.elapsedRealtime();
            if (currentTime - mLastPulseTimestamp < MIN_PULSE_INTERVAL_MS) {
                return;
            }

            if (DEBUG) {
                Log.d(TAG, "Magnitude: " + magnitude + ", Change: " + accelerationChange
                        + ", Z-Change: " + zChange + ", Z-Value: " + z);
            }

            if (isPickupDetected(magnitude, accelerationChange, zChange, z)) {
                if (DEBUG) Log.d(TAG, "Pickup Detected - WAKE UP");
                mLastPulseTimestamp = currentTime;
                wakeOrLaunchDozePulse();
            }
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {}

        /**
         * Determines if the pickup gesture is detected based on sensor data.
         */
        private boolean isPickupDetected(
                float magnitude, float accelerationChange, float zChange, float zValue) {
            return (magnitude > PICKUP_THRESHOLD_MAGNITUDE
                            && accelerationChange > PICKUP_THRESHOLD_CHANGE)
                    || (zChange < Z_AXIS_PICKUP_THRESHOLD_CHANGE
                            && zValue > Z_AXIS_MINIMUM_MAGNITUDE);
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        if (DEBUG) Log.d(TAG, "SamsungDozeService onCreate");
        mContext = this;
        mPowerManager = (PowerManager) mContext.getSystemService(Context.POWER_SERVICE);
        mPickUpSensor = new AccelerometerPickUpSensor(mContext);

        IntentFilter screenStateFilter = new IntentFilter(Intent.ACTION_SCREEN_ON);
        screenStateFilter.addAction(Intent.ACTION_SCREEN_OFF);
        mContext.registerReceiver(mScreenStateReceiver, screenStateFilter, RECEIVER_NOT_EXPORTED);
        mScreenReceiverRegistered = true;

        boolean pickupEnabled = Utils.isPickUpGestureEnabled(this);
        boolean sensorsShouldBeActive = !isInteractive()
                && Utils.isDozeEnabled(this)
                && pickupEnabled;

        if (DEBUG) {
            Log.d(TAG, "onCreate: isInteractive=" + isInteractive()
                    + ", isDozeEnabled=" + Utils.isDozeEnabled(this)
                    + ", isPickupEnabled=" + pickupEnabled
                    + ", sensorsShouldBeActive=" + sensorsShouldBeActive);
        }

        if (sensorsShouldBeActive) {
            setSarSensorEnabled(true);
            mPickUpSensor.enable();
        } else {
            setSarSensorEnabled(false);
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (DEBUG) Log.d(TAG, "Starting service");
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        if (DEBUG) Log.d(TAG, "SamsungDozeService onDestroy");
        if (mScreenReceiverRegistered) {
            try {
                mContext.unregisterReceiver(mScreenStateReceiver);
            } catch (IllegalArgumentException e) {
                Log.w(TAG, "Receiver already unregistered", e);
            }
            mScreenReceiverRegistered = false;
        }
        setSarSensorEnabled(false);
        mPickUpSensor.shutdown();
        super.onDestroy();
    }

    private void wakeOrLaunchDozePulse() {
        if (Utils.isWakeOnGestureEnabled(mContext)) {
            if (DEBUG) Log.d(TAG, "Wake up display");
            if (mPowerManager != null) {
                try {
                    mPowerManager.wakeUp(
                            SystemClock.uptimeMillis(), PowerManager.WAKE_REASON_GESTURE, TAG);
                } catch (Exception e) {
                    Log.e(TAG, "Error waking up display", e);
                }
            } else {
                Log.w(TAG, "PowerManager not available, cannot wake up display.");
            }
        } else {
            if (DEBUG) Log.d(TAG, "Launch doze pulse");
            Intent intent = new Intent(DOZE_INTENT);
            mContext.sendBroadcastAsUser(intent, UserHandle.CURRENT);
        }
    }

    private boolean isInteractive() {
        return mPowerManager != null && mPowerManager.isInteractive();
    }

    private void onDisplayOn() {
        if (DEBUG) Log.d(TAG, "Display on");
        setSarSensorEnabled(false);
        mPickUpSensor.disable();
    }

    private void onDisplayOff() {
        if (DEBUG) Log.d(TAG, "Display off");

        boolean pickupEnabled = Utils.isPickUpGestureEnabled(this);
        boolean sensorsShouldBeActive = Utils.isDozeEnabled(this) && pickupEnabled;

        if (DEBUG) {
            Log.d(TAG, "onDisplayOff: isDozeEnabled=" + Utils.isDozeEnabled(this)
                    + ", isPickupEnabled=" + pickupEnabled
                    + ", sensorsShouldBeActive=" + sensorsShouldBeActive);
        }

        if (sensorsShouldBeActive) {
            setSarSensorEnabled(true);
            mPickUpSensor.enable();
        } else {
            setSarSensorEnabled(false);
            mPickUpSensor.disable();
        }
    }

    private final BroadcastReceiver mScreenStateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent == null || intent.getAction() == null) {
                return;
            }
            String action = intent.getAction();
            if (Intent.ACTION_SCREEN_OFF.equals(action)) {
                onDisplayOff();
            } else if (Intent.ACTION_SCREEN_ON.equals(action)) {
                onDisplayOn();
            }
        }
    };

    private void setSarSensorEnabled(boolean enable) {
        String value = enable ? "1" : "0";
        try (FileOutputStream fos = new FileOutputStream(SAR_SENSOR_ENABLE_PATH)) {
            fos.write(value.getBytes(StandardCharsets.UTF_8));
            fos.flush();
            if (DEBUG) Log.d(TAG, "Successfully wrote '" + value + "' to " + SAR_SENSOR_ENABLE_PATH);
        } catch (IOException | SecurityException e) {
            Log.e(TAG, "Exception writing '" + value + "' to SAR sysfs node: " + SAR_SENSOR_ENABLE_PATH, e);
        }
    }
}
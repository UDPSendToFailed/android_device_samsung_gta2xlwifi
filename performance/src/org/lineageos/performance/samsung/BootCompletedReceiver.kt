/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.performance.samsung

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemProperties
import androidx.preference.PreferenceManager

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs = PreferenceManager.getDefaultSharedPreferences(context)
            if (prefs.getBoolean("perf_apply_on_boot", false)) {
                SystemProperties.set(PROP_CPU_GOV, if (prefs.getBoolean("perf_cpu", false)) "true" else "false")
                SystemProperties.set(PROP_GPU_GOV, if (prefs.getBoolean("perf_gpu", false)) "true" else "false")
                
                // Only restore OC if advanced menu was unlocked in preferences
                if (prefs.getBoolean("perf_advanced_unlocked", false)) {
                    SystemProperties.set(PROP_GPU_OC, prefs.getString("perf_gpu_oc", "650"))
                }
            } else {
                // If not applied on boot, reset the UI properties so the service goes back to default
                prefs.edit()
                    .putBoolean("perf_cpu", false)
                    .putBoolean("perf_gpu", false)
                    .putString("perf_gpu_oc", "650")
                    .apply()
            }
            // Mark that the app has run so our "data cleared" fallback in fragment doesn't trip incorrectly
            prefs.edit().putBoolean("has_run_once", true).apply()
        }
    }

    companion object {
        private const val PROP_CPU_GOV = "vendor.perf.cpu_gov"
        private const val PROP_GPU_GOV = "vendor.perf.gpu_gov"
        private const val PROP_GPU_OC = "vendor.perf.gpu_oc"
    }
}

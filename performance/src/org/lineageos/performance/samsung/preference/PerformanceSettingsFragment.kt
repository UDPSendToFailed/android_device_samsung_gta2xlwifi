/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.performance.samsung.preference

import android.app.AlertDialog
import android.os.Bundle
import android.os.SystemProperties
import androidx.preference.ListPreference
import androidx.preference.Preference
import androidx.preference.SwitchPreferenceCompat
import com.android.settingslib.widget.SettingsBasePreferenceFragment
import org.lineageos.performance.samsung.R

class PerformanceSettingsFragment : SettingsBasePreferenceFragment(),
    Preference.OnPreferenceChangeListener {

    private lateinit var applyOnBootPref: SwitchPreferenceCompat
    private lateinit var cpuPref: SwitchPreferenceCompat
    private lateinit var gpuPref: SwitchPreferenceCompat
    private lateinit var advancedTogglePref: Preference
    private lateinit var gpuOcPref: ListPreference

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.performance_settings, rootKey)
        
        applyOnBootPref = findPreference<SwitchPreferenceCompat>("perf_apply_on_boot")!!
        cpuPref = findPreference<SwitchPreferenceCompat>("perf_cpu")!!
        gpuPref = findPreference<SwitchPreferenceCompat>("perf_gpu")!!
        advancedTogglePref = findPreference<Preference>("perf_advanced_toggle")!!
        gpuOcPref = findPreference<ListPreference>("perf_gpu_oc")!!

        val prefs = preferenceManager.sharedPreferences!!
        
        // Safety Fallback: detect data clear (has_run_once is missing)
        if (!prefs.getBoolean("has_run_once", false)) {
            // Revert properties immediately to ensure system safety without a reboot
            SystemProperties.set(PROP_CPU_GOV, "false")
            SystemProperties.set(PROP_GPU_GOV, "false")
            SystemProperties.set(PROP_GPU_OC, "650")
            prefs.edit().putBoolean("has_run_once", true).apply()
        }

        // Apply on Boot is handled natively by PreferenceManager saving the SharedPreferences,
        // we just need it to save so BootCompletedReceiver can read it.
        // For the other options, we also save them to SharedPreferences so the Receiver knows
        // what values to restore.
        
        cpuPref.onPreferenceChangeListener = this
        gpuPref.onPreferenceChangeListener = this
        gpuOcPref.onPreferenceChangeListener = this

        // Read current state from SystemProperties to reflect the actual kernel state
        cpuPref.isChecked = SystemProperties.getBoolean(PROP_CPU_GOV, false)
        gpuPref.isChecked = SystemProperties.getBoolean(PROP_GPU_GOV, false)
        
        val currentOc = SystemProperties.get(PROP_GPU_OC, "650")
        gpuOcPref.value = currentOc
        gpuOcPref.summary = "%s"
        
        // Advanced Toggle Logic (Purely UI State)
        val isAdvancedUnlocked = prefs.getBoolean("perf_advanced_unlocked", false)
        updateAdvancedVisibility(isAdvancedUnlocked)

        advancedTogglePref.setOnPreferenceClickListener {
            showAdvancedWarningDialog()
            true
        }
    }

    private fun showAdvancedWarningDialog() {
        AlertDialog.Builder(requireContext())
            .setTitle(R.string.performance_advanced_warning_title)
            .setMessage(R.string.performance_advanced_warning_message)
            .setPositiveButton(R.string.performance_advanced_warning_accept) { _, _ ->
                preferenceManager.sharedPreferences!!.edit().putBoolean("perf_advanced_unlocked", true).apply()
                updateAdvancedVisibility(true)
            }
            .setNegativeButton(R.string.performance_advanced_warning_cancel, null)
            .show()
    }

    private fun updateAdvancedVisibility(unlocked: Boolean) {
        advancedTogglePref.isVisible = !unlocked
        gpuOcPref.isVisible = unlocked
    }

    override fun onPreferenceChange(preference: Preference, newValue: Any): Boolean {
        when (preference.key) {
            "perf_cpu" -> {
                SystemProperties.set(PROP_CPU_GOV, newValue.toString())
            }
            "perf_gpu" -> {
                SystemProperties.set(PROP_GPU_GOV, newValue.toString())
            }
            "perf_gpu_oc" -> {
                SystemProperties.set(PROP_GPU_OC, newValue.toString())
                gpuOcPref.value = newValue.toString()
            }
        }
        return true
    }

    companion object {
        private const val PROP_CPU_GOV = "vendor.perf.cpu_gov"
        private const val PROP_GPU_GOV = "vendor.perf.gpu_gov"
        private const val PROP_GPU_OC = "vendor.perf.gpu_oc"
    }
}

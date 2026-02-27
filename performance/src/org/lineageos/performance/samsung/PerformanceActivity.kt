/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.performance.samsung

import android.os.Bundle
import org.lineageos.performance.samsung.preference.PerformanceSettingsFragment
import com.android.settingslib.collapsingtoolbar.CollapsingToolbarBaseActivity

class PerformanceActivity : CollapsingToolbarBaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportFragmentManager
            .beginTransaction()
            .replace(
                com.android.settingslib.collapsingtoolbar.R.id.content_frame,
                PerformanceSettingsFragment(),
            )
            .commit()
    }
}

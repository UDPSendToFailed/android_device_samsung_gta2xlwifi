/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "sensors-hal-aidl"

#include "SensorsHalAidl.h"

#include <android-base/logging.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>

using ::aidl::android::hardware::sensors::implementation::SensorsHalAidl;

int main() {
    // The original samsung service read persist.vendor.sensor.hw.binder.size
    // to configure hw binder mmap size. With AIDL binder this is no longer
    // relevant — the kernel auto-sizes the binder buffer.

    ABinderProcess_setThreadPoolMaxThreadCount(2);

    auto hal = ndk::SharedRefBase::make<SensorsHalAidl>();
    const std::string instance = std::string() + SensorsHalAidl::descriptor + "/default";

    binder_status_t status =
            AServiceManager_addService(hal->asBinder().get(), instance.c_str());
    CHECK_EQ(status, STATUS_OK) << "Failed to register " << instance;

    LOG(INFO) << "Sensors AIDL HAL service registered: " << instance;

    ABinderProcess_joinThreadPool();
    return EXIT_FAILURE;  // should not reach
}

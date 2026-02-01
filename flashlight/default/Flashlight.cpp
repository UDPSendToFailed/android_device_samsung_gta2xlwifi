/*
 * Copyright (C) 2023 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "Flashlight.h"

#include <SafeStoi.h>

#include <android-base/file.h>
#include <android-base/properties.h>

namespace aidl {
namespace vendor {
namespace samsung_ext {
namespace hardware {
namespace camera {
namespace flashlight {

using ::android::base::ReadFileToString;
using ::android::base::WriteStringToFile;

static constexpr const char* FLASH_NODE = "/sys/class/camera/flash/rear_flash";

ndk::ScopedAStatus Flashlight::getCurrentBrightness(int32_t* _aidl_return) {
    std::string value;
    int intvalue;

    ReadFileToString(FLASH_NODE, &value);
    intvalue = stoi_safe(value);
    
    if (intvalue == 0) {
        *_aidl_return = 0;
    } else if (intvalue >= 1001 && intvalue <= 1010) {
        *_aidl_return = intvalue - 1000;
    } else {
        // Unknown state - report as off
        *_aidl_return = 0;
    }
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Flashlight::setBrightness(int32_t level) {
    if (level > 10 || level < 1)
       return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    
    int writeval = 1000 + level;
    WriteStringToFile(std::to_string(writeval), FLASH_NODE);
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Flashlight::enableFlash(bool enable) {
    if (enable) {
        // For turning on, caller should use setBrightness instead
        // This is just a fallback - turn on at level 1
        WriteStringToFile("1001", FLASH_NODE);
    } else {
        WriteStringToFile("0", FLASH_NODE);
    }
    return ndk::ScopedAStatus::ok();
}

} // namespace flashlight
} // namespace camera
} // namespace hardware
} // namespace samsung_ext
} // namespace vendor
} // namespace aidl

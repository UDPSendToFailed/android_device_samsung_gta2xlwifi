#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

TARGET_DEVICE_PATH := device/xiaomi/mi89xx-mainline/mi439_mainline

# Inherit options from mainline/qcom-common
TARGET_HAS_IR := true
TARGET_QCOM_SOC := sdm439
## TODO: Bringup the corresponding hardware and remove the following definitions
TARGET_AUDIO_HAL := default-aidl
TARGET_HEALTH_HAL := cuttlefish
TARGET_SUPPORTS_SUSPEND := false
TARGET_USES_FRAMEBUFFER_DISPLAY := true
include device/mainline/qcom-common/optional/options.mk

# Inherit from parent
$(call inherit-product, device/xiaomi/mi89xx-mainline/device.mk)

# AAPT
PRODUCT_AAPT_PREF_CONFIG := xhdpi

# Boot animation
TARGET_SCREEN_HEIGHT := 1440
TARGET_SCREEN_WIDTH := 720

# Dalvik heap
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# Init
PRODUCT_PACKAGES += \
    fstab.mi439 \
    fstab.mi439.ramdisk \
    init.mi439.rc \
    init.recovery.mi439.rc \
    ueventd.mi439.rc

PRODUCT_PACKAGES += \
    use_memfd.rc

$(call soong_config_set,mainline_common_libinit,set_properties_from,devicetree)

# Kernel
PRODUCT_PACKAGES += \
    modules.load.normal

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(TARGET_DEVICE_PATH) \
    kernel/mainline/configs

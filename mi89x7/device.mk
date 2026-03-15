#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

TARGET_DEVICE_PATH := device/xiaomi/mi89xx-mainline/mi89x7

# Inherit options from mainline/qcom-common
TARGET_HAS_IR := true
TARGET_QCOM_SOC_FAMILY := msm8937
## TODO: Bringup the corresponding hardware and remove the following definitions
TARGET_LIGHT_HAL := none
TARGET_SUPPORTS_SUSPEND := false
include device/mainline/qcom-common/optional/options.mk

# Inherit from parent
$(call inherit-product, device/xiaomi/mi89xx-mainline/device.mk)

# AAPT
PRODUCT_AAPT_PREF_CONFIG := xhdpi

# Audio
PRODUCT_PACKAGES += \
    audio.mi89x7.xml \
    audio.xiaomi-riva.xml \
    audio.xiaomi-santoni.xml \
    audio.xiaomi-ugg.xml

# Boot animation
TARGET_SCREEN_HEIGHT := 1280
TARGET_SCREEN_WIDTH := 720

# Dalvik heap
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# Init
PRODUCT_PACKAGES += \
    fstab.mi89x7 \
    fstab.mi89x7.ramdisk \
    init.mi89x7.rc \
    init.recovery.mi89x7.rc \
    ueventd.mi89x7.rc

PRODUCT_PACKAGES += \
    use_memfd.rc

$(call soong_config_set,mainline_common_libinit,set_properties_from,devicetree)

# Input
PRODUCT_PACKAGES += \
    Goodix_Capacitive_TouchScreen.kl \
    ts_vkeys.kl

TARGET_TOUCHSCREEN_HAS_VIRTUAL_KEYS := true

# Kernel
PRODUCT_PACKAGES += \
    modules.load.normal

# Overlay
DEVICE_PACKAGE_OVERLAYS += \
    $(TARGET_DEVICE_PATH)/overlays/overlay

PRODUCT_PACKAGES += \
    AodDefaultOnOverlay

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(TARGET_DEVICE_PATH) \
    kernel/mainline/configs

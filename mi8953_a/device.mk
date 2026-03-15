#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

TARGET_DEVICE_PATH := device/xiaomi/mi89xx-mainline/mi8953_a

# Inherit options from mainline/qcom-common
TARGET_HAS_IR := true
TARGET_QCOM_SOC_FAMILY := msm8953
TARGET_SENSORS_HAL := iio
## TODO: Bringup the corresponding hardware and remove the following definitions
TARGET_SUPPORTS_SUSPEND := false
include device/mainline/qcom-common/optional/options.mk

# Inherit from parent
$(call inherit-product, device/xiaomi/mi89xx-mainline/device.mk)

# AAPT
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Audio
PRODUCT_PACKAGES += \
    audio.mi8953_a.xml \
    audio.xiaomi-daisy.xml \
    audio.xiaomi-mido.xml \
    audio.xiaomi-onclite.xml \
    audio.xiaomi-vince.xml

# Boot animation
TARGET_SCREEN_HEIGHT := 1920
TARGET_SCREEN_WIDTH := 1080

# Dalvik heap
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# Firmware
PRODUCT_COPY_FILES += \
    vendor/xiaomi/msm8953-common/proprietary/vendor/firmware/a506_zap.b00:$(TARGET_COPY_OUT_ODM)/firmware/qcom/msm8953/xiaomi/a506_zap.b00 \
    vendor/xiaomi/msm8953-common/proprietary/vendor/firmware/a506_zap.b01:$(TARGET_COPY_OUT_ODM)/firmware/qcom/msm8953/xiaomi/a506_zap.b01 \
    vendor/xiaomi/msm8953-common/proprietary/vendor/firmware/a506_zap.b02:$(TARGET_COPY_OUT_ODM)/firmware/qcom/msm8953/xiaomi/a506_zap.b02 \
    vendor/xiaomi/msm8953-common/proprietary/vendor/firmware/a506_zap.mdt:$(TARGET_COPY_OUT_ODM)/firmware/qcom/msm8953/xiaomi/a506_zap.mdt

PRODUCT_PACKAGES += \
    all_symlink_firmware_mi8953_a

_src := vendor/xiaomi/oxygen/proprietary/vendor/firmware/wlan/prima/WCNSS_qcom_wlan_nv.bin
_dst := $(TARGET_COPY_OUT_ODM)/firmware/qcom/msm8953/xiaomi/oxygen/WCNSS_qcom_wlan_nv.bin
$(eval $(if $(wildcard $(_src)),PRODUCT_COPY_FILES += $(_src):$(_dst),$(warning $(_src) not found)))

# Init
PRODUCT_PACKAGES += \
    fstab.mi8953_a \
    fstab.mi8953_a.ramdisk \
    init.mi8953_a.rc \
    ueventd.mi8953_a.rc

ifneq ($(MI8953_USE_ANDROID_COMMON_KERNEL),true)
PRODUCT_PACKAGES += \
    use_memfd.rc
endif

$(call soong_config_set,mainline_common_libinit,set_properties_from,devicetree)

# Kernel
ifneq ($(MI8953_USE_ANDROID_COMMON_KERNEL),true)
PRODUCT_PACKAGES += \
    modules.load.normal
endif

# Overlay
DEVICE_PACKAGE_OVERLAYS += \
    $(TARGET_DEVICE_PATH)/overlays/overlay

# Properties
PRODUCT_VENDOR_PROPERTIES += \
    vendor.remoteproc.4080000_remoteproc.ignore=1

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(TARGET_DEVICE_PATH) \
    kernel/mainline/configs

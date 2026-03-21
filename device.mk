#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/samsung/gta2xlwifi

# Inherit options from mainline/qcom-common
TARGET_QCOM_SOC_FAMILY := msm8953
TARGET_CAMERA_PROVIDER_HAL := libcamera
TARGET_SENSORS_HAL := iio
## TODO: Bringup the corresponding hardware and remove the following definitions
TARGET_SUPPORTS_SUSPEND := false
include device/mainline/qcom-common/optional/options.mk

# Inherit from mainline/qcom-common
$(call inherit-product, device/mainline/qcom-common/mainline_qcom-common.mk)

# AAPT
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Audio
PRODUCT_PACKAGES += \
    audio.gta2xlwifi.xml

# Bluetooth
PRODUCT_ODM_PROPERTIES += \
    bluetooth.device.class_of_device=90,2,12

# Boot animation
TARGET_SCREEN_HEIGHT := 1920
TARGET_SCREEN_WIDTH := 1200

# Dalvik heap
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# Firmware
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/firmware/a506_zap.b00:$(TARGET_COPY_OUT_VENDOR)/firmware/a506_zap.b00 \
    $(DEVICE_PATH)/firmware/a506_zap.b01:$(TARGET_COPY_OUT_VENDOR)/firmware/a506_zap.b01 \
    $(DEVICE_PATH)/firmware/a506_zap.b02:$(TARGET_COPY_OUT_VENDOR)/firmware/a506_zap.b02 \
    $(DEVICE_PATH)/firmware/a506_zap.mdt:$(TARGET_COPY_OUT_VENDOR)/firmware/a506_zap.mdt \
    $(DEVICE_PATH)/firmware/wcnss.b00:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.b00 \
    $(DEVICE_PATH)/firmware/wcnss.b01:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.b01 \
    $(DEVICE_PATH)/firmware/wcnss.b02:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.b02 \
    $(DEVICE_PATH)/firmware/wcnss.b04:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.b04 \
    $(DEVICE_PATH)/firmware/wcnss.b06:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.b06 \
    $(DEVICE_PATH)/firmware/wcnss.b09:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.b09 \
    $(DEVICE_PATH)/firmware/wcnss.b10:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.b10 \
    $(DEVICE_PATH)/firmware/wcnss.b11:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.b11 \
    $(DEVICE_PATH)/firmware/wcnss.b12:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.b12 \
    $(DEVICE_PATH)/firmware/wcnss.mdt:$(TARGET_COPY_OUT_VENDOR)/firmware/wcnss.mdt

# HIDL
PRODUCT_PACKAGES += \
    vndservicemanager

# Init
PRODUCT_PACKAGES += \
    init.gta2xlwifi.rc \
    init.recovery.gta2xlwifi.rc \
    ueventd.gta2xlwifi.rc \
    iio_fixup.sh

PRODUCT_PACKAGES += \
    zram.rc

PRODUCT_PACKAGES += \
    fstab.gta2xlwifi \
    fstab.gta2xlwifi.ramdisk

PRODUCT_PACKAGES += \
    use_memfd.rc

$(call soong_config_set,mainline_common_libinit,set_properties_from,devicetree)

# Kernel
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

PRODUCT_PACKAGES += \
    modules.load.normal

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlays/overlay

ifeq ($(PRODUCT_IS_ATV),true)
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlays/overlay-tv
endif

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml

# Properties
PRODUCT_VENDOR_PROPERTIES += \
    vendor.remoteproc.4080000_remoteproc.ignore=1

# Set device properties
PRODUCT_PACKAGES += \
    set_device_prop \
    set_device_prop.recovery

# Scoped Storage
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensor.accelerometer.prebuilt.xml \
    android.hardware.sensor.ambient_temperature.prebuilt.xml \
    android.hardware.sensor.compass.prebuilt.xml \
    android.hardware.sensor.gyroscope.prebuilt.xml \
    android.hardware.sensor.light.prebuilt.xml \
    android.hardware.sensor.proximity.prebuilt.xml

# Shipping API level
PRODUCT_SHIPPING_API_LEVEL := 33

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    kernel/mainline/configs

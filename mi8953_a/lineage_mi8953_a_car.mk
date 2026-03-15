#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/telephony_vendor.mk)
$(call inherit-product, packages/services/Car/car_product/build/car_generic_system.mk)
$(call inherit-product, packages/services/Car/car_product/build/car_system_ext.mk)
$(call inherit-product, packages/services/Car/car_product/build/car_product.mk)
$(call inherit-product, packages/services/Car/car_product/build/car_vendor.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, device/lineage/car/lineage_car_vendor.mk)
$(call inherit-product, vendor/lineage/config/common_car.mk)

# Inherit from device
PRODUCT_IS_AUTOMOTIVE := true
$(call inherit-product, device/xiaomi/mi89xx-mainline/mi8953_a/device.mk)

# Overlays
PRODUCT_PACKAGE_OVERLAYS += \
    device/google_car/common/overlay

PRODUCT_PACKAGES += \
    CarServiceOverlayPhoneCar

# Permissions
ifneq ($(PORTRAIT_UI),true)
# Enable landscape
PRODUCT_COPY_FILES += \
    device/google_car/common/unavailable_features_landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/unavailable_features_landscape.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:system/etc/permissions/android.hardware.screen.landscape.xml
endif

# Set device properties
$(call soong_config_set_bool,xiaomi_mi89xx_mainline_set_device_prop,divide_lcd_density_by_two,true)

PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := false

PRODUCT_NAME := lineage_mi8953_a_car
PRODUCT_DEVICE := mi8953_a
PRODUCT_BRAND := Xiaomi
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := MSM8953 Car

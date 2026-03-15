#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, device/google/atv/products/atv_base.mk)

# Inherit some common Lineage stuff.
TARGET_ATV_FORCE_1080_SCALING := false
$(call inherit-product, vendor/lineage/config/common_tv.mk)

# Inherit from device
PRODUCT_IS_ATV := true
$(call inherit-product, device/xiaomi/mi89xx-mainline/mi89x7/device.mk)

PRODUCT_CHARACTERISTICS := tv

PRODUCT_NAME := lineage_mi89x7_tv
PRODUCT_DEVICE := mi89x7
PRODUCT_BRAND := Xiaomi
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := MSM89x7 TV

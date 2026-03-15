#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_mini_go_phone.mk)

# Inherit from device
PRODUCT_IS_GO := true
$(call inherit-product, device/xiaomi/mi89xx-mainline/tiare_mainline/device.mk)

PRODUCT_NAME := lineage_tiare_mainline
PRODUCT_DEVICE := tiare_mainline
PRODUCT_BRAND := Xiaomi
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := Redmi Go

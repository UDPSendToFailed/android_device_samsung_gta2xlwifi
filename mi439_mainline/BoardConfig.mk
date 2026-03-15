#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from parent
include device/xiaomi/mi89xx-mainline/BoardConfig.mk

# A/B
AB_OTA_UPDATER := false

# Boot parameters
BOARD_KERNEL_CMDLINE += \
    androidboot.hardware=mi439 \
    lk2nd.pass-simplefb=xrgb8888,relocate

# Kernel
TARGET_KERNEL_SOURCE := kernel/mainline/msm89x7-mainline

TARGET_DTB_LIST_WILDCARD := \
    qcom/sdm439-xiaomi-*

TARGET_KERNEL_CONFIG_EXT := \
    $(DEVICE_PATH)/mi89x7/kconfigs/config-postmarketos-qcom-msm89x7.aarch64 \
    kernel/mainline/configs/fragments/android-base-pre/common.config \
    kernel/mainline/configs/fragments/android-base-pre/arm64.config \
    kernel/configs/b/android-6.12/android-base.config \
    kernel/mainline/configs/fragments/android-base-conditional/CONFIG_ARM64-y.config \
    kernel/mainline/configs/fragments/common.config \
    kernel/mainline/configs/fragments/y/fbcon.config \
    kernel/mainline/configs/fragments/n/disable-clang-hardening-features.config \
    kernel/mainline/configs/fragments/n/faster-build-time.config \
    $(TARGET_DEVICE_PATH)/kconfigs/fixups.config

# Kernel modules
BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.load.basic)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.load.touchscreen))
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)
RECOVERY_KERNEL_MODULES := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.include_dep.basic)) \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)

# OTA
TARGET_OTA_ASSERT_DEVICE := mi439,Mi439,mi439_mainline

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_CACHEIMAGE_PARTITION_SIZE := 268435456
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT := -1
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3221225472
BOARD_VENDOR_DLKMIMAGE_EXTFS_INODE_COUNT := -1
BOARD_VENDOR_DLKMIMAGE_PARTITION_SIZE := 536870912
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_EXTFS_INODE_COUNT := -1
BOARD_VENDORIMAGE_PARTITION_SIZE := 1073741824
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

BOARD_USES_METADATA_PARTITION := true
BOARD_USES_VENDOR_DLKMIMAGE := true
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

# Recovery
TARGET_RECOVERY_DENSITY := xhdpi
TARGET_RECOVERY_FSTAB := $(TARGET_DEVICE_PATH)/fstab/fstab.mi439
TARGET_RECOVERY_PIXEL_FORMAT := BGRX_8888

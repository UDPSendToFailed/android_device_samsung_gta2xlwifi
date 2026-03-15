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
    androidboot.hardware=mi8916

# Kernel
TARGET_KERNEL_SOURCE := kernel/mainline/msm8916-mainline

TARGET_DTB_LIST_WILDCARD := \
    qcom/msm8916-wingtech-wt88047

TARGET_KERNEL_CONFIG := \
    msm8916_defconfig

TARGET_KERNEL_CONFIG_EXT := \
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
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.load.drm)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.load.touchscreen))
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)
RECOVERY_KERNEL_MODULES := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.include_dep.basic)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.include_dep.drm)) \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)

# OTA
TARGET_OTA_ASSERT_DEVICE := mi8916

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_CACHEIMAGE_PARTITION_SIZE := 335544320
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT := -1
BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE := 67108864
BOARD_VENDORIMAGE_EXTFS_INODE_COUNT := -1
BOARD_VENDORIMAGE_PARTITION_RESERVED_SIZE := 67108864
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

BOARD_USES_METADATA_PARTITION := true
TARGET_COPY_OUT_VENDOR := vendor

# Recovery
TARGET_RECOVERY_DENSITY := xhdpi
TARGET_RECOVERY_FSTAB := $(TARGET_DEVICE_PATH)/fstab/fstab.mi8916

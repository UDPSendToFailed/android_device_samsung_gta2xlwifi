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
    androidboot.hardware=tiare

# Filesystem
BOARD_EROFS_PCLUSTER_SIZE := 262144

# Kernel
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_SOURCE := kernel/mainline/msm89x7-mainline

TARGET_DTB_LIST_WILDCARD := \
    qcom/msm8917-xiaomi-tiare

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
    kernel/mainline/configs/fragments/n/go.config

# Kernel modules
BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.load.basic)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.load.drm)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.load.power_supply)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.load.touchscreen))
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)
RECOVERY_KERNEL_MODULES := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/modules.include_dep.basic)) \
    $(strip $(shell cat $(DEVICE_PATH)/mi89x7/modprobe/modules.include_dep.drm)) \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)

# OTA
TARGET_OTA_ASSERT_DEVICE := tiare,tiare_mainline

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 50331648
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864 # fake, real size is 25165824

BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_EXTFS_INODE_COUNT := 4096
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_PARTITION_RESERVED_SIZE := 41943040
TARGET_COPY_OUT_VENDOR := vendor

BOARD_SUPER_PARTITION_BLOCK_DEVICES := cache system vendor
BOARD_SUPER_PARTITION_METADATA_DEVICE := system
BOARD_SUPER_PARTITION_CACHE_DEVICE_SIZE := 157286400
BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 1390411776
BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := 333447168
BOARD_SUPER_PARTITION_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_CACHE_DEVICE_SIZE) + $(BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE) + $(BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE) )

BOARD_SUPER_PARTITION_GROUPS := tiare_dynpart
BOARD_TIARE_DYNPART_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) - 4194304 )
BOARD_TIARE_DYNPART_PARTITION_LIST := system vendor

# Properties
TARGET_ODM_PROP += $(TARGET_DEVICE_PATH)/properties/odm.prop

# Recovery
TARGET_RECOVERY_DENSITY := xhdpi
TARGET_RECOVERY_FSTAB := $(TARGET_DEVICE_PATH)/fstab/fstab.tiare

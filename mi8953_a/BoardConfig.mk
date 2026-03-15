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
    androidboot.hardware=mi8953_a

# Kernel
TARGET_DTB_LIST_WILDCARD := \
    qcom/msm8953-xiaomi-daisy \
    qcom/msm8953-xiaomi-markw \
    qcom/msm8953-xiaomi-mido \
    qcom/msm8953-xiaomi-oxygen \
    qcom/msm8953-xiaomi-vince \
    qcom/msm8953-xiaomi-ysl \
    qcom/sdm450-xiaomi-* \
    qcom/sdm632-xiaomi-*

ifneq ($(MI8953_USE_ANDROID_COMMON_KERNEL),true)
TARGET_KERNEL_CONFIG_EXT := \
    $(TARGET_DEVICE_PATH)/kconfigs/config-postmarketos-qcom-msm8953.aarch64 \
    $(TARGET_DEVICE_PATH)/kconfigs/basic.config \
    kernel/mainline/configs/fragments/android-base-pre/common.config \
    kernel/mainline/configs/fragments/android-base-pre/arm64.config \
    kernel/configs/b/android-6.12/android-base.config \
    kernel/mainline/configs/fragments/android-base-conditional/CONFIG_ARM64-y.config \
    kernel/mainline/configs/fragments/common.config \
    kernel/mainline/configs/fragments/y/fbcon.config \
    kernel/mainline/configs/fragments/n/disable-clang-hardening-features.config \
    kernel/mainline/configs/fragments/n/faster-build-time.config
TARGET_KERNEL_SOURCE := kernel/mainline/msm8953-mainline
else
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    mi8953.config
TARGET_KERNEL_SOURCE := kernel/xiaomi/mi8953-ack
endif

# Kernel modules
ifneq ($(MI8953_USE_ANDROID_COMMON_KERNEL),true)
BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/mainline/modules.load.basic)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/mainline/modules.load.drm)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/mainline/modules.load.panel.*)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/mainline/modules.load.touchscreen))
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)
RECOVERY_KERNEL_MODULES := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/mainline/modules.include_dep.basic)) \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/mainline/modules.include_dep.drm)) \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)
else
BOARD_SYSTEM_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/gki/modules.load.system_dlkm))
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/gki/modules.load.vendor))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/gki/modules.load.vendor_dlkm))
BOARD_RECOVERY_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/gki/modules.load.recovery))
BOOT_KERNEL_MODULES := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/gki/modules.include.vendor_dlkm))
RECOVERY_KERNEL_MODULES := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/gki/modules.include.recovery))
SYSTEM_KERNEL_MODULES := \
    $(strip $(shell cat $(TARGET_DEVICE_PATH)/modprobe/gki/modules.include.system_dlkm))

# Some kernel modules return an error at modprobe time
# TODO: Move non-critical modules to vendor
BOARD_KERNEL_CMDLINE += androidboot.first_stage_console=2
endif

# OTA
TARGET_OTA_ASSERT_DEVICE := mi8953_a

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_CACHEIMAGE_PARTITION_SIZE := 268435456
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT := -1
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3221225472
BOARD_VENDORIMAGE_EXTFS_INODE_COUNT := -1
BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

BOARD_USES_METADATA_PARTITION := true
TARGET_COPY_OUT_VENDOR := vendor

# Recovery
TARGET_RECOVERY_DENSITY := xxhdpi
TARGET_RECOVERY_FSTAB := $(TARGET_DEVICE_PATH)/fstab/fstab.mi8953_a

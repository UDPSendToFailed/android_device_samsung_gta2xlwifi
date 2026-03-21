#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

USES_DEVICE_SAMSUNG_GTA2XLWIFI := true

DEVICE_PATH := device/samsung/gta2xlwifi

# Inherit from mainline/qcom-common
include device/mainline/qcom-common/BoardConfigMainlineQcomCommon.mk

# A/B
AB_OTA_UPDATER := false

# Bootloader
ifneq ($(TARGET_LK2ND_PLATFORM),)
BOARD_BOOT_HEADER_VERSION := 0
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_PATH)/mkbootimg.mk
endif

# Boot parameters
BOARD_KERNEL_CMDLINE := \
    $(MAINLINE_COMMON_ANDROIDBOOT_PARAMS) \
    $(MAINLINE_COMMON_KERNEL_PARAMS) \
    $(MAINLINE_QCOM_KERNEL_PARAMS) \
    $(MAINLINE_QCOM_SOC_ANDROIDBOOT_PARAMS) \
    androidboot.hardware=gta2xlwifi \
    androidboot.verifiedbootstate=orange \
    console=ttyMSM0 \

BOARD_KERNEL_CMDLINE += \
    androidboot.selinux=permissive \
    audit=0 \
    ignore_loglevel \
#    page_owner=on

# Filesystem
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true


# Kernel

TARGET_KERNEL_ARCH := arm64
BOARD_KERNEL_BASE := 0x80000000
BOARD_RAMDISK_OFFSET := 0x02000000
BOARD_TAGS_OFFSET := 0x01e00000
BOARD_KERNEL_PAGESIZE := 2048

BOARD_MKBOOTIMG_ARGS := --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_TAGS_OFFSET) --pagesize $(BOARD_KERNEL_PAGESIZE)

BOARD_INCLUDE_DTB_IN_BOOTIMG := true

TARGET_DTB_LIST_WILDCARD := \
    qcom/msm8953-samsung-* \
    qcom/sdm450-samsung-*

TARGET_KERNEL_CONFIG_EXT := \
    $(DEVICE_PATH)/kconfigs/config-postmarketos-qcom-msm8953.aarch64 \
    $(DEVICE_PATH)/kconfigs/basic.config \
    kernel/mainline/configs/fragments/android-base-pre/common.config \
    kernel/mainline/configs/fragments/android-base-pre/arm64.config \
    kernel/configs/b/android-6.12/android-base.config \
    kernel/mainline/configs/fragments/android-base-conditional/CONFIG_ARM64-y.config \
    kernel/mainline/configs/fragments/common.config \
    kernel/mainline/configs/fragments/y/fbcon.config \
    kernel/mainline/configs/fragments/n/disable-clang-hardening-features.config \
    kernel/mainline/configs/fragments/n/faster-build-time.config
TARGET_KERNEL_SOURCE := kernel/mainline/msm8953-mainline

# Kernel modules
BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(DEVICE_PATH)/modprobe/mainline/modules.load.basic)) \
    $(strip $(shell cat $(DEVICE_PATH)/modprobe/mainline/modules.load.drm)) \
    $(strip $(shell cat $(DEVICE_PATH)/modprobe/mainline/modules.load.panel.*)) \
    $(strip $(shell cat $(DEVICE_PATH)/modprobe/mainline/modules.load.touchscreen))
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)
#RECOVERY_KERNEL_MODULES := \
#    $(strip $(shell cat $(DEVICE_PATH)/modprobe/mainline/modules.include_dep.basic)) \
#    $(strip $(shell cat $(DEVICE_PATH)/modprobe/mainline/modules.include_dep.drm)) \
#    $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)

# OTA
TARGET_OTA_ASSERT_DEVICE := gta2xlwifi

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_CACHEIMAGE_PARTITION_SIZE := 314572800
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT := -1
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3498049536
BOARD_VENDORIMAGE_EXTFS_INODE_COUNT := -1
BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

BOARD_USES_METADATA_PARTITION := true
TARGET_COPY_OUT_VENDOR := vendor

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/properties/vendor.prop

# Ramdisk
BOARD_RAMDISK_USE_LZ4 := true

# Recovery
TARGET_RECOVERY_DENSITY := xxhdpi
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/fstab/fstab.gta2xlwifi

# SELinux
BOARD_ODM_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/odm

# VINTF
DEVICE_MANIFEST_FILE := \
    $(DEVICE_PATH)/vintf/manifest.xml

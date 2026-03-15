#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

USES_DEVICE_XIAOMI_MI89XX := true

# Inherit from mainline/qcom-common
include device/mainline/qcom-common/BoardConfigMainlineQcomCommon.mk

# Bootloader
ifneq ($(TARGET_LK2ND_PLATFORM),)
BOARD_BOOT_HEADER_VERSION := 2
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_PATH)/mkbootimg.mk
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
TARGET_LK2ND_MAKE_FLAGS := OSVERSION_IN_BOOTIMAGE=1
endif

# Boot parameters
BOARD_KERNEL_CMDLINE := \
    $(MAINLINE_COMMON_ANDROIDBOOT_PARAMS) \
    $(MAINLINE_COMMON_KERNEL_PARAMS) \
    $(MAINLINE_QCOM_KERNEL_PARAMS) \
    $(MAINLINE_QCOM_SOC_ANDROIDBOOT_PARAMS) \
    androidboot.verifiedbootstate=orange \
    console=tty0 \
    lk2nd.pass-ramoops=zap

BOARD_KERNEL_CMDLINE += \
    androidboot.selinux=permissive \
    audit=0

# Filesystem
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true

# Kernel
ifneq ($(TARGET_LK2ND_PLATFORM),)
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
endif

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/properties/vendor.prop

# Ramdisk
BOARD_RAMDISK_USE_LZ4 := true

# SELinux
BOARD_ODM_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/odm

# VINTF
DEVICE_MANIFEST_FILE := \
    $(DEVICE_PATH)/vintf/manifest.xml

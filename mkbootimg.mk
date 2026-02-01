
# SPDX-FileCopyrightText: 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

## Boot Image Generation
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target boot image: $@")
	$(eval kernel := $(call bootimage-to-kernel,$@))
	$(MKBOOTIMG) --kernel $(kernel) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
	$(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE))

## Recovery Image (dummy placeholder - using TWRP externally)
$(INSTALLED_RECOVERYIMAGE_TARGET):
	$(call pretty,"Target recovery image (placeholder): $@")
	$(hide) mkdir -p $(dir $@)
	$(hide) touch $@

#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

#ifneq ($(INSTALLED_LK2NDIMAGE_TARGET),)
#MKBOOTIMG_LK2ND_IMAGE_PATH := $(INSTALLED_LK2NDIMAGE_TARGET)
#else
MKBOOTIMG_LK2ND_IMAGE_PATH := $(DEVICE_PATH)/prebuilts/lk2nd-msm8953.img
#endif

# $(1): output image
# $(2): mkbootimg image
# $(3): lk2nd image
define build-lk2nd-boot-image
	cp $(3) $(1)
	python3 -c "import struct; base=int('$(BOARD_KERNEL_BASE)',16); \
		f=open('$(1)','r+b'); \
		f.seek(20); f.write(struct.pack('<I',base+int('$(BOARD_RAMDISK_OFFSET)',16))); \
		f.seek(32); f.write(struct.pack('<I',base+int('$(BOARD_TAGS_OFFSET)',16))); \
		f.seek(40); f.write(struct.pack('<I',$(BOARD_BOOT_HEADER_VERSION))); \
		f.close()"
	$(call assert-max-image-size,$(1),$(TARGET_LK2ND_ACTUAL_BOOTIMG_OFFSET))

	lk2nd_size=$$(stat -c%s $(1)); \
	lk2nd_gap=$$(expr $(TARGET_LK2ND_ACTUAL_BOOTIMG_OFFSET) - $$lk2nd_size); \
	dd if=/dev/zero bs=$$lk2nd_gap count=1 >> $(1)

	cat $(2) >> $(1)
endef

$(foreach b,$(INSTALLED_BOOTIMAGE_TARGET), $(eval $(call add-dependency,$(b),$(call bootimage-to-kernel,$(b)))))

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS) $(MKBOOTIMG_LK2ND_IMAGE_PATH) $(INSTALLED_DTBIMAGE_TARGET)
	$(call pretty,"Target boot image with lk2nd: $@")
	cat $(call bootimage-to-kernel,$@) $(INSTALLED_DTBIMAGE_TARGET) > $@.kernel_dtb
	$(MKBOOTIMG) --kernel $@.kernel_dtb $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@.mkbootimg
	$(call build-lk2nd-boot-image,$@,$@.mkbootimg,$(MKBOOTIMG_LK2ND_IMAGE_PATH))
	$(call assert-max-image-size,$@,$(call get-bootimage-partition-size,$@,boot))

$(INSTALLED_RECOVERYIMAGE_TARGET): $(recoveryimage-deps) $(RECOVERYIMAGE_EXTRA_DEPS) $(MKBOOTIMG_LK2ND_IMAGE_PATH) $(INSTALLED_DTBIMAGE_TARGET)
	$(call pretty,"Target recovery image with lk2nd: $@")
	cat $(recovery_kernel) $(INSTALLED_DTBIMAGE_TARGET) > $@.kernel_dtb
	$(call build-recoveryimage-target,$@.mkbootimg,$@.kernel_dtb)
	$(call build-lk2nd-boot-image,$@,$@.mkbootimg,$(MKBOOTIMG_LK2ND_IMAGE_PATH))
	$(call assert-max-image-size,$@,$(call get-hash-image-max-size,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE)))
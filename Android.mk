# Copyright (C) 2017-2020 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


ifeq ($(TARGET_DEVICE),gta2xlwifi)

include $(call all-subdir-makefiles)

include $(CLEAR_VARS)

DSP_MOUNT_POINT := $(TARGET_OUT_VENDOR)/dsp
FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/firmware_mnt
MODEM_MOUNT_POINT := $(TARGET_OUT_VENDOR)/firmware-modem

$(DSP_MOUNT_POINT):
	@echo "Creating $(DSP_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/dsp

$(FIRMWARE_MOUNT_POINT):
	@echo "Creating $(FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware_mnt

$(MODEM_MOUNT_POINT):
	@echo "Creating $(MODEM_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware-modem

ALL_DEFAULT_INSTALLED_MODULES += $(DSP_MOUNT_POINT) $(FIRMWARE_MOUNT_POINT) $(MODEM_MOUNT_POINT)

endif
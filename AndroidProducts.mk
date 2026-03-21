#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    aosp_gta2xlwifi:$(LOCAL_DIR)/aosp_gta2xlwifi.mk \
    lineage_gta2xlwifi:$(LOCAL_DIR)/lineage_gta2xlwifi.mk

$(foreach build_type, user userdebug eng, \
    $(eval COMMON_LUNCH_CHOICES += aosp_gta2xlwifi-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_gta2xlwifi-$(build_type)))

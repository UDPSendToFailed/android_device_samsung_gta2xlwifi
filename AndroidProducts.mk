#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    aosp_mi439_mainline:$(LOCAL_DIR)/mi439_mainline/aosp_mi439_mainline.mk \
    aosp_mi8916:$(LOCAL_DIR)/mi8916/aosp_mi8916.mk \
    aosp_mi8953_a:$(LOCAL_DIR)/mi8953_a/aosp_mi8953_a.mk \
    aosp_mi89x7:$(LOCAL_DIR)/mi89x7/aosp_mi89x7.mk \
    aosp_tiare_mainline:$(LOCAL_DIR)/tiare_mainline/aosp_tiare_mainline.mk \
    lineage_mi439_mainline:$(LOCAL_DIR)/mi439_mainline/lineage_mi439_mainline.mk \
    lineage_mi8916:$(LOCAL_DIR)/mi8916/lineage_mi8916.mk \
    lineage_mi8953_a:$(LOCAL_DIR)/mi8953_a/lineage_mi8953_a.mk \
    lineage_mi8953_a_car:$(LOCAL_DIR)/mi8953_a/lineage_mi8953_a_car.mk \
    lineage_mi8953_a_tv:$(LOCAL_DIR)/mi8953_a/lineage_mi8953_a_tv.mk \
    lineage_mi89x7:$(LOCAL_DIR)/mi89x7/lineage_mi89x7.mk \
    lineage_mi89x7_car:$(LOCAL_DIR)/mi89x7/lineage_mi89x7_car.mk \
    lineage_mi89x7_tv:$(LOCAL_DIR)/mi89x7/lineage_mi89x7_tv.mk \
    lineage_tiare_mainline:$(LOCAL_DIR)/tiare_mainline/lineage_tiare_mainline.mk

$(foreach build_type, user userdebug eng, \
    $(eval COMMON_LUNCH_CHOICES += aosp_mi439_mainline-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += aosp_mi8916-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += aosp_mi8953_a-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += aosp_mi89x7-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += aosp_tiare_mainline-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_mi439_mainline-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_mi8916-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_mi8953_a-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_mi8953_a_car-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_mi8953_a_tv-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_mi89x7-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_mi89x7_car-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_mi89x7_tv-$(build_type)) \
    $(eval COMMON_LUNCH_CHOICES += lineage_tiare_mainline-$(build_type)))

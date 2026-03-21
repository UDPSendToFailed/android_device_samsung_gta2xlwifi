LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := gta2xlwifi_wcnss_nv
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/firmware/wlan/prima
LOCAL_SRC_FILES := WCNSS_qcom_wlan_nv.bin
LOCAL_OVERRIDES_MODULES := mainline_qcom-common_symlink_persist_firmware_wlan_prima_WCNSS_qcom_wlan_nv.bin
include $(BUILD_PREBUILT)
#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)
from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    libs_proto_3_9_1,
    lib_fixups,
    lib_fixups_user_type,
    lib_fixup_vendorcompat,
)

namespace_imports = [
    'device/samsung/gta2xlwifi',
    'hardware/qcom-caf/msm8996',
    'hardware/qcom-caf/wlan',
]

lib_fixups: lib_fixups_user_type = {
    libs_proto_3_9_1: lib_fixup_vendorcompat,
}

# Define the blob fixups
blob_fixups: blob_fixups_user_type = {

    ('vendor/lib/libmmcamera_hdr_gb_lib.so',
     'vendor/lib/libstr_preview_core.so'): blob_fixup()
    .replace_needed('libstdc++.so', 'libstdc++_vendor.so'),

    ('vendor/lib/libhifills.so'): blob_fixup()
    .replace_needed('libcutils.so', "libprocessgroup.so"),

    ('vendor/lib/libmmcamera_ppeiscore.so'): blob_fixup()
    .replace_needed('libGLESv2.so', 'libGLESv2_adreno.so'),

    ('vendor/lib/hw/gatekeeper.mdfpp.so',): blob_fixup()
    .replace_needed('libcrypto.so', 'libcrypto-v33.so'),

    ('vendor/lib/hw/camera.legacy.msm8953.so'): blob_fixup()
    .fix_soname(),

    ('vendor/lib/libmmcamera_faceproc2.so'): blob_fixup()
    .fix_soname()
    .clear_symbol_version('__aeabi_memcpy')
    .clear_symbol_version('__aeabi_memset')
    .clear_symbol_version('__gnu_Unwind_Find_exidx'),

    ('vendor/lib/hw/vulkan.adreno.so',
     'vendor/lib64/hw/vulkan.adreno.so'): blob_fixup()
    .fix_soname()
    .clear_symbol_version('AHardwareBuffer_acquire')
    .clear_symbol_version('AHardwareBuffer_allocate')
    .clear_symbol_version('AHardwareBuffer_describe')
    .clear_symbol_version('AHardwareBuffer_getNativeHandle')
    .clear_symbol_version('AHardwareBuffer_release'),

    ('vendor/lib/hw/gralloc.gta2xl.so'): blob_fixup()
    .fix_soname(),

}

# Define the module
module = ExtractUtilsModule(
    'gta2xlwifi',
    'samsung',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()

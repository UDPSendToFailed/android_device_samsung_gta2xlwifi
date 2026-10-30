/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

class SemNativeCarrierFeature {
public:
    static SemNativeCarrierFeature* getInstance();
    int getInt(int slot, const char* key, int defValue, bool cache);
    const char* getString(int slot, const char* key, const char* defValue, bool cache);
};

SemNativeCarrierFeature* SemNativeCarrierFeature::getInstance() {
    static SemNativeCarrierFeature inst;
    return &inst;
}

int SemNativeCarrierFeature::getInt(int /*slot*/, const char* /*key*/, int defValue, bool /*cache*/) {
    return defValue;
}

const char* SemNativeCarrierFeature::getString(int /*slot*/, const char* /*key*/, const char* defValue, bool /*cache*/) {
    return defValue;
}


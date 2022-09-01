/*
 * Copyright (C) 2018 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <media/AudioSystem.h>

int main(int, char**)
{
    android::AudioSystem::setParameters(0, android::String8("l_effect_tdm_framework_enable=true"));
    return 0;
}

/*
 * Copyright (C) 2019 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "set-audio-rotation"

#include <android-base/logging.h>
#include <cstring>
#include <tinyalsa/asoundlib.h>

int main(int argc, char **argv) {
    if (argc != 2)
        return -1;

    int rotation = atoi(argv[1]);
    if (rotation < 0 || rotation > 3)
        return -1;

    struct mixer *mixer = mixer_open(0);
    if (mixer == nullptr) {
        LOG(ERROR) << "Failed to open mixer";
        return -1;
    }

    struct mixer_ctl *ctl = mixer_get_ctl_by_name(mixer, "SPKUR TFA Speaker Rotation");
    if (ctl == nullptr) {
        LOG(ERROR) << "Failed to find SPKUR TFA Speaker Rotation control";
        mixer_close(mixer);
        return -1;
    }

    if (mixer_ctl_set_value(ctl, 0, rotation) < 0) {
        LOG(ERROR) << "Failed to set rotation to " << rotation;
        mixer_close(mixer);
        return -1;
    }

    LOG(INFO) << "Set speaker rotation to " << rotation;
    mixer_close(mixer);
    return 0;
}

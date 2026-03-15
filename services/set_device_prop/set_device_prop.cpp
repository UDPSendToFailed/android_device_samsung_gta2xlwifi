#include <fstream>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>

#include <stdlib.h>

#include <android-base/properties.h>
#include <android-base/strings.h>

using android::base::SetProperty;
using android::base::StartsWith;

const std::string kDtCompatiblePath = "/sys/firmware/devicetree/base/compatible";
const std::string kPropPrefix = "ro.vendor.device.";

typedef struct device_info {
    unsigned int lcd_density;
} device_info_t;

const device_info_t kFallbackDeviceInfo = {
        .lcd_density = 320,
};

const std::unordered_map<std::string, device_info_t> kDeviceInfoMap = {
        // clang-format off

    // mi8916
    {"wt88047", {320}},

    // Mi8917
    {"riva", {280}},
    {"rolex", {280}},
    {"tiare", {280}},
    {"ugglite", {260}},

    // Mi8937
    {"land", {280}},
    {"prada", {280}},
    {"santoni", {280}},
    {"ugg", {260}},

    // Mi439
    {"olive", {320}},
    {"pine", {320}},

    // Xiaomi MSM8953
    {"daisy", {420}},
    {"oxygen", {342}},
    {"uter", {400}},
    {"sakura", {420}},
    {"vince", {440}},
    {"ysl", {280}},

        // clang-format on
};

std::vector<std::string> readDtCompatible(const std::string& filename) {
    std::vector<std::string> result;
    std::ifstream file(filename, std::ios::binary);

    if (!file) {
        std::cerr << "Could not open file: " << filename << std::endl;
        return result;
    }

    std::string buffer;
    char ch;

    // Read file byte by byte
    while (file.get(ch)) {
        if (ch != '\0') {
            buffer += ch;
        } else {
            if (!buffer.empty()) {
                result.push_back(buffer);
                buffer.clear();
            }
        }
    }

    // Push any remaining buffer as a string
    if (!buffer.empty()) {
        result.push_back(buffer);
    }

    return result;
}

int main() {
    bool ret = true;

    std::vector<std::string> compatibles = readDtCompatible(kDtCompatiblePath);
    if (compatibles.empty()) {
        std::cout << "Failed to read " << kDtCompatiblePath << std::endl;
        return EXIT_FAILURE;
    }

    std::string device_codename;
    for (const auto& compatible : compatibles) {
        if (StartsWith(compatible, "wingtech,") || StartsWith(compatible, "xiaomi,")) {
            if (!device_codename.empty()) continue;
            device_codename = compatible.substr(compatible.find_first_of(",") + 1);
            std::cout << "Device codename: " << device_codename << std::endl;
            ret &= SetProperty(kPropPrefix + "codename", device_codename);
        }
    }

    if (device_codename.empty()) {
        std::cout << "Failed to get device codename" << std::endl;
        return EXIT_FAILURE;
    }

    const device_info_t* device_info_ptr;
    if (kDeviceInfoMap.find(device_codename) != kDeviceInfoMap.end()) {
        device_info_ptr = &kDeviceInfoMap.at(device_codename);
    } else {
        std::cout << "No matching device info, using fallback" << std::endl;
        device_info_ptr = &kFallbackDeviceInfo;
    }

    unsigned int tmp_lcd_density = device_info_ptr->lcd_density;
#ifdef DIVIDE_LCD_DENSITY_BY_TWO
    tmp_lcd_density /= 2;
#endif
    ret &= SetProperty(kPropPrefix + "lcd_density", std::to_string(tmp_lcd_density));

    return ret == true ? EXIT_SUCCESS : EXIT_FAILURE;
}

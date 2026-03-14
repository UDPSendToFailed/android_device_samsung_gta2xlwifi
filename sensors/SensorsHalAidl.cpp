/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * AIDL Sensors HAL wrapping legacy sensors.msm8953.so for gta2xlwifi.
 */

#define LOG_TAG "sensors-hal-aidl"

#include "SensorsHalAidl.h"

#include <aidl/sensors/convert.h>
#include <aidlcommonsupport/NativeHandle.h>
#include <android-base/logging.h>
#include <hardware/sensors.h>
#include <hardware_legacy/power.h>
#include <log/log.h>
#include <utils/SystemClock.h>

#include <cinttypes>

namespace aidl {
namespace android {
namespace hardware {
namespace sensors {
namespace implementation {

using ::android::hardware::sensors::implementation::convertFromSensorEvent;
using ::android::hardware::sensors::implementation::convertToSensorEvent;
using ::android::status_t;
using ::ndk::ScopedAStatus;

static void convertFromLegacySensorInfo(const sensor_t& src, SensorInfo* dst) {
    dst->sensorHandle = src.handle;
    dst->name = src.name ? src.name : "";
    dst->vendor = src.vendor ? src.vendor : "";
    dst->version = src.version;
    dst->type = static_cast<::aidl::android::hardware::sensors::SensorType>(src.type);
    dst->typeAsString = src.stringType ? src.stringType : "";
    dst->maxRange = src.maxRange;
    dst->resolution = src.resolution;
    dst->power = src.power;
    dst->minDelayUs = src.minDelay;
    dst->fifoReservedEventCount = src.fifoReservedEventCount;
    dst->fifoMaxEventCount = src.fifoMaxEventCount;
    dst->requiredPermission = src.requiredPermission ? src.requiredPermission : "";
    dst->maxDelayUs = src.maxDelay;
    dst->flags = src.flags;
}

SensorsHalAidl::SensorsHalAidl() {
    const hw_module_t* module = nullptr;
    status_t err = hw_get_module(SENSORS_HARDWARE_MODULE_ID, &module);
    mSensorModule = reinterpret_cast<sensors_module_t*>(const_cast<hw_module_t*>(module));
    if (err != ::android::OK || mSensorModule == nullptr) {
        LOG(FATAL) << "Failed to load " << SENSORS_HARDWARE_MODULE_ID << " module: "
                   << strerror(-err);
        return;
    }

    err = sensors_open_1(&mSensorModule->common, &mSensorDevice);
    if (err != ::android::OK || mSensorDevice == nullptr) {
        LOG(FATAL) << "Failed to open sensor device: " << strerror(-err);
        return;
    }

    CHECK_GE(mSensorDevice->common.version, SENSORS_DEVICE_API_VERSION_1_3);

    // Enumerate available sensors
    sensor_t const* list = nullptr;
    int count = mSensorModule->get_sensors_list(mSensorModule, &list);
    for (int i = 0; i < count; i++) {
        SensorInfo info;
        convertFromLegacySensorInfo(list[i], &info);
        mSensors[info.sensorHandle] = info;
    }

    LOG(INFO) << "Loaded " << count << " sensors from " << SENSORS_HARDWARE_MODULE_ID;
}

SensorsHalAidl::~SensorsHalAidl() {
    mStopThread = true;
    mReadWakeLockQueueRun = false;
    ++mPollGeneration;

    // poll() is a blocking syscall that can't be interrupted, so detach
    // the thread and let process exit clean it up.
    if (mPollThread.joinable()) {
        mPollThread.detach();
    }
    if (mWakeLockThread.joinable()) {
        mWakeLockThread.join();
    }

    deleteEventFlag();

    if (mSensorDevice != nullptr) {
        sensors_close_1(mSensorDevice);
    }
}

ScopedAStatus SensorsHalAidl::activate(int32_t in_sensorHandle, bool in_enabled) {
    if (mSensors.find(in_sensorHandle) == mSensors.end()) {
        return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    int err = mSensorDevice->activate(reinterpret_cast<sensors_poll_device_t*>(mSensorDevice),
                                      in_sensorHandle, in_enabled ? 1 : 0);
    if (err != 0) {
        return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }
    return ScopedAStatus::ok();
}

ScopedAStatus SensorsHalAidl::batch(int32_t in_sensorHandle, int64_t in_samplingPeriodNs,
                                    int64_t in_maxReportLatencyNs) {
    if (mSensors.find(in_sensorHandle) == mSensors.end()) {
        return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    int err = mSensorDevice->batch(mSensorDevice, in_sensorHandle, 0 /* flags */,
                                   in_samplingPeriodNs, in_maxReportLatencyNs);
    if (err != 0) {
        return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }
    return ScopedAStatus::ok();
}

ScopedAStatus SensorsHalAidl::configDirectReport(int32_t in_sensorHandle,
                                                  int32_t in_channelHandle,
                                                  ISensors::RateLevel in_rate,
                                                  int32_t* _aidl_return) {
    if (mSensorDevice->config_direct_report == nullptr) {
        return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    sensors_direct_cfg_t cfg;
    switch (in_rate) {
        case ISensors::RateLevel::STOP:
            cfg.rate_level = SENSOR_DIRECT_RATE_STOP;
            break;
        case ISensors::RateLevel::NORMAL:
            cfg.rate_level = SENSOR_DIRECT_RATE_NORMAL;
            break;
        case ISensors::RateLevel::FAST:
            cfg.rate_level = SENSOR_DIRECT_RATE_FAST;
            break;
        case ISensors::RateLevel::VERY_FAST:
            cfg.rate_level = SENSOR_DIRECT_RATE_VERY_FAST;
            break;
        default:
            return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    int err = mSensorDevice->config_direct_report(mSensorDevice, in_sensorHandle,
                                                   in_channelHandle, &cfg);
    if (in_rate == ISensors::RateLevel::STOP) {
        *_aidl_return = 0;
        return err < 0 ? ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT)
                       : ScopedAStatus::ok();
    }

    if (err > 0) {
        *_aidl_return = err;
        return ScopedAStatus::ok();
    }

    *_aidl_return = 0;
    return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
}

ScopedAStatus SensorsHalAidl::flush(int32_t in_sensorHandle) {
    if (mSensors.find(in_sensorHandle) == mSensors.end()) {
        return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    int err = mSensorDevice->flush(mSensorDevice, in_sensorHandle);
    if (err != 0) {
        return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }
    return ScopedAStatus::ok();
}

ScopedAStatus SensorsHalAidl::getSensorsList(std::vector<SensorInfo>* _aidl_return) {
    for (const auto& [handle, info] : mSensors) {
        _aidl_return->push_back(info);
    }
    return ScopedAStatus::ok();
}

ScopedAStatus SensorsHalAidl::initialize(
        const ::aidl::android::hardware::common::fmq::MQDescriptor<Event, SynchronizedReadWrite>&
                in_eventQueueDescriptor,
        const ::aidl::android::hardware::common::fmq::MQDescriptor<int32_t,
                                                                    SynchronizedReadWrite>&
                in_wakeLockDescriptor,
        const std::shared_ptr<ISensorsCallback>& in_sensorsCallback) {
    // Clean up previous state
    mStopThread = true;
    mReadWakeLockQueueRun = false;
    // Bump generation so the old poll thread stops posting events.
    int32_t gen = ++mPollGeneration;

    // Legacy HAL poll() is a blocking syscall we can't interrupt, so detach
    // the old thread — it will exit on its own once poll() returns.
    if (mPollThread.joinable()) {
        mPollThread.detach();
    }
    if (mWakeLockThread.joinable()) {
        mWakeLockThread.join();
    }

    // Deactivate all sensors (clean slate per AIDL contract)
    for (const auto& [handle, info] : mSensors) {
        mSensorDevice->activate(reinterpret_cast<sensors_poll_device_t*>(mSensorDevice),
                                handle, 0 /* disable */);
    }

    {
        std::lock_guard<std::mutex> lock(mWriteLock);
        deleteEventFlag();
        mEventQueue = std::make_unique<AidlMessageQueue<Event, SynchronizedReadWrite>>(
                in_eventQueueDescriptor, true /* resetPointers */);
    }

    if (mEventQueue == nullptr || !mEventQueue->isValid()) {
        mEventQueue = nullptr;
        return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    EventFlag::deleteEventFlag(&mEventQueueFlag);
    EventFlag::createEventFlag(mEventQueue->getEventFlagWord(), &mEventQueueFlag);

    mWakeLockQueue = std::make_unique<AidlMessageQueue<int32_t, SynchronizedReadWrite>>(
            in_wakeLockDescriptor, true /* resetPointers */);

    if (mWakeLockQueue == nullptr || !mWakeLockQueue->isValid()) {
        mWakeLockQueue = nullptr;
        return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    mCallback = in_sensorsCallback;

    // Reset wake lock state
    {
        std::lock_guard<std::mutex> lock(mWakeLockLock);
        mOutstandingWakeUpEvents = 0;
        if (mHasWakeLock) {
            release_wake_lock(kWakeLockName);
            mHasWakeLock = false;
        }
    }

    // Start worker threads
    mStopThread = false;
    mReadWakeLockQueueRun = true;
    mPollThread = std::thread([this, gen] { pollForEvents(gen); });
    mWakeLockThread = std::thread([this] { readWakeLockFMQ(); });

    return ScopedAStatus::ok();
}

ScopedAStatus SensorsHalAidl::injectSensorData(const Event& in_event) {
    if (mSensorDevice->common.version < SENSORS_DEVICE_API_VERSION_1_4 ||
        mSensorDevice->inject_sensor_data == nullptr) {
        return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    sensors_event_t out;
    convertToSensorEvent(in_event, &out);

    int err = mSensorDevice->inject_sensor_data(mSensorDevice, &out);
    if (err != 0) {
        return ScopedAStatus::fromServiceSpecificError(ISensors::ERROR_BAD_VALUE);
    }
    return ScopedAStatus::ok();
}

ScopedAStatus SensorsHalAidl::registerDirectChannel(const ISensors::SharedMemInfo& in_mem,
                                                     int32_t* _aidl_return) {
    if (mSensorDevice->register_direct_channel == nullptr) {
        return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    sensors_direct_mem_t mem;
    switch (in_mem.type) {
        case ISensors::SharedMemInfo::SharedMemType::ASHMEM:
            mem.type = SENSOR_DIRECT_MEM_TYPE_ASHMEM;
            break;
        case ISensors::SharedMemInfo::SharedMemType::GRALLOC:
            mem.type = SENSOR_DIRECT_MEM_TYPE_GRALLOC;
            break;
        default:
            return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    switch (in_mem.format) {
        case ISensors::SharedMemInfo::SharedMemFormat::SENSORS_EVENT:
            mem.format = SENSOR_DIRECT_FMT_SENSORS_EVENT;
            break;
        default:
            return ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    mem.size = in_mem.size;
    mem.handle = ::android::makeFromAidl(in_mem.memoryHandle);

    int err = mSensorDevice->register_direct_channel(mSensorDevice, &mem, -1);
    if (err < 0) {
        return ScopedAStatus::fromServiceSpecificError(ISensors::ERROR_NO_MEMORY);
    }

    *_aidl_return = err;
    return ScopedAStatus::ok();
}

ScopedAStatus SensorsHalAidl::setOperationMode(ISensors::OperationMode in_mode) {
    if (mSensorDevice->common.version < SENSORS_DEVICE_API_VERSION_1_4 ||
        mSensorModule->set_operation_mode == nullptr) {
        return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    int err = mSensorModule->set_operation_mode(static_cast<unsigned int>(in_mode));
    if (err != 0) {
        return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }
    return ScopedAStatus::ok();
}

ScopedAStatus SensorsHalAidl::unregisterDirectChannel(int32_t in_channelHandle) {
    if (mSensorDevice->register_direct_channel == nullptr) {
        return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    mSensorDevice->register_direct_channel(mSensorDevice, nullptr, in_channelHandle);
    return ScopedAStatus::ok();
}

void SensorsHalAidl::pollForEvents(int32_t generation) {
    auto data = std::make_unique<sensors_event_t[]>(kPollMaxBufferSize);

    while (!mStopThread.load() && mPollGeneration.load() == generation) {
        int count = mSensorDevice->poll(reinterpret_cast<sensors_poll_device_t*>(mSensorDevice),
                                        data.get(), kPollMaxBufferSize);
        if (count <= 0 || mPollGeneration.load() != generation) {
            break;
        }

        bool wakeup = false;
        std::vector<Event> events(count);
        for (int i = 0; i < count; i++) {
            convertFromSensorEvent(data[i], &events[i]);
            if (isWakeUpSensor(events[i].sensorHandle)) {
                wakeup = true;
            }
        }
        postEvents(events, wakeup);
    }
}

void SensorsHalAidl::postEvents(const std::vector<Event>& events, bool wakeup) {
    std::lock_guard<std::mutex> lock(mWriteLock);
    if (mEventQueue == nullptr) {
        return;
    }

    if (mEventQueue->write(events.data(), events.size())) {
        if (mEventQueueFlag != nullptr) {
            mEventQueueFlag->wake(
                    static_cast<uint32_t>(BnSensors::EVENT_QUEUE_FLAG_BITS_READ_AND_PROCESS));
        }
        if (wakeup) {
            updateWakeLock(events.size(), 0);
        }
    }
}

void SensorsHalAidl::readWakeLockFMQ() {
    while (mReadWakeLockQueueRun.load()) {
        constexpr int64_t kReadTimeoutNs = 500 * 1000 * 1000;  // 500 ms
        int32_t eventsHandled = 0;

        mWakeLockQueue->readBlocking(
                &eventsHandled, 1, 0 /* readNotification */,
                static_cast<uint32_t>(WAKE_LOCK_QUEUE_FLAG_BITS_DATA_WRITTEN), kReadTimeoutNs);
        updateWakeLock(0, eventsHandled);
    }
}

void SensorsHalAidl::updateWakeLock(int32_t eventsWritten, int32_t eventsHandled) {
    std::lock_guard<std::mutex> lock(mWakeLockLock);
    int32_t newVal = mOutstandingWakeUpEvents + eventsWritten - eventsHandled;
    mOutstandingWakeUpEvents = std::max(0, newVal);

    if (eventsWritten > 0) {
        mAutoReleaseWakeLockTime =
                ::android::uptimeMillis() + static_cast<int64_t>(WAKE_LOCK_TIMEOUT_SECONDS) * 1000;
    }

    if (!mHasWakeLock && mOutstandingWakeUpEvents > 0 &&
        acquire_wake_lock(PARTIAL_WAKE_LOCK, kWakeLockName) == 0) {
        mHasWakeLock = true;
    } else if (mHasWakeLock) {
        if (::android::uptimeMillis() > mAutoReleaseWakeLockTime) {
            ALOGD("Auto releasing wake lock after %d seconds", WAKE_LOCK_TIMEOUT_SECONDS);
            mOutstandingWakeUpEvents = 0;
        }
        if (mOutstandingWakeUpEvents == 0 && release_wake_lock(kWakeLockName) == 0) {
            mHasWakeLock = false;
        }
    }
}

void SensorsHalAidl::deleteEventFlag() {
    if (mEventQueueFlag != nullptr) {
        EventFlag::deleteEventFlag(&mEventQueueFlag);
    }
}

bool SensorsHalAidl::isWakeUpSensor(int32_t handle) const {
    auto it = mSensors.find(handle);
    return it != mSensors.end() &&
           (it->second.flags & SensorInfo::SENSOR_FLAG_BITS_WAKE_UP);
}

}  // namespace implementation
}  // namespace sensors
}  // namespace hardware
}  // namespace android
}  // namespace aidl

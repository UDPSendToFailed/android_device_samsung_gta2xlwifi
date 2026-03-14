/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * AIDL Sensors HAL wrapping legacy sensors.msm8953.so for gta2xlwifi.
 * Direct replacement for android.hardware.sensors@1.0-service.samsung.
 */

#pragma once

#include <aidl/android/hardware/sensors/BnSensors.h>
#include <fmq/AidlMessageQueue.h>
#include <hardware/sensors.h>
#include <hardware_legacy/power.h>

#include <atomic>
#include <map>
#include <memory>
#include <mutex>
#include <thread>
#include <vector>

namespace aidl {
namespace android {
namespace hardware {
namespace sensors {
namespace implementation {

using ::aidl::android::hardware::common::fmq::SynchronizedReadWrite;
using ::aidl::android::hardware::sensors::Event;
using ::aidl::android::hardware::sensors::ISensors;
using ::aidl::android::hardware::sensors::ISensorsCallback;
using ::aidl::android::hardware::sensors::SensorInfo;
using ::android::AidlMessageQueue;
using ::android::hardware::EventFlag;

class SensorsHalAidl : public BnSensors {
  public:
    SensorsHalAidl();
    ~SensorsHalAidl() override;

    ndk::ScopedAStatus activate(int32_t in_sensorHandle, bool in_enabled) override;
    ndk::ScopedAStatus batch(int32_t in_sensorHandle, int64_t in_samplingPeriodNs,
                             int64_t in_maxReportLatencyNs) override;
    ndk::ScopedAStatus configDirectReport(int32_t in_sensorHandle, int32_t in_channelHandle,
                                          ISensors::RateLevel in_rate,
                                          int32_t* _aidl_return) override;
    ndk::ScopedAStatus flush(int32_t in_sensorHandle) override;
    ndk::ScopedAStatus getSensorsList(std::vector<SensorInfo>* _aidl_return) override;
    ndk::ScopedAStatus initialize(
            const ::aidl::android::hardware::common::fmq::MQDescriptor<
                    Event, SynchronizedReadWrite>& in_eventQueueDescriptor,
            const ::aidl::android::hardware::common::fmq::MQDescriptor<
                    int32_t, SynchronizedReadWrite>& in_wakeLockDescriptor,
            const std::shared_ptr<ISensorsCallback>& in_sensorsCallback) override;
    ndk::ScopedAStatus injectSensorData(const Event& in_event) override;
    ndk::ScopedAStatus registerDirectChannel(const ISensors::SharedMemInfo& in_mem,
                                             int32_t* _aidl_return) override;
    ndk::ScopedAStatus setOperationMode(ISensors::OperationMode in_mode) override;
    ndk::ScopedAStatus unregisterDirectChannel(int32_t in_channelHandle) override;

  private:
    static constexpr const char* kWakeLockName = "SensorsHAL_WAKEUP";
    static constexpr int32_t kPollMaxBufferSize = 128;
    static constexpr int32_t WAKE_LOCK_TIMEOUT_SECONDS = 1;

    void pollForEvents(int32_t generation);
    void readWakeLockFMQ();
    void updateWakeLock(int32_t eventsWritten, int32_t eventsHandled);
    void postEvents(const std::vector<Event>& events, bool wakeup);
    void deleteEventFlag();

    bool isWakeUpSensor(int32_t handle) const;

    struct sensors_module_t* mSensorModule = nullptr;
    sensors_poll_device_1_t* mSensorDevice = nullptr;

    std::map<int32_t, SensorInfo> mSensors;

    std::unique_ptr<AidlMessageQueue<Event, SynchronizedReadWrite>> mEventQueue;
    std::unique_ptr<AidlMessageQueue<int32_t, SynchronizedReadWrite>> mWakeLockQueue;
    EventFlag* mEventQueueFlag = nullptr;

    std::shared_ptr<ISensorsCallback> mCallback;

    std::thread mPollThread;
    std::thread mWakeLockThread;
    std::atomic_bool mStopThread{false};
    std::atomic_bool mReadWakeLockQueueRun{false};
    std::atomic<int32_t> mPollGeneration{0};

    std::mutex mWriteLock;
    std::mutex mWakeLockLock;
    int32_t mOutstandingWakeUpEvents = 0;
    int64_t mAutoReleaseWakeLockTime = 0;
    bool mHasWakeLock = false;
};

}  // namespace implementation
}  // namespace sensors
}  // namespace hardware
}  // namespace android
}  // namespace aidl

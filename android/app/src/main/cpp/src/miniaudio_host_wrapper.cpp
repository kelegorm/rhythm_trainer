#include <chrono>  // Для работы с временем
#include <cstdint> // Для int64_t
#include <algorithm> // std::fill
#include "dsp/core/audio_source.h"
#include "dsp/core/audio_config.h"
#include "dsp/core/audio_host.h"
#include "my_log.h"
#include "miniaudio/miniaudio.h"

using std::shared_ptr;
using std::make_shared;

class MiniaudioHostWrapper {
public:
    explicit MiniaudioHostWrapper(shared_ptr<AudioHost> host) : host_(std::move(host)) {}

    // 0 — OK, 1 — ошибка открытия, 2 — ошибка старта
    int start() {
        if (isStarted()) return 0;
        if (!host_) {
            alog("MiniaudioHostWrapper: host is null");
            return 1;
        }

        ma_device_config cfg = ma_device_config_init(ma_device_type_playback);
        cfg.playback.format   = ma_format_f32;
        cfg.playback.channels = 2; // стерео: AudioHost ожидает 2 канала
        cfg.sampleRate        = SAMPLE_RATE;
        cfg.dataCallback      = &MiniaudioHostWrapper::dataCallback;
        cfg.pUserData         = this;

        ma_result r = ma_device_init(nullptr, &cfg, &device_);
        if (r != MA_SUCCESS) {
            alog("miniaudio: device_init failed (%d)", (int)r);
            deviceInitialized_ = false;
            deviceStarted_ = false;
            return 1;
        }
        deviceInitialized_ = true;

        r = ma_device_start(&device_);
        if (r != MA_SUCCESS) {
            alog("miniaudio: device_start failed (%d)", (int)r);
            ma_device_uninit(&device_);
            deviceInitialized_ = false;
            deviceStarted_ = false;
            return 2;
        }

        deviceStarted_ = true;
        alog("miniaudio: started (sr=%u, ch=%u, period=%u)",
             device_.sampleRate,
             device_.playback.channels,
             device_.playback.internalPeriodSizeInFrames);
        return 0;
    }

    void stop() {
        if (deviceStarted_) {
            ma_device_stop(&device_);
        }
        if (deviceInitialized_) {
            ma_device_uninit(&device_);
        }
        deviceStarted_ = false;
        deviceInitialized_ = false;
    }

    bool isStarted() const { return deviceStarted_; }

private:
    // miniaudio callback → AudioHost::process
    static void dataCallback(ma_device* dev, void* out, const void* in, ma_uint32 frames) {
        (void)in;
        auto* self = static_cast<MiniaudioHostWrapper*>(dev->pUserData);
        if (!self || !out) return;

        float* outF = static_cast<float*>(out);
        const ma_uint32 ch = dev->playback.channels;

        if (!self->host_ || ch != 2) {
            std::fill(outF, outF + frames * ch, 0.0f);
            return;
        }

        // AudioHost ожидает интерливный стерео-буфер float32 длиной frames*2
        self->host_->process(outF, static_cast<int>(frames));
    }

    // Держим состояние устройства
    ma_device device_{};
    bool deviceInitialized_ = false;
    bool deviceStarted_ = false;

    shared_ptr<AudioHost> host_;
};
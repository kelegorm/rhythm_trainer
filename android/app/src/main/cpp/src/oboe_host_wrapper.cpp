#include <chrono>  // Для работы с временем
#include <cstdint> // Для int64_t
#include <algorithm> // std::fill
#include <oboe/Oboe.h>
#include "dsp/core/audio_source.h"
#include "dsp/core/audio_config.h"
#include "dsp/core/audio_host.h"
#include "my_log.h"

using std::shared_ptr;
using std::make_shared;

class OboeHostWrapper {
public:
    explicit OboeHostWrapper(shared_ptr<AudioHost> host) : host_(std::move(host)) {}

    // 0 — OK, 1 — ошибка открытия, 2 — ошибка старта
    int start() {
        if (isStarted()) return 0;
        if (!host_) {
            alog("OboeHostWrapper: host is null");
            return 1;
        }

        callback_ = make_shared<HostCallback>(host_);
        oboe::AudioStreamBuilder builder = makeBuilder();
        builder.setDataCallback(callback_.get());

        oboe::Result result = builder.openStream(stream_);
        if (result != oboe::Result::OK) {
            alog("Failed to open stream");
            stream_.reset();
            callback_.reset();
            return 1;
        }
        alog("Opened stream: sampleRate = %d, framesPerBurst = %d, bufferSize = %d",
             stream_->getSampleRate(),
             stream_->getFramesPerBurst(),
             stream_->getBufferSizeInFrames());

        result = stream_->requestStart();
        if (result != oboe::Result::OK) {
            alog("Failed to start stream");
            stream_->close();
            stream_.reset();
            callback_.reset();
            return 2;
        }
        return 0;
    }

    void stop() {
        if (stream_) {
            stream_->stop();
            stream_->close();
            stream_.reset();
        }
        callback_.reset();
    }

    bool isStarted() const { return static_cast<bool>(stream_); }

private:
    // Внутренний callback, адаптирующий oboe к AudioHost
    class HostCallback : public oboe::AudioStreamDataCallback {
    public:
        explicit HostCallback(std::shared_ptr<AudioHost> host) : host_(std::move(host)) {}
        oboe::DataCallbackResult onAudioReady(oboe::AudioStream* stream,
                                              void* audioData,
                                              int32_t numFrames) override {
            auto out = static_cast<float*>(audioData);
            const int32_t channels = stream->getChannelCount();
            if (host_ && channels == 2) {
                host_->process(out, numFrames);
            } else if (out) {
                std::fill(out, out + numFrames * channels, 0.0f);
            }
            return oboe::DataCallbackResult::Continue;
        }
    private:
        shared_ptr<AudioHost> host_;
    };

    static oboe::AudioStreamBuilder makeBuilder() {
        oboe::AudioStreamBuilder builder;
        builder.setFormat(oboe::AudioFormat::Float)
                ->setBufferCapacityInFrames(512)
                ->setChannelCount(oboe::ChannelCount::Stereo)
                ->setSampleRate(SAMPLE_RATE)
                ->setPerformanceMode(oboe::PerformanceMode::LowLatency)
                ->setSharingMode(oboe::SharingMode::Exclusive);
        return builder;
    }

    shared_ptr<AudioHost> host_;
    shared_ptr<HostCallback> callback_;
    shared_ptr<oboe::AudioStream> stream_;
};
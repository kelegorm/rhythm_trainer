#include <chrono>  // Для работы с временем
#include <cstdint> // Для int64_t
#include <algorithm> // std::fill
#include <oboe/Oboe.h>
#include "dsp/core/audio_source.h"
#include "dsp/core/audio_config.h"
#include "dsp/core/audio_host.h"
#include "dsp/metronome.h"
#include "dsp/mixer.h"
#include "my_log.h"
#include "dsp/note.h"
#include "dsp/sampler.h"
#include "dsp/sequencer.h"
#include "dsp/transport.h"
#include "gen_wave.h"
#include "rhythm_trainer_session.h"
#include "ffi_structs.h"

using std::shared_ptr;
using std::make_shared;
using std::vector;

using InitCallback = void(*)(int);

void testGetSineWave();

oboe::AudioStreamBuilder makeOboeBuilder();

// Адаптер oboe::AudioStreamDataCallback - вызывает AudioHost::process
class HostOboeCallback : public oboe::AudioStreamDataCallback {
public:
    explicit HostOboeCallback(std::shared_ptr<AudioHost> host) : host_(host) {}

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
    std::shared_ptr<AudioHost> host_;
};

shared_ptr<oboe::AudioStream> globalStream;
std::shared_ptr<AudioHost> gHost;
std::shared_ptr<HostOboeCallback> gHostCallback;
std::shared_ptr<RhythmTrainerSession> gSession;

extern "C" {
    void initializeAudio(InitCallback callback) {
        alog("Started initializing Audio");
        if (globalStream != nullptr) return; // Поток уже открыт
        if (!gHost) {
            gHost = std::make_shared<AudioHost>(); // root по умолчанию — SilentSource
            gHostCallback = std::make_shared<HostOboeCallback>(gHost);
        }

//        testGetSineWave();

        oboe::AudioStreamBuilder myOboe = makeOboeBuilder(); // todo check if existed (but maybe not)
        myOboe.setDataCallback(gHostCallback.get());

        oboe::Result result = myOboe.openStream(globalStream);
        if (result != oboe::Result::OK) {
            if (callback) {
                callback(1);
            }

            alog("Failed to open stream");
            return;
        }
        alog("Opened stream: sampleRate = %d, framesPerBurst = %d, bufferSize = %d",
             globalStream->getSampleRate(),
             globalStream->getFramesPerBurst(),
             globalStream->getBufferSizeInFrames());

        result = globalStream->requestStart();
        if (result != oboe::Result::OK) {
            if (callback) {
                callback(2);
            }

            alog("Failed to start stream");
            return;
        }

        if (!gSession) {
            gSession = std::make_shared<RhythmTrainerSession>();
            gSession->init();
        }
        if (gHost) {
            gHost->swapSource(gSession);
        }

        if (callback) {
            callback(0);
        }

        alog("Audio is initialized");
    }

    void cleanupAudioStream() {
        if (globalStream) {
            globalStream->stop();
            globalStream->close();
            globalStream.reset();
        }
        gHostCallback.reset();
        gHost.reset();
        gSession.reset();
        alog("Audio stream cleaned up!");
    }

    /// leftData and rightData should be pointers to interlaced audio.
    /// leftLength and rightLength should be in frames.
    int setDrumSamples(
        const float* leftData, int leftLength,
        const float* rightData, int rightLength
    ) {
        alog("setDrumSamples called: leftLength = %d, rightLength = %d", leftLength, rightLength);
        // Для теста можно добавить проверку на nullptr
        if (leftData == nullptr || rightData == nullptr) {
            alog("Error: one of the sample pointers is null.");
            return 1;
        }

        if (leftLength == 0 || rightLength == 0) {
            alog("Length of one of samples is 0");
            return 2;
        }

        vector<float> leftVector(leftData, leftData + leftLength * 2);
        vector<float> rightVector(rightData, rightData + rightLength * 2);

        auto leftSound = make_shared<Wave>(leftVector);
        auto rightSound = make_shared<Wave>(rightVector);

        if (gSession) {
            gSession->assignDrumWaves(leftSound, rightSound);
        }

        return 0;
    }

    int setDrumSequence(const SequenceFFI* seq) {
        if (!seq || seq == nullptr) {
            alog("Pointer to a sequence is invalid");
            return -1; // means data transfer failed.
        }

        if (seq->noteCount < 0 || seq->sequenceLength < 0.0) {
            return 1; // means data is not valid.
        }

        vector<Note> notes;
        for (int i = 0; i < seq->noteCount; ++i) {
            auto ffiNote = seq->notes + i;
            if (ffiNote && ffiNote != nullptr && ffiNote->noteId >=0 && ffiNote->startBeat >= 0.0) {
                notes.push_back(Note{
                    static_cast<size_t>(ffiNote->noteId),
                    ffiNote->startBeat
                });
            }
        }

        if (gSession) {
            gSession->applySequence(notes, seq->sequenceLength);
        }

        return 0;
    }

    void playLeft() {
        if (globalStream == nullptr) {
            alog("Audio stream is not initialized!");
            return;
        }
        if (gSession) gSession->hitLeft();
    }

    void playRight() {
        if (globalStream == nullptr) {
            alog("Audio stream is not initialized!");
            return;
        }
        if (gSession) gSession->hitRight();
    }

    void runScene(int8_t metronomeEnabled, int8_t sequenceEnabled, double temp) {
        bool metronomeBool = (metronomeEnabled != 0);
        bool sequenceBool = (sequenceEnabled != 0);

        if (gSession) {
            gSession->setMetronomeEnabled(metronomeBool);
            gSession->setSequenceEnabled(sequenceBool);
            gSession->setTempoBpm(static_cast<double>(temp));
            gSession->startTransport();
        }
    }

    void stopScene() {
        if (gSession) gSession->stopTransport();
    }
}

oboe::AudioStreamBuilder makeOboeBuilder() {
    oboe::AudioStreamBuilder builder;

    builder.setFormat(oboe::AudioFormat::Float)
            ->setBufferCapacityInFrames(512)
            ->setChannelCount(oboe::ChannelCount::Stereo)
            ->setSampleRate(SAMPLE_RATE)
            ->setPerformanceMode(oboe::PerformanceMode::LowLatency)
            ->setSharingMode(oboe::SharingMode::Exclusive);

    return builder;
}

//--------------
// UTIL STUFF
//--------------

//void measureTime() {
//    auto currentTime = high_resolution_clock::now();
//    auto duration = duration_cast<microseconds>(currentTime - startTime).count();
//    alog("Time since start playing: %d microsec", duration);
//}

void testGetSineWave() {
    using namespace std::chrono;
    const int iterations = 1000;
    volatile int totalFrames = 0;  // volatile для предотвращения оптимизации

    auto start = high_resolution_clock::now();
    for (int i = 0; i < iterations; i++) {
        // Например, генерируем синусоиду с sampleCount = 4024 и частотой 300 Гц
        Wave wave = getSineWave(4024, 300.0f + i);
        totalFrames += wave.numFrames;
    }
    auto end = high_resolution_clock::now();

    auto duration = duration_cast<milliseconds>(end - start).count();

    alog("Sine by sinf. Time, ms: %d, total frames: %d", duration, totalFrames);
}
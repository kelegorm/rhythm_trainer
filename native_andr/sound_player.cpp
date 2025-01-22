#include <android/log.h>
#include <chrono>  // Для работы с временем
#include <cstdint> // Для int64_t
#include <math.h>
#include <oboe/Oboe.h>
#include <stdarg.h>
#include <stdlib.h>

#define LOG_TAG "Native Sound PLayer"
#define SAMPLE_RATE 48000
#define FREQUENCY 880.0  // Частота синусоиды в Гц
#define FREQUENCY2 1760.0  // Частота синусоиды в Гц

using namespace std::chrono;

typedef struct {
    float* data;
    int length;
} Wave;

void alog(const char *message, ...);
Wave getSinewave(int sample_count, float freq);
void logWave(Wave wave);
oboe::AudioStreamBuilder makeOboeBuilder();
void measureTime();

steady_clock::time_point startTime;
bool isPlaying = false;
Wave wave = getSinewave(1024, FREQUENCY);
Wave wave2 = getSinewave(1024, FREQUENCY2);

class AudioCallback : public oboe::AudioStreamDataCallback {
public:
    AudioCallback(Wave wave) : wave(wave) {}

    oboe::DataCallbackResult onAudioReady(oboe::AudioStream* stream, void* audioData, int32_t numFrames) override {
        auto currentTime = high_resolution_clock::now();
        auto duration = duration_cast<milliseconds>(currentTime - startTime).count();

        if (duration >= 30) {
            // Останавливаем поток после 0.08 секунды
            isPlaying = false;
        } else {
            alog("onAudioReady is called!! NumFrames is %d, duration is %lld", numFrames, duration);
        }

        // Заменим данные в потоке на синусоиду
        auto *outputData = static_cast<float *>(audioData);
        if (isPlaying) {
            for (int i = 0; i < numFrames; ++i) {
                outputData[i] = wave.data[i];
            }
        } else {
            for (int i = 0; i < numFrames; ++i) {
                outputData[i] = 0;
            }
        }

        return oboe::DataCallbackResult::Continue;
    }

    void setWave(Wave newWave) {
        wave = newWave;
    }
private:
    Wave wave;
};

oboe::AudioStream* globalStream = nullptr;
AudioCallback* globalCallback = nullptr;

extern "C" {
    void initializeAudio() {
        alog("initializeAudio");
        if (globalStream != nullptr) return; // Поток уже открыт

        oboe::AudioStreamBuilder myOboe = makeOboeBuilder(); // todo check if existed (but maybe not)
        globalCallback = new AudioCallback({nullptr, 0});
        myOboe.setDataCallback(globalCallback);

        oboe::Result result = myOboe.openStream(&globalStream);
        if (result != oboe::Result::OK) {
            alog("Failed to open stream");
            return;
        }

        result = globalStream->requestStart();
        if (result != oboe::Result::OK) {
            alog("Failed to start stream");
            return;
        }

        alog("Audio is initialized");
    }

    void cleanupAudioStream() {
        if (globalStream != nullptr) {
            globalStream->stop();
            globalStream->close();
            globalStream = nullptr;
        }
        delete globalCallback;
        globalCallback = nullptr;
        alog("Audio stream cleaned up!");
    }

    void playLeft() {
        if (globalStream == nullptr || globalCallback == nullptr) {
            alog("Audio stream is not initialized!");
            return;
        }
        if (isPlaying) {
            return;
        }

        isPlaying = true;
        startTime = high_resolution_clock::now();  // Запоминаем время начала

        globalCallback->setWave(wave); // Запушаем волноформу в AudioCallback
    }

    void playRight() {
        if (globalStream == nullptr || globalCallback == nullptr) {
            alog("Audio stream is not initialized!");
            return;
        }
        if (isPlaying) {
            return;
        }
        isPlaying = true;
        startTime = high_resolution_clock::now();  // Запоминаем время начала

        globalCallback->setWave(wave2);
    }

}

oboe::AudioStreamBuilder makeOboeBuilder() {
    oboe::AudioStreamBuilder builder;

    builder.setFormat(oboe::AudioFormat::Float)
            ->setBufferCapacityInFrames(128)
            ->setChannelCount(oboe::ChannelCount::Stereo)
            ->setSampleRate(SAMPLE_RATE)
            ->setPerformanceMode(oboe::PerformanceMode::LowLatency)
            ->setSharingMode(oboe::SharingMode::Exclusive);

    return builder;
}

Wave getSinewave(int sample_count, float freq) {
    Wave result;
    result.data = (float*)malloc(sample_count * sizeof(float));

    if (result.data == NULL) {
        alog("Memory allocation failed for sine wave generating.");
        result.length = 0;
        return result;
    }

    result.length = sample_count;

    const float twoPi = 6.283185307179586476925286766559f;
    for (int i = 0; i < sample_count; i++) {
        result.data[i] = sinf(twoPi * freq * ((float)i / SAMPLE_RATE));
    }

    return result;
}


//--------------
// UTIL STUFF
//--------------

void alog(const char *message, ...) {
    va_list args;
    va_start(args, message);
    __android_log_vprint(ANDROID_LOG_INFO, LOG_TAG, message, args);
    va_end(args);
}

void measureTime() {
    auto currentTime = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(currentTime - startTime).count();
    alog("Time since start playing: %d microsec", duration);
}

void logWave(Wave wave) {
    // Выводим первые 10 значений синусоиды в лог для проверки.
    alog("Generated Sine Wave Samples (Length: %d):", wave.length);
    for (int i = 0; i < 10 && i < wave.length; i++) {
        alog("Sample %d: %f", i, wave.data[i]);
    }
}
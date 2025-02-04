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
    int length; // длинна в семплах
    int currentIndex;  // Текущий индекс воспроизведения
    bool isPlaying;    // Активен ли звук
} Wave;

void alog(const char *message, ...);
Wave getSinewave(int sample_count, float freq);
void logWave(Wave wave);
oboe::AudioStreamBuilder makeOboeBuilder();
//void measureTime();

Wave leftSound = getSinewave(1024, FREQUENCY);
Wave rightSound = getSinewave(1024, FREQUENCY2);

class AudioCallback : public oboe::AudioStreamDataCallback {
public:
//    AudioCallback(Wave wave) : wave(wave) {}
    AudioCallback() {}

    oboe::DataCallbackResult onAudioReady(oboe::AudioStream* stream, void* audioData, int32_t numFrames) override {
        auto *outputData = static_cast<float *>(audioData);

        for (int i = 0; i < numFrames; ++i) {
            float sample = 0.0f;

            if (leftSound.isPlaying) {
                sample += leftSound.data[leftSound.currentIndex] + 0.3f;
                leftSound.currentIndex++;

                // Проверить завершение звука
                if (leftSound.currentIndex >= leftSound.length) {
                    leftSound.isPlaying = false;  // Остановить звук
                    leftSound.currentIndex = 0;  // Сбросить индекс
                }
            }

            if (rightSound.isPlaying) {
                sample += rightSound.data[rightSound.currentIndex] + 0.3f;
                rightSound.currentIndex++;

                // Проверить завершение звука
                if (rightSound.currentIndex >= rightSound.length) {
                    rightSound.isPlaying = false;  // Остановить звук
                    rightSound.currentIndex = 0;  // Сбросить индекс
                }
            }

            // Предотвратить клиппинг
            if (sample > 1.0f) sample = 1.0f;
            if (sample < -1.0f) sample = -1.0f;

            outputData[i] = sample;
        }

        return oboe::DataCallbackResult::Continue;
    }

//    void setWave(Wave newWave) {
//        wave = newWave;
//    }
//private:
//    Wave wave;
};

oboe::AudioStream* globalStream = nullptr;
AudioCallback* globalCallback = nullptr;

extern "C" {
    void initializeAudio() {
        alog("initializeAudio");
        if (globalStream != nullptr) return; // Поток уже открыт

        oboe::AudioStreamBuilder myOboe = makeOboeBuilder(); // todo check if existed (but maybe not)
        globalCallback = new AudioCallback();
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

        leftSound.isPlaying = true;
        leftSound.currentIndex = 0;
    }

    void playRight() {
        if (globalStream == nullptr || globalCallback == nullptr) {
            alog("Audio stream is not initialized!");
            return;
        }

        rightSound.isPlaying = true;
        rightSound.currentIndex = 0;
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

    result.currentIndex = 0;
    result.isPlaying = false;

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

//void measureTime() {
//    auto currentTime = high_resolution_clock::now();
//    auto duration = duration_cast<microseconds>(currentTime - startTime).count();
//    alog("Time since start playing: %d microsec", duration);
//}

void logWave(Wave wave) {
    // Выводим первые 10 значений синусоиды в лог для проверки.
    alog("Generated Sine Wave Samples (Length: %d):", wave.length);
    for (int i = 0; i < 10 && i < wave.length; i++) {
        alog("Sample %d: %f", i, wave.data[i]);
    }
}
#include <android/log.h>
#include <math.h>
#include <oboe/Oboe.h>
#include <stdarg.h>
#include <stdlib.h>
#include <chrono>  // Для работы с временем
using namespace std::chrono;

steady_clock::time_point startTime;
bool isPlaying = false;

#define LOG_TAG "Native Sound PLayer"
#define SAMPLE_RATE 44100
#define FREQUENCY 440.0  // Частота синусоиды в Гц

// Структура для хранения синусоиды и её длины.
typedef struct {
    float* data;
    int length;
} Wave;

void alog(const char *message, ...);
Wave getSinewave(int sample_count);
void logWave(Wave wave);
oboe::AudioStreamBuilder makeOboeBuilder();

class AudioCallback : public oboe::AudioStreamDataCallback {
        public:
        AudioCallback(Wave wave) : wave(wave) {}

        oboe::DataCallbackResult onAudioReady(oboe::AudioStream* stream, void* audioData, int32_t numFrames) override {
            // Проверка времени, прошло ли 0.1 секунды
            auto currentTime = high_resolution_clock::now();
            auto duration = duration_cast<milliseconds>(currentTime - startTime).count();

            alog("onAudioReady is called!! NumFrames is %d, duration is %lld", numFrames, duration);

            if (duration >= 200) {
                // Останавливаем поток после 0.2 секунды
                isPlaying = false;
                return oboe::DataCallbackResult::Stop;
            }

            // Заменим данные в потоке на синусоиду
            auto *outputData = static_cast<float *>(audioData);
            for (int i = 0; i < numFrames; ++i) {
                outputData[i] = wave.data[i];
            }

            return oboe::DataCallbackResult::Continue;
        }
        private:
        Wave wave;
};

//--------------
// PUBLIC STUFF
//--------------
extern "C" {
    void playLeft() {
        alog("Play Left!");

        if (isPlaying) {
            // Уже воспроизводится, ничего не делаем
            return;
        }
        isPlaying = true;
        startTime = high_resolution_clock::now();  // Запоминаем время начала

        Wave wave = getSinewave(1024);
//        logWave(wave);

        oboe::AudioStreamBuilder myOboe = makeOboeBuilder();
        alog("playLeft:: myOboe is created!");

        myOboe.setDataCallback(new AudioCallback(wave));

        alog("playLeft:: AudioCallback is set!");

        oboe::AudioStream* stream = nullptr;
        oboe::Result result = myOboe.openStream(&stream);
        if (result != oboe::Result::OK) {
            alog("Failed to open stream");
            return;
        }

        result = stream->requestStart();
        if (result != oboe::Result::OK) {
            alog("Failed to start stream");
            return;
        }

        alog("Stream is started!");
    }
}

//--------------
// PRIVATE STUFF
//--------------

oboe::AudioStreamBuilder makeOboeBuilder() {
    oboe::AudioStreamBuilder builder;

    builder.setFormat(oboe::AudioFormat::Float)
            ->setBufferCapacityInFrames(512)
            ->setChannelCount(oboe::ChannelCount::Mono)
            ->setSampleRate(SAMPLE_RATE)
            ->setPerformanceMode(oboe::PerformanceMode::LowLatency)
            ->setSharingMode(oboe::SharingMode::Exclusive);

    return builder;
}

void logWave(Wave wave) {
    // Выводим первые 10 значений синусоиды в лог для проверки.
    alog("Generated Sine Wave Samples (Length: %d):", wave.length);
    for (int i = 0; i < 10 && i < wave.length; i++) {
        alog("Sample %d: %f", i, wave.data[i]);
    }
}

Wave getSinewave(int sample_count) {
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
        result.data[i] = sinf(twoPi * FREQUENCY * ((float)i / SAMPLE_RATE));
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
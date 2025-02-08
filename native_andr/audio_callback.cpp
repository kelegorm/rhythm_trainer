#include "audio_callback.h"

oboe::DataCallbackResult AudioCallback::onAudioReady(oboe::AudioStream* stream, void* audioData, int32_t numFrames) {
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

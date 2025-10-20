#pragma once

#include "audio_source.h"
#include "../silent_source.h"
#include <memory>

class AudioHost {
public:
    AudioHost();

    // Рендерит следующий буфер в out.
    void process(float* out, int32_t frames);

    // Горячая замена корневого источника
    void swapSource(std::shared_ptr<IAudioSource> newRoot);

private:
    std::shared_ptr<IAudioSource> root_;
};
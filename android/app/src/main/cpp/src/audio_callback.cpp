#include "audio_callback.h"
#include <chrono>
#include <thread>

using std::shared_ptr;
using namespace std::chrono;

AudioCallback::AudioCallback(
    const shared_ptr<Transport>& transport,
    const shared_ptr<Mixer>& mixer
)
    : transport(transport),
      mixer(mixer)
{

}

oboe::DataCallbackResult AudioCallback::onAudioReady(oboe::AudioStream* stream, void* audioData, int32_t numFrames) {
    counter++;
    int bufferDuration = (numFrames * 1000000) / SAMPLE_RATE; // microseconds
    bool framesChanged = (numFrames != previousNumFrames);
    int busyWaitDuration = bufferDuration - 3 * storedMixTime - 200;

    if (framesChanged) {
        previousNumFrames = numFrames;
        storedMixTime = 0;
    }

    logXRun(stream);

    auto start = high_resolution_clock::now();

    if (transport->isPlaying() && !framesChanged && busyWaitDuration > 0) { // busy wait
        auto deadline = start + microseconds(busyWaitDuration);

        while (high_resolution_clock::now() < deadline) {
            std::this_thread::yield();
        }
    }


    auto *outputData = static_cast<float *>(audioData);

    auto mixStart = high_resolution_clock::now();
    mixer->mix(outputData, numFrames);
    auto mixEnd = high_resolution_clock::now();

    auto total = duration_cast<microseconds>(mixEnd - start).count();
    auto mixDuration = duration_cast<microseconds>(mixEnd - mixStart).count();
    if (mixDuration > storedMixTime) {
        storedMixTime = mixDuration;
    }

//    if (counter % 100 == 0) {
//        alog("Total dur: %d, frames: %d, busy dur: %d", total, numFrames, busyWaitDuration);
//    }

    transport->update(numFrames);

    return oboe::DataCallbackResult::Continue;
}

void AudioCallback::logXRun(oboe::AudioStream* stream) {
    if (counter % 100 == 0) {
        auto result = stream->getXRunCount();
        if (result) {
            if (result.value() > 0) {
                alog("XRun count: %d", result.value());
            }
        } else {
            alog("Failed to get XRun count: %s", oboe::convertToText(result.error()));
        }
    }
}

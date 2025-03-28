#include "audio_callback.h"

using std::shared_ptr;

AudioCallback::AudioCallback(
    const shared_ptr<Transport>& transport,
    const shared_ptr<Mixer>& mixer
)
    : transport(transport),
      mixer(mixer)
{

}

oboe::DataCallbackResult AudioCallback::onAudioReady(oboe::AudioStream* stream, void* audioData, int32_t numFrames) {
    auto *outputData = static_cast<float *>(audioData);

    mixer->mix(outputData, numFrames);

    transport->update(numFrames);

    return oboe::DataCallbackResult::Continue;
}

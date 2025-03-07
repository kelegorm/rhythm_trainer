#include "../include/audio_config.h"
#include "../include/metronome.h"
#include "../include/my_log.h"
#include <cmath>
#include <cstring>

using std::round;
using std::ceil;
using std::shared_ptr;

Metronome::Metronome(
    const shared_ptr<Transport>& transport,
    const shared_ptr<const Wave>& sound1,
    const shared_ptr<const Wave>& sound2
)
    : isEnabled(false),
      transport(transport)
{
    sound1Sampler.setWave(sound1);
    sound2Sampler.setWave(sound2);
}

void Metronome::run() {
    isEnabled = true;
    sound1Sampler.trigger(0);
}

void Metronome::stop() {
    isEnabled = false;
    sound1Sampler.stop();
    sound2Sampler.stop();
}

void Metronome::getSamples(float *buffer, int numFrames) {
    // Если транспорт не играет, заполняем буфер тишиной и выходим
    if (!transport->isPlaying() || !isEnabled) {
        memset(buffer, 0, sizeof(float) * numFrames * 2);
        return;
    }

    int globalStart = transport->getCurrentSample();
    int globalEnd = globalStart + numFrames;

    int nextTickNumber = static_cast<int>(ceil(globalStart / transport->framesPerBeat()));
    double nextTickTime = nextTickNumber * transport->framesPerBeat();

    if (nextTickTime < globalEnd) {
        int offset = (int)(round(nextTickTime - globalStart));

        if (nextTickNumber % 4 == 0) {
            sound2Sampler.trigger(offset);   // Sound2 on the first tick
        } else {
            sound1Sampler.trigger(offset);   // Sound1 on the next three ticks
        }
    }

    if (sound1Sampler.isPlaying) {
        sound1Sampler.getSamples(buffer, numFrames);
    } else {
        sound2Sampler.getSamples(buffer, numFrames);
    }
}
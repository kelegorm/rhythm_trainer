#include "mixer.h"
#include "my_log.h"
#include "sampler.h"
#include "sequencer.h"
#include <algorithm>
#include <cmath>
#include <cstring>

using std::fmod;
using std::make_shared;
using std::round;
using std::shared_ptr;
using std::sort;
using std::vector;

Sequencer::Sequencer(Transport* transport, const vector<Note>& notes, const vector<Wave>& soundBank, double loopLengthBeats)
        : transport(transport), loopLengthBeats(loopLengthBeats), isEnabled(true)
{
    double fpb = transport->framesPerBeat();
    loopLengthFrames = loopLengthBeats * fpb;

    for (const auto& note : notes) {
        NoteEvent event;
        event.soundId = note.soundId;
        event.startFrame = note.startBeat * fpb;
        events.push_back(event);
    }
    
    // Сортируем события по времени
    sort(events.begin(), events.end(), [](const NoteEvent& a, const NoteEvent& b) {
        return a.startFrame < b.startFrame;
    });

    samplers.reserve(soundBank.size());
    for (size_t i = 0; i < soundBank.size(); i++) {
        auto sampler = make_shared<Sampler>(soundBank[i]);
        samplers.push_back(sampler);
        internalMixer.addSource(sampler);
    }
}

Sequencer::~Sequencer() {
    events.clear();
    samplers.clear();
}

void Sequencer::getSamples(float* buffer, int numFrames) {
    if (!transport->isPlaying() || !isEnabled) {
        memset(buffer, 0, sizeof(float) * numFrames * 2);
        return;
    }

    int posInLoop = fmod(static_cast<double>(transport->getCurrentSample()), loopLengthFrames);

    auto shiftedEvents = getShiftedEvents(events, loopLengthFrames, posInLoop);
    for (const auto& event : shiftedEvents) {
        int offset = static_cast<int>(round(event.startFrame));
        if (offset >= 0 && offset < numFrames) {
            samplers[event.soundId]->trigger(offset);
        }
    }

    internalMixer.mix(buffer, numFrames);
}

vector<Sequencer::NoteEvent> Sequencer::getShiftedEvents(const vector<NoteEvent>& events, double loopLengthFrames, double loopStart) {
    vector<NoteEvent> shiftedEvents;
    for (const auto& event : events) {
        int shifted = event.startFrame - loopStart;
        if (shifted < 0) {
            shifted += loopLengthFrames;
        }

        NoteEvent shiftedEvent = event; 
        shiftedEvent.startFrame = shifted;
        shiftedEvents.push_back(shiftedEvent);
    }
    return shiftedEvents;
}
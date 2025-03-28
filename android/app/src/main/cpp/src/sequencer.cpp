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

Sequencer::Sequencer(
    const shared_ptr<Transport>& transport,
    const vector<Note>& notes,
    const vector<shared_ptr<const Wave>>& soundBank,
    double loopLengthBeats
)
    : transport(transport), loopLengthBeats(loopLengthBeats), isEnabled(false)
{
    setSequence(notes, loopLengthBeats);

    setSounds(soundBank);
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

    double posInLoop = fmod(static_cast<double>(transport->getCurrentSample()), loopLengthFrames);

    auto shiftedEvents = getShiftedEvents(events, loopLengthFrames, posInLoop);
    for (const auto& event : shiftedEvents) {
        int offset = static_cast<int>(round(event.startFrame));
        if (offset >= 0 && offset < numFrames) {
            samplers[event.soundId]->trigger(offset);
        }
    }

    internalMixer.mix(buffer, numFrames);
}

void Sequencer::setSequence(const vector<Note>& notes, double length) {
    loopLengthBeats = length;

    double fpb = transport->framesPerBeat();
    loopLengthFrames = length * fpb;

    for (const auto& note : notes) {
        events.push_back(NoteEvent{note.soundId, note.startBeat * fpb});
    }

    // Сортируем события по времени
    sort(events.begin(), events.end(), [](const NoteEvent& a, const NoteEvent& b) {
        return a.startFrame < b.startFrame;
    });
}

void Sequencer::setSounds(const vector<shared_ptr<const Wave>>& newSoundBank) {
    samplers.clear();
    internalMixer.clear();

    samplers.reserve(newSoundBank.size());

    for (const auto & wave : newSoundBank) {
        auto sampler = make_shared<Sampler>(wave);
        samplers.push_back(sampler);
        internalMixer.addSource(sampler);
    }
}

vector<Sequencer::NoteEvent> Sequencer::getShiftedEvents(const vector<NoteEvent>& events, double loopLengthFrames, double loopStart) {
    vector<NoteEvent> shiftedEvents;
    for (const auto& event : events) {
        auto shifted = event.startFrame - loopStart;
        if (shifted < 0) {
            shifted += loopLengthFrames;
        }

        NoteEvent shiftedEvent = event; 
        shiftedEvent.startFrame = shifted;
        shiftedEvents.push_back(shiftedEvent);
    }
    return shiftedEvents;
}
#pragma once

#include <vector>
#include "audio_source.h"
#include "note.h"
#include "sampler.h"
#include "transport.h"
#include "waveforms.h"

class Sequencer : public AudioSource {
public:
    Sequencer(Transport* transport, const std::vector<Note>& notes, const std::vector<Wave>& soundBank, double loopLength);
    ~Sequencer();

    void getSamples(float* buffer, int numFrames) override;

    void setEnabled(bool enabled) { isEnabled = enabled; }

private:
    struct NoteEvent {
        int soundId;
        double startFrame;
    };

    static std::vector<NoteEvent> getShiftedEvents(const std::vector<NoteEvent>& events, double loopLengthFrames, double posInLoop);

    Transport* transport;
    std::vector<NoteEvent> events;
    std::vector<std::shared_ptr<Sampler>> samplers;
    double loopLengthBeats;
    double loopLengthFrames;  // Длина лупа в фреймах
    bool isEnabled;

    Mixer internalMixer;
};
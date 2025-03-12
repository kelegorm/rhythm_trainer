#pragma once

#include <memory>
#include <vector>
#include "audio_source.h"
#include "note.h"
#include "sampler.h"
#include "transport.h"
#include "waveforms.h"

class Sequencer : public AudioSource {
public:
    /**
     * @brief Constructs a Sequencer.
     *
     * @param transport Pointer to the Transport.
     * @param notes Vector of notes (beat-based).
     * @param soundBank Vector of shared pointers to Wave objects.
     * @param loopLength Length of the loop in beats.
     */
    Sequencer(
        const std::shared_ptr<Transport>& transport,
        const std::vector<Note>& notes,
        const std::vector<std::shared_ptr<const Wave>>& soundBank,
        double loopLength
    );
    ~Sequencer() override;

    void getSamples(float* buffer, int numFrames) override;

    void setEnabled(bool enabled) { isEnabled = enabled; }

    void setSequence(const std::vector<Note>& notes, double length);

private:
    struct NoteEvent {
        size_t soundId;
        double startFrame;
    };

    static std::vector<NoteEvent> getShiftedEvents(const std::vector<NoteEvent>& events, double loopLengthFrames, double posInLoop);

    const std::shared_ptr<Transport> transport;
    std::vector<NoteEvent> events;
    std::vector<std::shared_ptr<Sampler>> samplers;
    double loopLengthBeats;
    double loopLengthFrames;  // Длина лупа в фреймах
    bool isEnabled;

    Mixer internalMixer;
};
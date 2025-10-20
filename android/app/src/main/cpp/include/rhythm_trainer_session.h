//
// Created by Dmitry on 20.10.25..
//

// ===== RhythmTrainerSession.h =====
#pragma once

#include <cstdint>
#include <memory>
#include <vector>
#include "dsp/core/audio_source.h"
// Need full definition because std::vector<Note> appears in the public API
#include "dsp/note.h"

// Forward declarations keep the header light; full headers are included in the .cpp
class Mixer;
class Sampler;
class Transport;
class Metronome;
class Sequencer;
class Wave;

class RhythmTrainerSession : public IAudioSource {
public:
    RhythmTrainerSession() = default;

    // Полная сборка сцены. Можно вызывать повторно для реинициализации.
    void init();

    // IAudioSource
    void getSamples(float* out, int32_t numFrames) override;
    float getVolume() override;

    // Управление сценой (без FFI-логики)
    void assignDrumWaves(const std::shared_ptr<Wave>& left, const std::shared_ptr<Wave>& right);
    void applySequence(const std::vector<Note>& notes, double lengthBeats);

    void hitLeft();
    void hitRight();

    void setMetronomeEnabled(bool on);
    void setSequenceEnabled(bool on);

    void setTempoBpm(double bpm);
    void startTransport();
    void stopTransport();

private:
    std::shared_ptr<Mixer> mixer_;
    std::shared_ptr<Sampler> leftSampler_;
    std::shared_ptr<Sampler> rightSampler_;
    std::shared_ptr<Transport> transport_;
    std::shared_ptr<Metronome> metronome_;
    std::shared_ptr<Sequencer> rhythm_;
};
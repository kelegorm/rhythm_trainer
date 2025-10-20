//
// Created by Dmitry on 20.10.25..
//
#include "rhythm_trainer_session.h"

#include <algorithm>
#include <memory>
#include <vector>

#include "dsp/mixer.h"
#include "dsp/sampler.h"
#include "dsp/transport.h"
#include "dsp/metronome.h"
#include "dsp/sequencer.h"
#include "dsp/note.h"
#include "gen_wave.h"

using std::make_shared;
using std::shared_ptr;
using std::vector;

void RhythmTrainerSession::init() {
    mixer_ = make_shared<Mixer>();

    // Базовые источники — простые синусы, чтобы сразу что-то слышать
    leftSampler_  = make_shared<Sampler>(make_shared<Wave>(getSineWave(4024, 300.0f)));
    rightSampler_ = make_shared<Sampler>(make_shared<Wave>(getSineWave(3024, 600.0f)));

    transport_ = make_shared<Transport>(120);

    auto met1 = make_shared<Wave>(getSineWave(2612, 800.0f));
    auto met2 = make_shared<Wave>(getSineWave(2612, 1600.0f));
    metronome_ = make_shared<Metronome>(transport_, met1, met2);

    // Простейшая 4/4 секвенция
    vector<Note> notes = {
        {0, 0.001},
        {1, 1.0},
        {0, 2.0},
        {1, 3.0},
    };
    vector<shared_ptr<const Wave>> bank = {
        make_shared<Wave>(getSineWave(1256, 1600.0f)),
        make_shared<Wave>(getSineWave(1256, 800.0f)),
    };
    rhythm_ = make_shared<Sequencer>(transport_, notes, bank, 4.0);

    // Подключаем все к микшеру
    mixer_->addSource(leftSampler_);
    mixer_->addSource(rightSampler_);
    mixer_->addSource(metronome_);
    mixer_->addSource(rhythm_);
}

void RhythmTrainerSession::getSamples(float* out, int32_t numFrames) {
    std::fill(out, out + numFrames * 2, 0.0f);
    if (!mixer_) return;

    mixer_->mix(out, numFrames);
    if (transport_) transport_->update(numFrames);
}

float RhythmTrainerSession::getVolume() {
    return 1.0f;
}

void RhythmTrainerSession::assignDrumWaves(const shared_ptr<Wave>& left, const shared_ptr<Wave>& right) {
    if (leftSampler_)  leftSampler_->setWave(left);
    if (rightSampler_) rightSampler_->setWave(right);

    // Обновим банк для секвенсора, если он есть
    if (rhythm_) {
        vector<shared_ptr<const Wave>> newBank;
        newBank.push_back(left);
        newBank.push_back(right);
        rhythm_->setSounds(newBank);
    }
}

void RhythmTrainerSession::applySequence(const vector<Note>& notes, double lengthBeats) {
    if (rhythm_) rhythm_->setSequence(notes, lengthBeats);
}

void RhythmTrainerSession::hitLeft()  { if (leftSampler_)  leftSampler_->trigger(); }
void RhythmTrainerSession::hitRight() { if (rightSampler_) rightSampler_->trigger(); }

void RhythmTrainerSession::setMetronomeEnabled(bool on) { if (metronome_) metronome_->setEnabled(on); }
void RhythmTrainerSession::setSequenceEnabled(bool on)  { if (rhythm_)    rhythm_->setEnabled(on);   }

void RhythmTrainerSession::setTempoBpm(double bpm) { if (transport_) transport_->setBPM(bpm); }
void RhythmTrainerSession::startTransport()        { if (transport_) transport_->play();     }
void RhythmTrainerSession::stopTransport()         { if (transport_) transport_->stop();     }
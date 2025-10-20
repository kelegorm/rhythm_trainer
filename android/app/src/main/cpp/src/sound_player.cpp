#include <chrono>  // Для работы с временем
#include <cstdint> // Для int64_t
#include <algorithm> // std::fill
#include "dsp/core/audio_host.h"
#include "dsp/metronome.h"
#include "dsp/mixer.h"
#include "my_log.h"
#include "dsp/note.h"
#include "dsp/sampler.h"
#include "dsp/sequencer.h"
#include "dsp/transport.h"
#include "gen_wave.h"
#include "rhythm_trainer_session.h"
#include "ffi_structs.h"
#include "oboe_host_wrapper.cpp"

using std::shared_ptr;
using std::make_shared;
using std::vector;

using InitCallback = void(*)(int);

void testGetSineWave();


shared_ptr<AudioHost> audioHost;
shared_ptr<OboeHostWrapper> oboeWrapper;
shared_ptr<RhythmTrainerSession> appAudioSession;

extern "C" {
    void initializeAudio(InitCallback callback) {
        alog("Started initializing Audio");
        if (oboeWrapper && oboeWrapper->isStarted()) return; // Поток уже открыт

        appAudioSession = make_shared<RhythmTrainerSession>();
        appAudioSession->init();

        audioHost = make_shared<AudioHost>();
        audioHost->swapSource(appAudioSession);

        oboeWrapper = make_shared<OboeHostWrapper>(audioHost);

        int err = oboeWrapper->start();
        if (err != 0) {
            if (callback) callback(err);
            alog("Audio init met error");
        } else {
            if (callback) callback(0);
            alog("Audio is initialized");
        }
    }

    void cleanupAudioStream() {
        if (oboeWrapper) {
            oboeWrapper->stop();
            oboeWrapper.reset();
        }
        audioHost.reset();
        appAudioSession.reset();
        alog("Audio stream cleaned up!");
    }

    /// leftData and rightData should be pointers to interlaced audio.
    /// leftLength and rightLength should be in frames.
    int setDrumSamples(
        const float* leftData, int leftLength,
        const float* rightData, int rightLength
    ) {
        alog("setDrumSamples called: leftLength = %d, rightLength = %d", leftLength, rightLength);
        // Для теста можно добавить проверку на nullptr
        if (leftData == nullptr || rightData == nullptr) {
            alog("Error: one of the sample pointers is null.");
            return 1;
        }

        if (leftLength == 0 || rightLength == 0) {
            alog("Length of one of samples is 0");
            return 2;
        }

        vector<float> leftVector(leftData, leftData + leftLength * 2);
        vector<float> rightVector(rightData, rightData + rightLength * 2);

        auto leftSound = make_shared<Wave>(leftVector);
        auto rightSound = make_shared<Wave>(rightVector);

        if (appAudioSession) {
            appAudioSession->assignDrumWaves(leftSound, rightSound);
        }

        return 0;
    }

    int setDrumSequence(const SequenceFFI* seq) {
        if (!seq || seq == nullptr) {
            alog("Pointer to a sequence is invalid");
            return -1; // means data transfer failed.
        }

        if (seq->noteCount < 0 || seq->sequenceLength < 0.0) {
            return 1; // means data is not valid.
        }

        vector<Note> notes;
        for (int i = 0; i < seq->noteCount; ++i) {
            auto ffiNote = seq->notes + i;
            if (ffiNote && ffiNote != nullptr && ffiNote->noteId >=0 && ffiNote->startBeat >= 0.0) {
                notes.push_back(Note{
                    static_cast<size_t>(ffiNote->noteId),
                    ffiNote->startBeat
                });
            }
        }

        if (appAudioSession) {
            appAudioSession->applySequence(notes, seq->sequenceLength);
        }

        return 0;
    }

    void playLeft() {
        if (!oboeWrapper || !oboeWrapper->isStarted()) {
            alog("Audio stream is not initialized!");
            return;
        }
        if (appAudioSession) appAudioSession->hitLeft();
    }

    void playRight() {
        if (!oboeWrapper || !oboeWrapper->isStarted()) {
            alog("Audio stream is not initialized!");
            return;
        }
        if (appAudioSession) appAudioSession->hitRight();
    }

    void runScene(int8_t metronomeEnabled, int8_t sequenceEnabled, double temp) {
        bool metronomeBool = (metronomeEnabled != 0);
        bool sequenceBool = (sequenceEnabled != 0);

        if (appAudioSession) {
            appAudioSession->setMetronomeEnabled(metronomeBool);
            appAudioSession->setSequenceEnabled(sequenceBool);
            appAudioSession->setTempoBpm(static_cast<double>(temp));
            appAudioSession->startTransport();
        }
    }

    void stopScene() {
        if (appAudioSession) appAudioSession->stopTransport();
    }
}



//--------------
// UTIL STUFF
//--------------

//void measureTime() {
//    auto currentTime = high_resolution_clock::now();
//    auto duration = duration_cast<microseconds>(currentTime - startTime).count();
//    alog("Time since start playing: %d microsec", duration);
//}

void testGetSineWave() {
    using namespace std::chrono;
    const int iterations = 1000;
    volatile int totalFrames = 0;  // volatile для предотвращения оптимизации

    auto start = high_resolution_clock::now();
    for (int i = 0; i < iterations; i++) {
        // Например, генерируем синусоиду с sampleCount = 4024 и частотой 300 Гц
        Wave wave = getSineWave(4024, 300.0f + i);
        totalFrames += wave.numFrames;
    }
    auto end = high_resolution_clock::now();

    auto duration = duration_cast<milliseconds>(end - start).count();

    alog("Sine by sinf. Time, ms: %d, total frames: %d", duration, totalFrames);
}
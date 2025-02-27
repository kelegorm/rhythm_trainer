#include <chrono>  // Для работы с временем
#include <cstdint> // Для int64_t
#include <oboe/Oboe.h>
#include "audio_callback.h"
#include "audio_config.h"
#include "metronome.h"
#include "mixer.h"
#include "my_log.h"
#include "note.h"
#include "sampler.h"
#include "sequencer.h"
#include "transport.h"
#include "waveforms.h"

using std::shared_ptr;
using std::make_shared;
using std::vector;
using namespace std::chrono;

using InitCallback = void(*)(int);

oboe::AudioStreamBuilder makeOboeBuilder();
//void measureTime();

oboe::AudioStream* globalStream = nullptr;
Mixer* globalMixer = nullptr;
shared_ptr<Sampler> leftSampler;
shared_ptr<Sampler> rightSampler;
shared_ptr<Metronome> metronome;
AudioCallback* globalCallback = nullptr;

extern "C" {
    void initializeAudio(InitCallback callback) {
        alog("initializeAudio");
        if (globalStream != nullptr) return; // Поток уже открыт

        // Создаем микшер
        globalMixer = new Mixer();

        // Создаем семплеры и задаем им звуки
        leftSampler = make_shared<Sampler>();
        rightSampler = make_shared<Sampler>();
        leftSampler->setWave(leftSound);
        rightSampler->setWave(rightSound);

        Transport* transport = new Transport(120);
        Wave metronomeSound1 = getSinewave(256, 800.0f);
        Wave metronomeSound2 = getSinewave(256, 1600.0f);
        metronome = make_shared<Metronome>(transport, metronomeSound1, metronomeSound2);
        metronome->run();

        vector<Note> notes;
        notes.push_back(Note{0, 0.001});  // сильный удар на 1-ю долю
        notes.push_back(Note{1, 1.0});  // слабый удар на 2-ю долю
        notes.push_back(Note{1, 2.0});  // слабый удар на 3-ю долю
        notes.push_back(Note{1, 3.0});  // слабый удар на 4-ю долю

        vector<Wave> soundBank;
        soundBank.push_back(getSinewave(256, 1600.0f)); // strong strike
        soundBank.push_back(getSinewave(256, 800.0f)); // weak

        shared_ptr<Sequencer> rhythmPlayer = make_shared<Sequencer>(transport, notes, soundBank, 4.0);

        // Регистрируем семплеры в микшере
        globalMixer->addSource(leftSampler);
        globalMixer->addSource(rightSampler);
        globalMixer->addSource(metronome);
        globalMixer->addSource(rhythmPlayer);

        globalCallback = new AudioCallback(transport, globalMixer);

        oboe::AudioStreamBuilder myOboe = makeOboeBuilder(); // todo check if existed (but maybe not)
        myOboe.setDataCallback(globalCallback);

        oboe::Result result = myOboe.openStream(&globalStream);
        if (result != oboe::Result::OK) {
            if (callback) {
                callback(1);
            }

            alog("Failed to open stream");
            return;
        }

        result = globalStream->requestStart();
        if (result != oboe::Result::OK) {
            if (callback) {
                callback(2);
            }

            alog("Failed to start stream");
            return;
        }

        if (callback) {
            callback(0);
        }

        alog("Audio is initialized");
    }

    void cleanupAudioStream() {
        if (globalStream != nullptr) {
            globalStream->stop();
            globalStream->close();
            globalStream = nullptr;
        }
        delete globalCallback;
        globalCallback = nullptr;
        alog("Audio stream cleaned up!");
    }

    void playLeft() {
        if (globalStream == nullptr || globalCallback == nullptr) {
            alog("Audio stream is not initialized!");
            return;
        }

        leftSampler->trigger();
    }

    void playRight() {
        if (globalStream == nullptr || globalCallback == nullptr) {
            alog("Audio stream is not initialized!");
            return;
        }

        rightSampler->trigger();
    }

    void runMetronome() {
        metronome->run();
    }

    void stopMetronome() {
        metronome->stop();
    }
}

oboe::AudioStreamBuilder makeOboeBuilder() {
    oboe::AudioStreamBuilder builder;

    builder.setFormat(oboe::AudioFormat::Float)
            ->setBufferCapacityInFrames(128)
            ->setChannelCount(oboe::ChannelCount::Stereo)
            ->setSampleRate(SAMPLE_RATE)
            ->setPerformanceMode(oboe::PerformanceMode::LowLatency)
            ->setSharingMode(oboe::SharingMode::Exclusive);

    return builder;
}

//--------------
// UTIL STUFF
//--------------

//void measureTime() {
//    auto currentTime = high_resolution_clock::now();
//    auto duration = duration_cast<microseconds>(currentTime - startTime).count();
//    alog("Time since start playing: %d microsec", duration);
//}
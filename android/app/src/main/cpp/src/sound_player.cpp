#include <chrono>  // Для работы с временем
#include <cstdint> // Для int64_t
#include <algorithm> // std::fill
#include <oboe/Oboe.h>
#include "audio_callback.h"
#include "audio_source.h"
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
//using namespace std::chrono;

using InitCallback = void(*)(int);

void testGetSineWave();
//void measureTime();

oboe::AudioStreamBuilder makeOboeBuilder();

// -----------------------------
// AudioHostDsp + SilentSource + Oboe adapter
// -----------------------------
class SilentSource : public AudioSource {
public:
    void getSamples(float* out, int32_t numFrames) override {
        if (!out || numFrames <= 0) return;

        std::fill(out, out + numFrames * 2, 0.0f);
    }

    float getVolume() override {return 1.0; }
};

class AudioHostDsp {
public:
    AudioHostDsp() : root_(std::make_shared<SilentSource>()) {}

    // Рендерит следующий буфер в out.
    void process(float* out, int32_t frames) {
        if (root_) {
            root_->getSamples(out, frames); // пока используем текущий API
        } else if (out && frames > 0) {
            std::fill(out, out + frames * 2, 0.0f);
        }
    }

    // Горячая замена корневого источника
    void swapSource(std::shared_ptr<AudioSource> newRoot) {
        root_ = std::move(newRoot);
    }

private:
    std::shared_ptr<AudioSource> root_;
};

// Адаптер oboe::AudioStreamDataCallback - вызывает AudioHostDsp::process
class HostOboeCallback : public oboe::AudioStreamDataCallback {
public:
    explicit HostOboeCallback(std::shared_ptr<AudioHostDsp> host) : host_(host) {}

    oboe::DataCallbackResult onAudioReady(oboe::AudioStream* stream,
                                          void* audioData,
                                          int32_t numFrames) override {
        auto out = static_cast<float*>(audioData);
        const int32_t channels = stream->getChannelCount();
        if (host_ && channels == 2) {
            host_->process(out, numFrames);
        } else if (out) {
            std::fill(out, out + numFrames * channels, 0.0f);
        }
        return oboe::DataCallbackResult::Continue;
    }

private:
    std::shared_ptr<AudioHostDsp> host_;
};

shared_ptr<oboe::AudioStream> globalStream;
std::shared_ptr<AudioHostDsp> gHost;
std::shared_ptr<HostOboeCallback> gHostCallback;
shared_ptr<Sampler> leftSampler;
shared_ptr<Sampler> rightSampler;
shared_ptr<Transport> transport;
shared_ptr<Metronome> metronome;
shared_ptr<Sequencer> rhythmPlayer;
//shared_ptr<AudioCallback> globalCallback;

struct NoteFFI {
    int noteId;
    double startBeat;
};

struct SequenceFFI {
    const NoteFFI* notes;
    int noteCount;
    double sequenceLength;
};

extern "C" {
    void initializeAudio(InitCallback callback) {
        alog("Started initializing Audio");
        if (globalStream != nullptr) return; // Поток уже открыт
        if (!gHost) {
            gHost = std::make_shared<AudioHostDsp>(); // root по умолчанию — SilentSource
            gHostCallback = std::make_shared<HostOboeCallback>(gHost);
        }

//        testGetSineWave();

        // Создаем микшер
        auto globalMixer = make_shared<Mixer>();

        // Создаем семплеры и задаем им звуки
        leftSampler = make_shared<Sampler>(
            make_shared<Wave>(getSineWave(4024, 300.0f))
        );
        rightSampler = make_shared<Sampler>(
            make_shared<Wave>(getSineWave(3024, 600.0f))
        );

        transport = make_shared<Transport>(120);
        auto metronomeSound1 = make_shared<Wave>(getSineWave(2612, 800.0f));
        auto metronomeSound2 = make_shared<Wave>(getSineWave(2612, 1600.0f));
        metronome = make_shared<Metronome>(transport, metronomeSound1, metronomeSound2);

        vector<Note> notes;
        notes.push_back(Note{0, 0.001});  // сильный удар на 1-ю долю
        notes.push_back(Note{1, 1.0});  // слабый удар на 2-ю долю
        notes.push_back(Note{0, 2.0});  // слабый удар на 3-ю долю
        notes.push_back(Note{1, 3.0});  // слабый удар на 4-ю долю

        vector<shared_ptr<const Wave>> soundBank;
        soundBank.push_back(make_shared<Wave>(getSineWave(1256, 1600.0f))); // strong strike
        soundBank.push_back(make_shared<Wave>(getSineWave(1256, 800.0f))); // weak

        rhythmPlayer = make_shared<Sequencer>(transport, notes, soundBank, 4.0);

        // Регистрируем семплеры в микшере
        globalMixer->addSource(leftSampler);
        globalMixer->addSource(rightSampler);
        globalMixer->addSource(metronome);
        globalMixer->addSource(rhythmPlayer);

        // globalCallback = make_shared<AudioCallback>(transport, globalMixer);

        oboe::AudioStreamBuilder myOboe = makeOboeBuilder(); // todo check if existed (but maybe not)
        myOboe.setDataCallback(gHostCallback.get());

        oboe::Result result = myOboe.openStream(globalStream);
        if (result != oboe::Result::OK) {
            if (callback) {
                callback(1);
            }

            alog("Failed to open stream");
            return;
        }
        alog("Opened stream: sampleRate = %d, framesPerBurst = %d, bufferSize = %d",
             globalStream->getSampleRate(),
             globalStream->getFramesPerBurst(),
             globalStream->getBufferSizeInFrames());

        result = globalStream->requestStart();
        if (result != oboe::Result::OK) {
            if (callback) {
                callback(2);
            }

            alog("Failed to start stream");
            return;
        }

        // Подключаем текущую сцену (микшер) как корневой источник для хоста.
//        if (gHost) {
//            gHost->swapSource(globalMixer);
//        }
        if (callback) {
            callback(0);
        }

        alog("Audio is initialized");
    }

    void cleanupAudioStream() {
        if (globalStream) {
            globalStream->stop();
            globalStream->close();
            globalStream.reset();
        }
        gHostCallback.reset();
        gHost.reset();
//        globalCallback.reset();
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

        leftSampler->setWave(leftSound);
        rightSampler->setWave(rightSound);

        vector<shared_ptr<const Wave>> newSoundBank;
        newSoundBank.push_back(leftSound);
        newSoundBank.push_back(rightSound);

        rhythmPlayer->setSounds(newSoundBank);

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

        rhythmPlayer->setSequence(notes, seq->sequenceLength);

        return 0;
    }

    void playLeft() {
        if (globalStream == nullptr) {
            alog("Audio stream is not initialized!");
            return;
        }
        leftSampler->trigger();
    }

    void playRight() {
        if (globalStream == nullptr) {
            alog("Audio stream is not initialized!");
            return;
        }
        rightSampler->trigger();
    }

    void runScene(int8_t metronomeEnabled, int8_t sequenceEnabled, double temp) {
        bool metronomeBool = (metronomeEnabled != 0);
        bool sequenceBool = (sequenceEnabled != 0);

        metronome->setEnabled(metronomeBool);
        rhythmPlayer->setEnabled(sequenceBool);

//        if (globalCallback) globalCallback->resetBusy();

        transport->setBPM(static_cast<double>(temp));
        transport->play();
    }

    void stopScene() {
        transport->stop();
    }
}

oboe::AudioStreamBuilder makeOboeBuilder() {
    oboe::AudioStreamBuilder builder;

    builder.setFormat(oboe::AudioFormat::Float)
            ->setBufferCapacityInFrames(512)
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
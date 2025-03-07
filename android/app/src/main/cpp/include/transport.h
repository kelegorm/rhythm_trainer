#pragma once

#include "audio_config.h"

class Transport {
public:
    Transport(double bpm)
            : _isPlaying(true), _bpm(bpm), _currentSample(0)
    {}

    bool isPlaying() const { return _isPlaying; }
    double getBPM() const { return _bpm; }
    int getCurrentSample() const { return _currentSample; }

    // Вычисляет число сэмплов на одну долю (beat)
    double framesPerBeat() const {
        return (SAMPLE_RATE * 60.0) / _bpm;
    }

    // Запускает транспорт: сбрасываем счетчик и ставим isPlaying=true
    void play() {
        _isPlaying = true;
        _currentSample = 0;
    }

    // Останавливаем транспорт
    void stop() {
        _isPlaying = false;
    }

    // Метод обновления счетчика сэмплов
    void update(int numFrames) {
        if (_isPlaying) {
            _currentSample += numFrames;
        }
    }

    // Метод для изменения BPM
    void setBPM(double newBpm) {
        _bpm = newBpm;
    }
private:
    bool _isPlaying;
    double _bpm;
    int _currentSample; // глобальный счётчик сэмплов от начала воспроизведения
};
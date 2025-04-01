#pragma once

class AudioSource {
public:
    virtual ~AudioSource() {}
    virtual float getVolume() = 0;
    virtual void getSamples(float* buffer, int numFrames) = 0;
};
#pragma once

class IAudioSource {
public:
    virtual ~IAudioSource() {}
    virtual float getVolume() = 0;
    virtual void getSamples(float* buffer, int numFrames) = 0;
};
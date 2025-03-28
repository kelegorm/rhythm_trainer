#pragma once

class AudioSource {
public:
    virtual ~AudioSource() {}

    virtual void getSamples(float* buffer, int numFrames) = 0;
};
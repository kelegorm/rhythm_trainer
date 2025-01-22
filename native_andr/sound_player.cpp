//#include <cmath.h>
#include <android/log.h>

#define LOG_TAG "Native Sound PLayer"

extern "C" {
    void playLeft() {
        __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "Play Left!");
    }
}

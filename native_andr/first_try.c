#include <math.h>
#include <android/log.h>

#define LOG_TAG "Native First Try"

int myAdd(int a, int b) {
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "This is a log message from myAdd func from C code");
    return a + b;
}
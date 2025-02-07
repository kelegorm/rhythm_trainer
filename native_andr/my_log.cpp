#include <android/log.h>
#include <stdarg.h>

#define LOG_TAG "Native Sound PLayer"

void alog(const char *message, ...) {
    va_list args;
    va_start(args, message);
    __android_log_vprint(ANDROID_LOG_INFO, LOG_TAG, message, args);
    va_end(args);
}
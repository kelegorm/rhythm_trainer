#следующие две настрйоки обязательны, если у нас проект сложнее, чем один C файл, доп либы, линкование и тд.
cmake_minimum_required(VERSION 3.22)

#set(CMAKE_CXX_CLANG_TIDY clang-tidy -checks=*-cppcoreguidelines-*)

#set(CMAKE_CXX_CLANG_TIDY "clang-tidy;-checks=-*,bugprone-signed-unsigned-comparison")
#set(CMAKE_CXX_CLANG_TIDY clang-tidy -checks=-*,bugprone-signed-unsigned-comparison)
#set(CMAKE_CXX_CLANG_TIDY clang-tidy -checks=*)

#set(CMAKE_C_CLANG_TIDY
#        clang-tidy;
#        -header-filter=.*;
#        -checks=*,-llvmlibc-restrict-system-libc-headers;
#        -warnings-as-errors=*;
#)

#set(CMAKE_CXX_CLANG_TIDY ${ANDROID_TOOLCHAIN_ROOT}/bin/clang-tidy -checks=*)

project(RhythmTrainer LANGUAGES C CXX) # если используешь C++, укажи CXX вместо C

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include_directories(${CMAKE_SOURCE_DIR}/include)

# Добавляем ваш файл с кодом
add_library(sound_player SHARED
        src/dsp/core/wave_renderer.cpp
        src/dsp/core/audio_host.cpp
        src/dsp/metronome.cpp
        src/dsp/mixer.cpp
        src/dsp/sampler.cpp
        src/dsp/sequencer.cpp
        src/sound_player.cpp
        src/my_log.cpp
        src/gen_waves.cpp
        # src/dsp/core/audio_host.cpp  # removed duplicate
        include/rhythm_trainer_session.h
        src/rhythm_trainer_session.cpp
        src/ffi_structs.h
        src/oboe_host_wrapper.cpp
        # src/oboe_host_wrapper.cpp  # removed duplicate
        src/miniaudio.c
        src/miniaudio_host_wrapper.cpp
)

find_library(log-lib log)

find_package(oboe REQUIRED CONFIG)

target_link_libraries(sound_player PRIVATE oboe::oboe ${log-lib} c++_shared)

# Android audio backends for miniaudio
if(ANDROID)
    if(DEFINED ANDROID_PLATFORM AND ANDROID_PLATFORM VERSION_LESS "26")
        target_compile_definitions(sound_player PRIVATE MA_NO_AAUDIO)
        target_link_libraries(sound_player PRIVATE OpenSLES)
    else()
        target_link_libraries(sound_player PRIVATE aaudio OpenSLES)
    endif()
endif()

# Настройка стандартов C++ (требование oboe)
set_target_properties(sound_player PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
)

target_include_directories(sound_player PRIVATE src)
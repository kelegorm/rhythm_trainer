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

project(RhythmTrainer LANGUAGES CXX) # если используешь C++, укажи CXX вместо C

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include_directories(${CMAKE_SOURCE_DIR}/include)

# Добавляем ваш файл с кодом
add_library(sound_player SHARED
        src/audio_callback.cpp
        src/metronome.cpp
        src/mixer.cpp
        src/my_log.cpp
        src/sampler.cpp
        src/sequencer.cpp
        src/sound_player.cpp
        src/waveforms.cpp
        src/wave_renderer.cpp
)

find_library(log-lib log)

find_package(oboe REQUIRED CONFIG)

target_link_libraries(sound_player oboe::oboe ${log-lib})

# Настройка стандартов C++ (требование oboe)
set_target_properties(sound_player PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
)

target_include_directories(sound_player PRIVATE src)
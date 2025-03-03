#следующие две настрйоки обязательны, если у нас проект сложнее, чем один C файл, доп либы, линкование и тд.
cmake_minimum_required(VERSION 3.22)

#set(CMAKE_CXX_CLANG_TIDY clang-tidy -checks=*-cppcoreguidelines-*)

project(RhythmTrainer LANGUAGES CXX) # если используешь C++, укажи CXX вместо C

# Добавляем ваш файл с кодом
add_library(sound_player SHARED
        ../../native_andr/sound_player.cpp
        ../../native_andr/my_log.cpp
        ../../native_andr/waveforms.cpp
        ../../native_andr/audio_callback.cpp
        ../../native_andr/mixer.cpp
        ../../native_andr/sampler.cpp
        ../../native_andr/metronome.cpp
        ../../native_andr/sequencer.cpp
)

find_library(log-lib log)

find_package(oboe REQUIRED CONFIG)

target_link_libraries(sound_player oboe::oboe ${log-lib})

# Настройка стандартов C++ (требование oboe)
set_target_properties(sound_player PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
)

#target_include_directories(sound_player PRIVATE ../../native_code)
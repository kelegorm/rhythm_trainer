#следующие две настрйоки обязательны, если у нас проект сложнее, чем один C файл, доп либы, линкование и тд.
cmake_minimum_required(VERSION 3.22)

project(RhythmTrainer LANGUAGES CXX) # если используешь C++, укажи CXX вместо C

# Добавляем ваш файл с кодом
#add_library(first_try SHARED first_try.c)
add_library(sound_player SHARED sound_player.cpp)

find_library(log-lib log)

find_package(oboe REQUIRED CONFIG)

target_link_libraries(sound_player oboe::oboe ${log-lib})

# Настройка стандартов C++ (требование oboe)
set_target_properties(sound_player PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
)
#следующие две настрйоки обязательны, если у нас проект сложнее, чем один C файл, доп либы, линкование и тд.
cmake_minimum_required(VERSION 3.22)

project(RhythmTrainer LANGUAGES C) # если используешь C++, укажи CXX вместо C

# Добавляем ваш файл с кодом
#add_library(first_try SHARED first_try.c)
add_library(sound_player SHARED sound_player.c)

find_library(log-lib log)

target_link_libraries(sound_player ${log-lib})
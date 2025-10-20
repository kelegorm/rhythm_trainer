#pragma once

struct Note {
    size_t soundId;         // Идентификатор звука (например, 1 или 2)
    double startBeat;    // Начало ноты в тактовых долях (например, 1.0, 1.5 и т.д.)
};
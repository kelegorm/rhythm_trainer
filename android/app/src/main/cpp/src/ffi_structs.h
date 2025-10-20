//
// Created by Dmitry on 20.10.25..
//

#pragma once

struct NoteFFI {
    int noteId;
    double startBeat;
};

struct SequenceFFI {
    const NoteFFI* notes;
    int noteCount;
    double sequenceLength;
};

//
//  processPitch.swift
//  tunar
//
//  Created by Sonny Young on 8/14/23.
//

import Foundation

func frequencyToPitch(frequency: Float) -> String? {
    if let midiNote = frequencyToMidiNote(frequency: frequency) {
        let pitch = midiNoteToPitch(midiNote: midiNote)
        return pitch
    } else {
        return nil
    }
}

func frequencyToMidiNote(frequency: Float) -> Int? {
    let a440Frequency: Float = 440.0
    let a440MidiNote: Int = 69
//    let centsPerOctave: Float = 1200.0
    let real_frequency = frequency * 2
    
    guard real_frequency > 0 else {
        return nil
    }
    
    let midiNote = Int(round(12.0 * log2f(real_frequency / a440Frequency) + Float(a440MidiNote)))
    print(midiNote)
    return midiNote
}

func midiNoteToPitch(midiNote: Int) -> String {
    let octave = midiNote / 12 - 1
    let pitchClass = midiNote % 12
    
    let pitchClassNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let pitchName = pitchClassNames[pitchClass] + String(octave)
    
    return pitchName
}

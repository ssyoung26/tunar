//
//  processPitch.swift
//  tunar
//
//  Created by Sonny Young on 8/14/23.
//

let A440: Float = 440
let A440MIDINOTE: Float = 69

import Foundation

func frequencyToNote(frequency: Float, offset: Float) -> (Float, Int, String, Float)? {
    let a440Frequency: Float = A440 + offset
    
    guard frequency > 0 else {
        return nil
    }
    
    let calcMidi = round(12 * log2f(frequency / a440Frequency) + Float(A440MIDINOTE))
    let exp: Float = (calcMidi - A440MIDINOTE) / 12
    let midiNoteFrequency: Float = pow(2, exp) * a440Frequency
    let cents: Float = 1200 * log2f(frequency / midiNoteFrequency)
    
    let midiNote = Int(calcMidi)
    let octave = midiNote / 12 - 1
    let pitchClass = midiNote % 12
    let pitchClassNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let pitchName: String = pitchClassNames[pitchClass] + String(octave)
    
    print("frequency: \(frequency), midiNote: \(midiNote), pitchName: \(pitchName), cents: \(cents)")
    
    return (frequency, midiNote, pitchName, cents)
}

//
//  pitchManager.swift
//  tunar
//
//  Created by Sonny Young on 8/22/23.
//

import SwiftUI
import Combine

class PitchManager: ObservableObject {
    @Published var pitchFrequency: Float = 0.0
    @Published var midiNote: Int = 0
    @Published var pitchName: String = ""
    @Published var cents: Float = 0.0
    @Published var offset: Float = 0.0 {
        didSet {
            print("pitch offset updated: \(offset)")
        }
    }
}

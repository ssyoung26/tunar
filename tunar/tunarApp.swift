//
//  tunarApp.swift
//  tunar
//
//  Created by Sonny Young on 6/27/23.
//

import SwiftUI
import AVFoundation

@main
struct tunarApp: App {

    let pitchManager = PitchManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(audioEngine: AudioEngine(pitchManager: pitchManager)).environmentObject(pitchManager)
        }
    }
}




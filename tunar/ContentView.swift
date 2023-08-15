//
//  ContentView.swift
//  tunar
//
//  Created by Sonny Young on 8/14/23.
//

import SwiftUI

struct ContentView: View {
    @State private var recordingStatus = "Not Recording"
    
    let audioEngine = AudioEngine()
    
    var body: some View {
        VStack {
            Button(action: startRecording) {
                Text("Start Recording")
            }
            Button(action: endRecording) {
                Text("Stop Recording")
            }
            Text("Status: " + recordingStatus)
        }
    }
    
    func startRecording() {
        audioEngine.startRecording()
        recordingStatus = "Recording"
    }
    
    func endRecording() {
        audioEngine.endRecording()
        recordingStatus = "Not Recording"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

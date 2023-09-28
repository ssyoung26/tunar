//
//  ContentView.swift
//  tunar
//
//  Created by Sonny Young on 8/14/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var pitchManager: PitchManager
    @ObservedObject var metronome: Metronome
    let audioEngine: AudioEngine
    
    init(audioEngine: AudioEngine, metronome: Metronome = Metronome()) {
        self.audioEngine = audioEngine
        self._metronome = ObservedObject(wrappedValue: metronome)
    }

    @State private var selectedTab: Tab = .tuner // Default tab is tuner

    enum Tab {
        case tuner
        case metronome
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TunerView(audioEngine: audioEngine)
                .tabItem {
                    Label("Tuner", systemImage: "music.quarternote.3")
                }
                .tag(Tab.tuner)
            
            MetronomeView(metronome: metronome)
                .tabItem {
                    Label("Metronome", systemImage: "metronome.fill")
                }
                .tag(Tab.metronome)
        }
        .onChange(of: selectedTab) { newTab in
            // Handle tab changes here if needed
        }
    }
}

struct TunerView: View {
    @EnvironmentObject var pitchManager: PitchManager
    var audioEngine: AudioEngine

    @State private var standard: Float = 440.0
    @State private var offset: Float = 0
    @State private var isEditing = false
    @State private var recordingStatus = false

    var currentTuning: Float {
        return standard + offset
    }

    var pitchBody: some View {
        VStack {
            Text(" \(pitchManager.pitchName) insert note")
                .font(.system(size:75))
//                .fixedSize()
//            Text("Pitch Frequency: \(pitchManager.pitchFrequency) Hz")
//            Text("Cents: \(pitchManager.cents)")
            GeometryReader { geometry in
                ZStack {
                    Slider(value: $pitchManager.cents, in: -50...50, step: 1)
                        .rotationEffect(.degrees(-90))
                        .frame(width: geometry.size.height, height: geometry.size.width)
                        .offset(x: -geometry.size.height / 2 + geometry.size.width / 2)
                    
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                        .offset(x: -geometry.size.height / 2 + geometry.size.width / 2)
                }
//                .frame(height: 150)
            }
//            .padding()
//            .frame(height: 200)
        }
    }

    var tuneBody: some View {
        VStack {
            HStack {
                Button(action: decrementTuning) {
                    Text("-").font(.system(size: 36))
                }
                Slider(
                    value: $offset,
                    in: -439...562,
                    step: 5
                )
                .frame(width: 150)
                .onChange(of: offset) { _ in
                    pitchManager.offset = offset
                }
                Button(action: incrementTuning) {
                    Text("+").font(.system(size: 36))
                }
            }
            .padding()

            HStack {
                Image(systemName: "music.note")
                    .font(.system(size: 20))

                Text(":  \(Int(currentTuning))")
            }
        }
    }

    var body: some View {
        VStack {
            pitchBody
//            Spacer()
            tuneBody
            
            HStack {
                Button(action: toggleRecording) {
                    Image(systemName: recordingStatus ? "stop.circle.fill" : "circle.fill")
                        .font(.system(size: 40))
                }
                
                Text(recordingStatus ? "Stop Recording" : "Start Recording")
                    .font(.headline)
            }
        }
    }

    func toggleRecording() {
        recordingStatus.toggle()
        if recordingStatus {
            startRecording()
        } else {
            endRecording()
        }
    }
    
    func startRecording() {
        audioEngine.startRecording()
        recordingStatus = true
    }

    func endRecording() {
        audioEngine.endRecording()
        recordingStatus = false
    }

    func incrementTuning() {
        standard += 1
        offset = standard - 440.0
        pitchManager.offset = offset
    }

    func decrementTuning() {
        standard -= 1
        offset = standard - 440.0
        pitchManager.offset = offset
    }
}

struct MetronomeView: View {
    @ObservedObject var metronome: Metronome

    var body: some View {
        VStack {
            Text("\(Int(metronome.bpm) - 2) BPM")
                .font(.system(size:25))
                .frame(width: 200, height: 100)
                .fixedSize()

            HStack {
                Button(action: { metronome.decrementBPM() }) {
                    Text("-").font(.title)
                }

                Slider(value: $metronome.bpm, in: 30...300, step: 1) {
                    Text("Tempo")
                }

                Button(action: { metronome.incrementBPM() }) {
                    Text("+").font(.title)
                }
            }
        
            Button(action: toggleMetronome) {
                Image(systemName: metronome.enabled ? "pause.circle" : "play.circle")
                    .font(.title)
                    .foregroundColor(.blue)
            }

        }
    }
    
    func toggleMetronome() {
        metronome.enabled.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let pitchManager = PitchManager()
        let audioEngine = AudioEngine(pitchManager: pitchManager)
        let metronome = Metronome()
        Group {
            ContentView(audioEngine: audioEngine)
                .environmentObject(pitchManager)
                .environmentObject(metronome)
        }
    }
}

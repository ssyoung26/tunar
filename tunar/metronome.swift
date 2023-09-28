//
//  metronome.swift
//  tunar
//
//  Created by Sonny Young on 9/27/23.
//

import Foundation
import AVFoundation

class Metronome: ObservableObject {
    @Published var enabled: Bool = false {
        didSet {
            if enabled {
                start()
            } else {
                stop()
            }
        }
    }
    
    @Published var bpm: Float = 62.0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.bpm = min(300.0, max(30.0, self.bpm))
                print("tempo bpm updated: \(self.bpm)")
            }
        }
    }
    
    var onTick: ((_ nextTick: DispatchTime) -> Void)?
    var nextTick: DispatchTime = DispatchTime.distantFuture

    let player: AVAudioPlayer
    private var metronomeQueue = DispatchQueue(label: "MetronomeQueue")
    
    init() {
        
        do {
            let soundURL = Bundle.main.url(forResource: "metronome_1", withExtension: "wav")!
            let player = try AVAudioPlayer(contentsOf: soundURL)
            self.player = player
        } catch {
            print("Unable to initialize metronome audio buffer: \(error)")
            self.player = AVAudioPlayer()
        }
    }

    private func start() {
        print("Starting metronome, BPM: \(bpm)")
        player.prepareToPlay()
        nextTick = DispatchTime.now()
        tick()
    }

    private func stop() {
        player.stop()
        print("Stopping metronome")
    }

    private func tick() {
        guard enabled else { return }

        let interval: TimeInterval = 60.0 / TimeInterval(bpm)
        let dispatchTime = DispatchTime.now() + interval

        DispatchQueue.main.asyncAfter(deadline: dispatchTime) { [weak self] in
            self?.tick()
        }

        player.play()
        onTick?(dispatchTime)
    }
    
    func incrementBPM() {
        bpm += 1
    }

    func decrementBPM() {
        bpm -= 1
    }
}

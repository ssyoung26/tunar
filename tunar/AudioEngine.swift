//
//  AudioEngine.swift
//  tunar
//
//  Created by Sonny Young on 8/14/23.
//

import AVFoundation

class AudioEngine : ObservableObject {


    private var audioEngine = AVAudioEngine()
    private var audioInputNode: AVAudioInputNode!
    private var pitchManager: PitchManager?
    
    init(pitchManager: PitchManager) {
        self.pitchManager = pitchManager
    }

    func startRecording() {

        // Format bus and buffer parameters
        let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        let bufferSize = 1024
        let nearestPowerOf2 = Int(ceil(log2(Double(bufferSize))))
        let fftSize = 1 << nearestPowerOf2
        
        // Start the audio bus
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(bufferSize), format: inputFormat) { [weak self] buffer, time in
            guard let self = self else {
                return
            }
            
            // Process audio and process FFT
            let fft = FFT(withSize: fftSize, sampleRate: Float(inputFormat.sampleRate))
            let audioBuffer = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
            fft.fftForward(audioBuffer)
            
            // Get peak magnitudes which will get converted to frequency which will get turned to pitches
            let magnitudes = fft.getMagnitudes()
            let binIndexWithDominantFrequency = fft.findDominantFrequencyBin(magnitudes)
            let pitchFrequency = 2 * Float(binIndexWithDominantFrequency) * fft.nyquistFrequency / Float(fft.size)
            
            // Process pitch
            if let noteOutput = frequencyToNote(frequency: pitchFrequency, offset: self.pitchManager?.offset ?? 0) {
                DispatchQueue.main.async {
                    self.pitchManager?.pitchFrequency = noteOutput.0
                    self.pitchManager?.midiNote = noteOutput.1
                    self.pitchManager?.pitchName = noteOutput.2
                    self.pitchManager?.cents = noteOutput.3
                }
            }
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Error: Audio engine did not start")
        }
        
    }
    
    func endRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

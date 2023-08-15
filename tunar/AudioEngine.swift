//
//  AudioEngine.swift
//  tunar
//
//  Created by Sonny Young on 8/14/23.
//

import AVFoundation

class AudioEngine {
    private var audioEngine = AVAudioEngine()
    private var audioInputNode: AVAudioInputNode!
    
    
    func startRecording() {
        let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        
        let bufferSize = 1024
        let nearestPowerOf2 = Int(ceil(log2(Double(bufferSize))))
        let fftSize = 1 << nearestPowerOf2
        
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(bufferSize), format: inputFormat) { buffer, time in
            
            // Process fft
            _ = AVAudioFrameCount(buffer.frameLength)
            let fft = FFT(withSize: fftSize, sampleRate: Float(inputFormat.sampleRate))
            
            let audioBuffer = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
            fft.fftForward(audioBuffer)
            
            let magnitudes = fft.getMagnitudes()
            let binIndexWithDominantFrequency = fft.findDominantFrequencyBin(magnitudes)
            
            let pitchFrequency = Float(binIndexWithDominantFrequency) * fft.nyquistFrequency / Float(fft.size)
            
            print("Dominant Frequency Bin Index: \(binIndexWithDominantFrequency)")
            print("Pitch Frequency: \(pitchFrequency) Hz")
            
            // Process pitch
            
            if let pitchName = frequencyToPitch(frequency: pitchFrequency) {
                print("Frequency \(pitchFrequency) corresponds to pitch \(pitchName)")
            } else {
                print("Invalid frequency")
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

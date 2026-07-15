//
//  AlarmPlayer.swift
//  TomaTask
//

import AVFoundation
import AudioToolbox
import UIKit

@MainActor
final class AlarmPlayer {
    static let shared = AlarmPlayer()

    private var player: AVAudioPlayer?
    private var repeatWorkItem: DispatchWorkItem?
    private var remainingPlays = 0

    private init() {}

    func play(preview: Bool = false) {
        stop()

        guard let data = Self.makeAlarmWAV() else {
            AudioServicesPlaySystemSound(1005)
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(data: data)
            player?.prepareToPlay()

            remainingPlays = preview ? 1 : 3
            playNextBeep()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            AudioServicesPlaySystemSound(1005)
        }
    }

    func stop() {
        repeatWorkItem?.cancel()
        repeatWorkItem = nil
        remainingPlays = 0
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func playNextBeep() {
        guard remainingPlays > 0, let player else { return }
        remainingPlays -= 1
        player.currentTime = 0
        player.play()

        guard remainingPlays > 0 else { return }

        let workItem = DispatchWorkItem { [weak self] in
            self?.playNextBeep()
        }
        repeatWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85, execute: workItem)
    }

    /// Two short sine beeps packed into a WAV, suitable for an end-of-session alarm.
    private static func makeAlarmWAV() -> Data? {
        let sampleRate = 44_100.0
        let toneDuration = 0.18
        let gapDuration = 0.08
        let frequencies: [Double] = [880, 1174.7]
        let amplitude: Float = 0.45

        var samples: [Float] = []
        for (index, frequency) in frequencies.enumerated() {
            let toneCount = Int(toneDuration * sampleRate)
            for i in 0..<toneCount {
                let t = Double(i) / sampleRate
                let envelope = Float(sin(Double.pi * t / toneDuration))
                let sample = envelope * amplitude * Float(sin(2 * Double.pi * frequency * t))
                samples.append(sample)
            }
            if index < frequencies.count - 1 {
                samples.append(contentsOf: Array(repeating: 0, count: Int(gapDuration * sampleRate)))
            }
        }

        return wavData(from: samples, sampleRate: Int(sampleRate))
    }

    private static func wavData(from samples: [Float], sampleRate: Int) -> Data {
        let dataSize = UInt32(samples.count * 2)
        var data = Data()

        func appendASCII(_ string: String) {
            data.append(contentsOf: string.utf8)
        }
        func appendUInt16(_ value: UInt16) {
            var value = value.littleEndian
            withUnsafeBytes(of: &value) { data.append(contentsOf: $0) }
        }
        func appendUInt32(_ value: UInt32) {
            var value = value.littleEndian
            withUnsafeBytes(of: &value) { data.append(contentsOf: $0) }
        }

        appendASCII("RIFF")
        appendUInt32(36 + dataSize)
        appendASCII("WAVE")
        appendASCII("fmt ")
        appendUInt32(16)
        appendUInt16(1) // PCM
        appendUInt16(1) // mono
        appendUInt32(UInt32(sampleRate))
        appendUInt32(UInt32(sampleRate * 2))
        appendUInt16(2)
        appendUInt16(16)
        appendASCII("data")
        appendUInt32(dataSize)

        for sample in samples {
            let clamped = max(-1, min(1, sample))
            let intSample = Int16(clamped * Float(Int16.max))
            var littleEndian = intSample.littleEndian
            withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
        }

        return data
    }
}

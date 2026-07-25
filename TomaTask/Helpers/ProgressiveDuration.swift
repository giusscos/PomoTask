//
//  ProgressiveDuration.swift
//  TomaTask
//

import Foundation

/// Progressive focus/break duration rules shared by iPhone and Watch.
enum ProgressiveDuration {
    static let defaultTimeStart: Double = 5 * 60
    static let defaultMinSeconds: Double = 3 * 60
    static let defaultMaxSeconds: Double = 25 * 60
    static let defaultBreakMinSeconds: Double = 3 * 60
    static let defaultBreakMaxSeconds: Double = 8 * 60

    static func increased(_ seconds: Double) -> Double {
        min(seconds + defaultMinSeconds, defaultMaxSeconds)
    }

    static func decreased(_ seconds: Double) -> Double {
        max(seconds - defaultMinSeconds, defaultMinSeconds)
    }

    /// ~20% of last focus, clamped to 3–8 minutes.
    static func breakDuration(forFocusSeconds focus: Double) -> Double {
        let raw = focus * 0.2
        return min(max(raw, defaultBreakMinSeconds), defaultBreakMaxSeconds)
    }

    /// Cut remaining by ~1/3, floor 1 minute.
    static func shortenedRemaining(_ seconds: Double) -> Double {
        max(seconds * (2.0 / 3.0), 60)
    }

    static func minutesLabel(_ seconds: Double) -> String {
        let mins = max(1, Int((seconds / 60).rounded()))
        return "\(mins)′"
    }
}

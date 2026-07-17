//
//  TimerLiveActivityStyle.swift
//  TomaTaskWidgets
//

import SwiftUI

/// Visual tokens matching TaskView / ProgressiveTimerView.
enum TimerLiveActivityStyle {
    static let tomatoRed = Color(red: 0.86, green: 0.14, blue: 0.14)
    static let breakRed = Color(red: 0.72, green: 0.22, blue: 0.28)

    static func phaseColor(isBreak: Bool) -> Color {
        isBreak ? breakRed : tomatoRed
    }
}

//
//  TimerLiveActivityStyle.swift
//  TomaTaskWidgets
//

import SwiftUI

/// Visual tokens matching TaskView / ProgressiveTimerView.
enum TimerLiveActivityStyle {
    static let tomatoRed = BrandColors.tomatoRed
    static let breakRed = BrandColors.breakRed

    static func phaseColor(isBreak: Bool) -> Color {
        BrandColors.phaseColor(isBreak: isBreak)
    }
}

//
//  SharedTimerSync.swift
//  TomaTask
//

import Foundation

/// Publishes Progressive / Classic session state for Home Screen widgets.
@MainActor
enum SharedTimerSync {
    static func publishRunning(
        title: String,
        timeRemaining: TimeInterval,
        phaseDuration: TimeInterval,
        isBreak: Bool
    ) {
        SharedTimerStore.save(
            SharedTimerStore.Snapshot(
                isActive: true,
                isRunning: true,
                isBreak: isBreak,
                endDate: Date().addingTimeInterval(timeRemaining),
                remainingWhenPaused: timeRemaining,
                title: title,
                phaseDuration: phaseDuration
            )
        )
        SharedTimerStore.reloadWidgets()
    }

    static func publishPaused(
        title: String,
        timeRemaining: TimeInterval,
        phaseDuration: TimeInterval,
        isBreak: Bool
    ) {
        SharedTimerStore.save(
            SharedTimerStore.Snapshot(
                isActive: timeRemaining > 0,
                isRunning: false,
                isBreak: isBreak,
                endDate: Date(),
                remainingWhenPaused: timeRemaining,
                title: title,
                phaseDuration: phaseDuration
            )
        )
        SharedTimerStore.reloadWidgets()
    }

    static func publishIdle(title: String = "Progressive", phaseDuration: TimeInterval = 5 * 60) {
        SharedTimerStore.save(
            SharedTimerStore.Snapshot(
                isActive: false,
                isRunning: false,
                isBreak: false,
                endDate: .now,
                remainingWhenPaused: phaseDuration,
                title: title,
                phaseDuration: phaseDuration
            )
        )
        SharedTimerStore.reloadWidgets()
    }
}

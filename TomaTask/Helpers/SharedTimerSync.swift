//
//  SharedTimerSync.swift
//  TomaTask
//

import Foundation

/// Publishes Progressive / Classic session state for widgets and the Watch companion.
@MainActor
enum SharedTimerSync {
    /// When true, App Group / widgets still update but WatchConnectivity is skipped
    /// (avoids echo while adopting a companion snapshot).
    static var suppressWatchBroadcast = false

    static func publishRunning(
        title: String,
        timeRemaining: TimeInterval,
        phaseDuration: TimeInterval,
        isBreak: Bool
    ) {
        let snapshot = SharedTimerStore.Snapshot(
            isActive: true,
            isRunning: true,
            isBreak: isBreak,
            endDate: Date().addingTimeInterval(timeRemaining),
            remainingWhenPaused: timeRemaining,
            title: title,
            phaseDuration: phaseDuration
        )
        SharedTimerStore.save(snapshot)
        SharedTimerStore.reloadWidgets()
        broadcastToWatch(snapshot)
    }

    static func publishPaused(
        title: String,
        timeRemaining: TimeInterval,
        phaseDuration: TimeInterval,
        isBreak: Bool
    ) {
        let snapshot = SharedTimerStore.Snapshot(
            isActive: timeRemaining > 0,
            isRunning: false,
            isBreak: isBreak,
            endDate: Date(),
            remainingWhenPaused: timeRemaining,
            title: title,
            phaseDuration: phaseDuration
        )
        SharedTimerStore.save(snapshot)
        SharedTimerStore.reloadWidgets()
        broadcastToWatch(snapshot)
    }

    static func publishIdle(title: String = "Progressive", phaseDuration: TimeInterval = 5 * 60) {
        let snapshot = SharedTimerStore.Snapshot(
            isActive: false,
            isRunning: false,
            isBreak: false,
            endDate: .now,
            remainingWhenPaused: phaseDuration,
            title: title,
            phaseDuration: phaseDuration
        )
        SharedTimerStore.save(snapshot)
        SharedTimerStore.reloadWidgets()
        broadcastToWatch(snapshot)
    }

    private static func broadcastToWatch(_ snapshot: SharedTimerStore.Snapshot) {
        guard !suppressWatchBroadcast else { return }
        WatchSessionManager.shared.broadcast(snapshot)
    }
}

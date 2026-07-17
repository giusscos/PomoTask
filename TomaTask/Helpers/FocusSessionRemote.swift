//
//  FocusSessionRemote.swift
//  TomaTask
//

import ActivityKit
import AlarmKit
import Foundation
import SwiftUI
import WidgetKit

/// Play / pause without bringing the app to the foreground.
@MainActor
enum FocusSessionRemote {
    private static let defaultFocusSeconds: TimeInterval = 5 * 60

    /// Set by in-app session UIs when they handle a remote toggle.
    private(set) static var didHandleRemoteToggle = false

    static func markHandled() {
        didHandleRemoteToggle = true
    }

    static func toggle() async {
        didHandleRemoteToggle = false
        NotificationCenter.default.post(name: .focusSessionRemoteToggle, object: nil)
        if didHandleRemoteToggle {
            return
        }
        await toggleFromSharedState()
    }

    static func toggleFromSharedState() async {
        var snapshot = SharedTimerStore.load()

        if snapshot.isActive, snapshot.isRunning {
            await pause(&snapshot)
        } else if snapshot.isActive {
            await resume(&snapshot)
        } else {
            await startFresh(&snapshot)
        }

        SharedTimerStore.save(snapshot)
        SharedTimerStore.reloadWidgets()
    }

    // MARK: - Mutations

    private static func pause(_ snapshot: inout SharedTimerStore.Snapshot) async {
        let remaining = snapshot.displayedRemaining
        snapshot.isRunning = false
        snapshot.remainingWhenPaused = remaining
        snapshot.endDate = Date()

        pauseAlarm()
        await updateLiveActivity(
            timeRemaining: remaining,
            isBreak: snapshot.isBreak,
            isPaused: true,
            title: snapshot.title
        )
    }

    private static func resume(_ snapshot: inout SharedTimerStore.Snapshot) async {
        let remaining = max(1, snapshot.remainingWhenPaused)
        snapshot.isRunning = true
        snapshot.isActive = true
        snapshot.endDate = Date().addingTimeInterval(remaining)
        snapshot.remainingWhenPaused = remaining

        resumeAlarm()
        await ensureAlarm(duration: remaining, isBreak: snapshot.isBreak, title: snapshot.title)
        await updateLiveActivity(
            timeRemaining: remaining,
            isBreak: snapshot.isBreak,
            isPaused: false,
            title: snapshot.title
        )
    }

    private static func startFresh(_ snapshot: inout SharedTimerStore.Snapshot) async {
        let duration = snapshot.phaseDuration > 0 ? snapshot.phaseDuration : defaultFocusSeconds
        snapshot = SharedTimerStore.Snapshot(
            isActive: true,
            isRunning: true,
            isBreak: false,
            endDate: Date().addingTimeInterval(duration),
            remainingWhenPaused: duration,
            title: "Progressive",
            phaseDuration: duration
        )

        await ensureAlarm(duration: duration, isBreak: false, title: "Focus complete")
        // Prefer AlarmKit’s system Live Activity when an alarm was scheduled.
        if SharedTimerStore.alarmID == nil {
            await startLiveActivity(
                title: snapshot.title,
                timeRemaining: duration,
                isBreak: false
            )
        } else {
            endLiveActivities()
        }
    }

    // MARK: - Live Activity

    private static func startLiveActivity(title: String, timeRemaining: TimeInterval, isBreak: Bool) async {
        endLiveActivities()
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TomaTaskActivityAttributes(taskTitle: title)
        let endDate = Date().addingTimeInterval(timeRemaining)
        let state = TomaTaskActivityAttributes.ContentState(
            endDate: endDate,
            isBreak: isBreak,
            isPaused: false,
            timeRemainingWhenPaused: timeRemaining
        )

        do {
            let content = ActivityContent(state: state, staleDate: endDate)
            _ = try Activity.request(attributes: attributes, content: content, pushType: nil)
        } catch {
            print("FocusSessionRemote LA start failed: \(error.localizedDescription)")
        }
    }

    private static func updateLiveActivity(
        timeRemaining: TimeInterval,
        isBreak: Bool,
        isPaused: Bool,
        title: String
    ) async {
        let activities = Activity<TomaTaskActivityAttributes>.activities
        if activities.isEmpty, !isPaused {
            await startLiveActivity(title: title, timeRemaining: timeRemaining, isBreak: isBreak)
            return
        }

        let endDate = isPaused ? Date() : Date().addingTimeInterval(timeRemaining)
        let state = TomaTaskActivityAttributes.ContentState(
            endDate: endDate,
            isBreak: isBreak,
            isPaused: isPaused,
            timeRemainingWhenPaused: timeRemaining
        )
        let content = ActivityContent(state: state, staleDate: isPaused ? nil : endDate)

        for activity in activities {
            await activity.update(content)
        }
    }

    private static func endLiveActivities() {
        for activity in Activity<TomaTaskActivityAttributes>.activities {
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    // MARK: - AlarmKit

    private static func pauseAlarm() {
        guard #available(iOS 26.0, *) else { return }
        guard let id = SharedTimerStore.alarmID else { return }
        try? AlarmManager.shared.pause(id: id)
    }

    private static func resumeAlarm() {
        guard #available(iOS 26.0, *) else { return }
        guard let id = SharedTimerStore.alarmID else { return }
        try? AlarmManager.shared.resume(id: id)
    }

    private static func ensureAlarm(duration: TimeInterval, isBreak: Bool, title: String) async {
        guard #available(iOS 26.0, *) else { return }
        if SharedTimerStore.alarmID != nil {
            resumeAlarm()
            return
        }

        // Schedule a lightweight countdown so the system alarm still fires if the app stays closed.
        let id = UUID()
        let attributes = AlarmAttributes<TomaTaskAlarmMetadata>(
            presentation: AlarmPresentation(
                alert: AlarmPresentation.Alert(
                    title: LocalizedStringResource(stringLiteral: title),
                    stopButton: AlarmButton(text: "Done", textColor: .white, systemImageName: "checkmark")
                ),
                countdown: AlarmPresentation.Countdown(
                    title: isBreak ? LocalizedStringResource("Break") : LocalizedStringResource("Focus"),
                    pauseButton: AlarmButton(text: "Pause", textColor: .orange, systemImageName: "pause.fill")
                ),
                paused: AlarmPresentation.Paused(
                    title: "Paused",
                    resumeButton: AlarmButton(text: "Resume", textColor: .green, systemImageName: "play.fill")
                )
            ),
            metadata: TomaTaskAlarmMetadata(isBreak: isBreak),
            tintColor: isBreak
                ? .init(red: 0.72, green: 0.22, blue: 0.28)
                : .init(red: 0.86, green: 0.14, blue: 0.14)
        )

        let openIntent = OpenAlarmAppIntent(alarmID: id.uuidString)
        do {
            _ = try await AlarmManager.shared.schedule(
                id: id,
                configuration: .timer(
                    duration: duration,
                    attributes: attributes,
                    stopIntent: openIntent,
                    secondaryIntent: openIntent,
                    sound: .default
                )
            )
            SharedTimerStore.alarmID = id
        } catch {
            print("FocusSessionRemote alarm schedule failed: \(error.localizedDescription)")
        }
    }
}

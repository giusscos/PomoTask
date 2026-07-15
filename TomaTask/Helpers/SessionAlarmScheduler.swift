//
//  SessionAlarmScheduler.swift
//  TomaTask
//

import AlarmKit
import SwiftUI

/// Schedules system alarms via AlarmKit (iOS 26+). Falls back to in-app audio below that.
@MainActor
enum SessionAlarmScheduler {
    private static var activeAlarmID: UUID?

    static var hasActiveAlarm: Bool {
        activeAlarmID != nil
    }

    static var usesAlarmKit: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    static func requestAuthorizationIfNeeded() async -> Bool {
        guard #available(iOS 26.0, *) else { return true }

        let manager = AlarmManager.shared
        switch manager.authorizationState {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                let state = try await manager.requestAuthorization()
                return state == .authorized
            } catch {
                print("AlarmKit authorization error: \(error.localizedDescription)")
                return false
            }
        @unknown default:
            return false
        }
    }

    static func schedule(duration: TimeInterval, isBreak: Bool, title: String) async {
        guard SessionCompletionAlert.isAlarmEnabled, duration > 0 else {
            cancel()
            return
        }

        guard #available(iOS 26.0, *) else { return }

        let authorized = await requestAuthorizationIfNeeded()
        guard authorized else {
            print("AlarmKit not authorized — system alarm will not fire")
            return
        }

        // Replace any previous countdown; never cancel from session-complete handlers.
        cancel()

        let id = UUID()
        let label = title.isEmpty
            ? (isBreak ? "Break complete" : "Focus complete")
            : title
        let countdownTitle = isBreak ? "Break" : "Focus"

        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: label),
            stopButton: AlarmButton(
                text: "Done",
                textColor: .white,
                systemImageName: "checkmark"
            )
        )

        let countdown = AlarmPresentation.Countdown(
            title: LocalizedStringResource(stringLiteral: countdownTitle),
            pauseButton: AlarmButton(
                text: "Pause",
                textColor: .orange,
                systemImageName: "pause.fill"
            )
        )

        let paused = AlarmPresentation.Paused(
            title: LocalizedStringResource(stringLiteral: "Paused"),
            resumeButton: AlarmButton(
                text: "Resume",
                textColor: .green,
                systemImageName: "play.fill"
            )
        )

        let attributes = AlarmAttributes<TomaTaskAlarmMetadata>(
            presentation: AlarmPresentation(
                alert: alert,
                countdown: countdown,
                paused: paused
            ),
            metadata: TomaTaskAlarmMetadata(isBreak: isBreak),
            tintColor: isBreak ? .orange : Color.accentColor
        )

        do {
            _ = try await AlarmManager.shared.schedule(
                id: id,
                configuration: .timer(
                    duration: duration,
                    attributes: attributes,
                    sound: .default
                )
            )
            activeAlarmID = id
        } catch {
            print("Failed to schedule AlarmKit timer: \(error.localizedDescription)")
        }
    }

    /// Pause the system countdown without dismissing it (Clock-style).
    static func pause() {
        guard #available(iOS 26.0, *) else { return }
        guard let id = activeAlarmID else { return }
        try? AlarmManager.shared.pause(id: id)
    }

    /// Resume a paused system countdown.
    static func resume() {
        guard #available(iOS 26.0, *) else { return }
        guard let id = activeAlarmID else { return }
        try? AlarmManager.shared.resume(id: id)
    }

    /// User stopped / reset the timer — cancel so it never alerts.
    static func cancel() {
        guard #available(iOS 26.0, *) else { return }
        guard let id = activeAlarmID else { return }

        try? AlarmManager.shared.cancel(id: id)
        activeAlarmID = nil
    }

    /// Session reached zero in-app. Do **not** cancel — AlarmKit must be allowed to alert.
    static func clearTrackingOnly() {
        activeAlarmID = nil
    }
}

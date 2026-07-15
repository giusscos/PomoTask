//
//  LiveActivityManager.swift
//  TomaTask
//

import ActivityKit
import Foundation

@MainActor
enum LiveActivityManager {
    /// AlarmKit already owns Lock Screen / Dynamic Island countdown UI when the session alarm is on.
    private static var shouldUseCustomLiveActivity: Bool {
        !(SessionAlarmScheduler.usesAlarmKit && SessionCompletionAlert.isAlarmEnabled)
    }

    static func start(taskTitle: String, timeRemaining: TimeInterval, isBreak: Bool) {
        // Always clear any leftover custom activity so it can't stack with AlarmKit.
        endAll()

        guard shouldUseCustomLiveActivity else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TomaTaskActivityAttributes(taskTitle: taskTitle)
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
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    static func update(timeRemaining: TimeInterval, isBreak: Bool, isPaused: Bool) {
        guard shouldUseCustomLiveActivity else {
            endAll()
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

        for activity in Activity<TomaTaskActivityAttributes>.activities {
            Task {
                await activity.update(content)
            }
        }
    }

    static func endAll() {
        for activity in Activity<TomaTaskActivityAttributes>.activities {
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}

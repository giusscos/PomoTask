//
//  SharedTimerStore.swift
//  TomaTask
//

import Foundation
import WidgetKit

/// App Group–backed session snapshot for Home Screen widgets and App Intents.
enum SharedTimerStore {
    static let appGroupID = "group.giusscos.TomaTask"
    static let widgetKind = "TomaTaskTimerWidget"

    private static let stateKey = "sharedTimerState"
    private static let alarmIDKey = "sharedAlarmID"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    struct Snapshot: Codable, Hashable {
        var isActive: Bool
        var isRunning: Bool
        var isBreak: Bool
        var endDate: Date
        var remainingWhenPaused: TimeInterval
        var title: String
        var phaseDuration: TimeInterval

        var subtitle: String {
            if !isActive { return "Focus" }
            if isRunning {
                return isBreak ? "Break" : "Focus"
            }
            return isBreak ? "Break · Paused" : "Focus · Paused"
        }

        var displayedRemaining: TimeInterval {
            if isRunning {
                return max(0, endDate.timeIntervalSinceNow)
            }
            return max(0, remainingWhenPaused)
        }

        static let idle = Snapshot(
            isActive: false,
            isRunning: false,
            isBreak: false,
            endDate: .now,
            remainingWhenPaused: 5 * 60,
            title: "Progressive",
            phaseDuration: 5 * 60
        )
    }

    static func load() -> Snapshot {
        guard let data = defaults.data(forKey: stateKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return .idle
        }
        return snapshot
    }

    static func save(_ snapshot: Snapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: stateKey)
    }

    static var alarmID: UUID? {
        get {
            guard let raw = defaults.string(forKey: alarmIDKey) else { return nil }
            return UUID(uuidString: raw)
        }
        set {
            defaults.set(newValue?.uuidString, forKey: alarmIDKey)
        }
    }

    static func clear() {
        save(.idle)
        alarmID = nil
        reloadWidgets()
    }

    static func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }

    static func formatted(_ time: TimeInterval) -> String {
        let total = max(0, Int(time.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

extension Notification.Name {
    /// Posted when a widget / Live Activity intent toggles play-pause (app process).
    static let focusSessionRemoteToggle = Notification.Name("focusSessionRemoteToggle")
}

//
//  SharedStatsStore.swift
//  TomaTask
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// App Group–backed focus history for Home Screen statistics widgets.
enum SharedStatsStore {
    static let appGroupID = SharedTimerStore.appGroupID
    static let widgetKind = "TomaTaskStatsWidget"

    private static let stateKey = "sharedStatsState"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    struct DayFocus: Codable, Hashable {
        /// Start-of-day date for this entry.
        var day: Date
        var focusSeconds: TimeInterval
    }

    struct Snapshot: Codable, Hashable {
        var days: [DayFocus]
        var updatedAt: Date

        var focusByDay: [Date: TimeInterval] {
            Dictionary(uniqueKeysWithValues: days.map { ($0.day, $0.focusSeconds) })
        }

        static let empty = Snapshot(days: [], updatedAt: .distantPast)

        static let placeholder: Snapshot = {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: .now)
            var days: [DayFocus] = []
            for offset in 0..<28 {
                guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                let seconds: TimeInterval
                switch offset % 5 {
                case 0: seconds = 95 * 60
                case 1: seconds = 45 * 60
                case 2: seconds = 20 * 60
                case 3: seconds = 0
                default: seconds = 70 * 60
                }
                if seconds > 0 {
                    days.append(DayFocus(day: day, focusSeconds: seconds))
                }
            }
            return Snapshot(days: days, updatedAt: .now)
        }()
    }

    static func load() -> Snapshot {
        guard let data = defaults.data(forKey: stateKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return .empty
        }
        return snapshot
    }

    static func save(_ snapshot: Snapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: stateKey)
    }

    static func reloadWidgets() {
#if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
#endif
    }
}

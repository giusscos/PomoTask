//
//  SharedStatsSync.swift
//  TomaTask
//

import Foundation
import SwiftData

/// Publishes SwiftData focus statistics into the App Group for Home Screen widgets.
@MainActor
enum SharedStatsSync {
    static func publish(using context: ModelContext) {
        let descriptor = FetchDescriptor<Statistics>()
        let statistics = (try? context.fetch(descriptor)) ?? []
        publish(from: statistics)
    }

    static func publish(from statistics: [Statistics]) {
        let map = StatisticsAggregator.dailyFocusMap(from: statistics)
        let days = map
            .map { SharedStatsStore.DayFocus(day: $0.key, focusSeconds: $0.value) }
            .sorted { $0.day < $1.day }
        SharedStatsStore.save(SharedStatsStore.Snapshot(days: days, updatedAt: .now))
        SharedStatsStore.reloadWidgets()
    }
}

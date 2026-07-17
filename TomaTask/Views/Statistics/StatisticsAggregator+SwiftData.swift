//
//  StatisticsAggregator+SwiftData.swift
//  TomaTask
//

import Foundation
import SwiftData

extension StatisticsAggregator {
    /// Focus seconds keyed by start-of-day (normalized via year/month/day components).
    static func dailyFocusMap(from statistics: [Statistics], calendar: Calendar = .current) -> [Date: TimeInterval] {
        var map: [Date: TimeInterval] = [:]
        for stat in statistics where stat.totalFocusTime > 0 {
            guard let day = normalizedDay(stat.date, calendar: calendar) else { continue }
            map[day, default: 0] += stat.totalFocusTime
        }
        return map
    }

    static func dailyTotals(from statistics: [Statistics], calendar: Calendar = .current) -> [Date: DayTotal] {
        var map: [Date: DayTotal] = [:]
        for stat in statistics {
            guard let day = normalizedDay(stat.date, calendar: calendar) else { continue }
            var total = map[day] ?? DayTotal(date: day)
            total.timersStarted += stat.timersStarted
            total.timersCompleted += stat.timersCompleted
            total.totalFocusTime += stat.totalFocusTime
            map[day] = total
        }
        return map
    }
}

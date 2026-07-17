import Foundation
import SwiftUI
import UIKit

enum StatisticsAggregator {
    /// Soft daily focus target used for heatmap intensity (seconds).
    static let dailyGoalSeconds: TimeInterval = 90 * 60

    static let stageFloor = Color(red: 0.98, green: 0.94, blue: 0.93)
    static let splashPink = Color(red: 0.96, green: 0.72, blue: 0.74)
    static let splashCoral = Color(red: 0.92, green: 0.38, blue: 0.36)
    static let splashDeep = Color(red: 0.86, green: 0.14, blue: 0.14)

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

    /// Stable midnight for a calendar day — avoids SwiftData Date equality quirks.
    static func normalizedDay(_ date: Date, calendar: Calendar = .current) -> Date? {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: parts)
    }

    static func intensity(for focusSeconds: TimeInterval) -> Double {
        guard focusSeconds > 0 else { return 0 }
        let ratio = focusSeconds / dailyGoalSeconds
        return min(1, max(0.18, ratio))
    }

    static func splashColor(intensity: Double) -> Color {
        guard intensity > 0 else { return stageFloor }
        if intensity < 0.4 {
            return splashPink.mix(with: splashCoral, amount: intensity / 0.4)
        }
        if intensity < 0.75 {
            return splashCoral.mix(with: splashDeep, amount: (intensity - 0.4) / 0.35)
        }
        return splashDeep
    }

    static func formatFocusTime(_ timeInterval: TimeInterval) -> String {
        let totalMinutes = Int(timeInterval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    static func currentStreak(focusByDay: [Date: TimeInterval], calendar: Calendar = .current, now: Date = Date()) -> Int {
        guard let today = normalizedDay(now, calendar: calendar) else { return 0 }
        var cursor = today
        // Allow streak to continue if today has no focus yet but yesterday did.
        if (focusByDay[today] ?? 0) <= 0 {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  let yesterdayDay = normalizedDay(yesterday, calendar: calendar)
            else { return 0 }
            cursor = yesterdayDay
            if (focusByDay[cursor] ?? 0) <= 0 { return 0 }
        }

        var streak = 0
        while (focusByDay[cursor] ?? 0) > 0 {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor),
                  let previousDay = normalizedDay(previous, calendar: calendar)
            else { break }
            cursor = previousDay
        }
        return streak
    }

    static func longestStreak(focusByDay: [Date: TimeInterval], calendar: Calendar = .current) -> Int {
        let days = focusByDay.keys.filter { (focusByDay[$0] ?? 0) > 0 }.sorted()
        guard !days.isEmpty else { return 0 }

        var best = 1
        var run = 1
        for index in 1..<days.count {
            let previous = days[index - 1]
            let current = days[index]
            if let expected = calendar.date(byAdding: .day, value: 1, to: previous),
               calendar.isDate(expected, inSameDayAs: current) {
                run += 1
                best = max(best, run)
            } else {
                run = 1
            }
        }
        return best
    }

    static func bestDay(in focusByDay: [Date: TimeInterval]) -> (date: Date, seconds: TimeInterval)? {
        focusByDay.max { $0.value < $1.value }.map { ($0.key, $0.value) }
    }

    struct DayTotal {
        var date: Date
        var timersStarted: Int = 0
        var timersCompleted: Int = 0
        var totalFocusTime: TimeInterval = 0
    }
}

private extension Color {
    func mix(with other: Color, amount: Double) -> Color {
        let t = min(1, max(0, amount))
        let a = UIColor(self)
        let b = UIColor(other)
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        return Color(
            red: Double(ar + (br - ar) * t),
            green: Double(ag + (bg - ag) * t),
            blue: Double(ab + (bb - ab) * t),
            opacity: Double(aa + (ba - aa) * t)
        )
    }
}

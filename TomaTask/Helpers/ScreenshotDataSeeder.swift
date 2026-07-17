//
//  ScreenshotDataSeeder.swift
//  TomaTask
//
//  DEBUG-only helper for seeding App Store screenshot-friendly sample data.
//

#if DEBUG
import Foundation
import SwiftData

@MainActor
enum ScreenshotDataSeeder {
    /// Seeds classic tasks and ~5 weeks of focus stats for screenshot captures.
    static func seed(into context: ModelContext) throws {
        seedTasks(into: context)
        seedStatistics(into: context)
        try context.save()
        SharedStatsSync.publish(using: context)
    }

    private static func seedTasks(into context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<TomaTask>())) ?? []
        for task in existing {
            context.delete(task)
        }

        let samples: [(String, Int, Int, Int, TomaTask.Category)] = [
            ("Deep Work", 25, 5, 4, .work),
            ("Inbox Zero", 25, 5, 3, .work),
            ("Language practice", 20, 5, 4, .study),
            ("Reading", 30, 5, 2, .study),
            ("Meal prep", 15, 5, 2, .home),
            ("Workout plan", 25, 5, 3, .wealth),
        ]

        for (title, focus, pause, reps, category) in samples {
            context.insert(
                TomaTask(
                    title: title,
                    maxDuration: focus,
                    pauseDuration: pause,
                    repetition: reps,
                    category: category
                )
            )
        }
    }

    private static func seedStatistics(into context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Statistics>())) ?? []
        for stats in existing {
            context.delete(stats)
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        // Last 7 days: solid streak for the stats screenshot.
        let recentFocusMinutes = [95, 75, 110, 60, 90, 80, 100]
        for (offset, minutes) in recentFocusMinutes.enumerated() {
            let daysBack = recentFocusMinutes.count - 1 - offset
            guard let day = calendar.date(byAdding: .day, value: -daysBack, to: today) else { continue }
            insertDay(day, focusMinutes: minutes, into: context)
        }

        // Older days: patterned variety similar to the widget placeholder.
        for offset in 7..<35 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let minutes: Int
            switch offset % 5 {
            case 0: minutes = 95
            case 1: minutes = 45
            case 2: minutes = 20
            case 3: minutes = 0
            default: minutes = 70
            }
            if minutes > 0 {
                insertDay(day, focusMinutes: minutes, into: context)
            }
        }
    }

    private static func insertDay(_ day: Date, focusMinutes: Int, into context: ModelContext) {
        let completed = max(1, focusMinutes / 25)
        context.insert(
            Statistics(
                date: day,
                timersStarted: completed + (focusMinutes % 25 > 0 ? 1 : 0),
                timersCompleted: completed,
                totalFocusTime: TimeInterval(focusMinutes * 60)
            )
        )
    }
}
#endif

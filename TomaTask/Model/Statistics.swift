import Foundation
import SwiftData

@Model
class Statistics {
    var date: Date = Date()
    var timersStarted: Int = 0
    var timersCompleted: Int = 0
    var subtasksCompleted: Int = 0
    var totalFocusTime: TimeInterval = 0 // in secods
    
    init(date: Date = Date(), timersStarted: Int = 0, timersCompleted: Int = 0, subtasksCompleted: Int = 0, totalFocusTime: TimeInterval = 0) {
        self.date = date
        self.timersStarted = timersStarted
        self.timersCompleted = timersCompleted
        self.subtasksCompleted = subtasksCompleted
        self.totalFocusTime = totalFocusTime
    }
    
    static func getDailyStats(from date: Date, context: ModelContext) -> Statistics {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Statistics> { statistics in
            statistics.date >= startOfDay && statistics.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<Statistics>(predicate: predicate)
        
        do {
            let stats = try context.fetch(descriptor)
            if let existingStats = stats.first {
                return existingStats
            } else {
                let newStats = Statistics(date: date)
                context.insert(newStats)
                try context.save()
                return newStats
            }
        } catch {
            print("Error fetching statistics: \(error)")
            let newStats = Statistics(date: date)
            context.insert(newStats)
            try? context.save()
            return newStats
        }
    }
    
    static func getWeeklyStats(from date: Date, context: ModelContext) -> [Statistics] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
            return getDailyStats(from: date, context: context)
        }
    }
} 

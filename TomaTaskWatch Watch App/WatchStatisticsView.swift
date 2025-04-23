//
//  WatchStatisticsView.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import SwiftData
import Charts

struct WatchStatisticsView: View {
    enum TimeRange: String, CaseIterable {
        case day = "Today"
        case week = "Week"
        case month = "Month"
    }

    @Environment(\.modelContext) private var modelContext
    
    @State var store = Store()

    @Query private var statistics: [Statistics]
    
    @State private var selectedTimeRange: TimeRange = .day
    @State private var showingPaywall = false
    
    var isSubscribed: Bool {
        !store.purchasedSubscriptions.isEmpty
    }
    
    var filteredStatistics: [Statistics] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .day:
            let startOfDay = calendar.startOfDay(for: now)
            return statistics.filter { stat in
                calendar.isDate(stat.date, inSameDayAs: startOfDay)
            }
        case .week:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return statistics.filter { stat in
                stat.date >= startOfWeek && stat.date <= now
            }
        case .month:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return statistics.filter { stat in
                stat.date >= startOfMonth && stat.date <= now
            }
        }
    }
    
    var body: some View {
        Group {
            if store.purchasedSubscriptions.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if isSubscribed {
                statisticsContent
            } else {
                paywallContent
            }
        }
        .navigationTitle("Stats")
    }
    
    private var statisticsContent: some View {
        List {
            Section {
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue)
                            .tag(range)
                    }
                }
            }
            
            if filteredStatistics.isEmpty {
                Section {
                    Text("No data available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Section {
                    WatchStatRow(
                        title: "Timers Started",
                        value: "\(filteredStatistics.reduce(0) { $0 + $1.timersStarted })",
                        icon: "play.circle.fill",
                        color: .blue
                    )
                    
                    WatchStatRow(
                        title: "Timers Completed",
                        value: "\(filteredStatistics.reduce(0) { $0 + $1.timersCompleted })",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    WatchStatRow(
                        title: "Subtasks Completed",
                        value: "\(filteredStatistics.reduce(0) { $0 + $1.subtasksCompleted })",
                        icon: "list.bullet.circle.fill",
                        color: .orange
                    )
                    
                    WatchStatRow(
                        title: "Focus Time",
                        value: formatTime(filteredStatistics.reduce(0) { $0 + $1.totalFocusTime }),
                        icon: "clock.fill",
                        color: .purple
                    )
                } header: {
                    Text("Overview")
                }
                
                Section {
                    if filteredStatistics.isEmpty {
                        Text("No data available")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        WatchStatisticsChartView(
                            statistics: filteredStatistics,
                            timeRange: selectedTimeRange
                        )
                    }
                } header: {
                    Text("Focus time")
                }
            }
        }
    }
    
    private var paywallContent: some View {
        ScrollView {
            Image(systemName: "chart.bar.fill")
                .font(.title)
                .foregroundColor(Color.accentColor)
            
            Text("Statistics")
                .font(.title2)
                .bold()
            
            Text("Track your productivity and progress with detailed statistics. Upgrade to Pro on your iPhone to unlock this feature.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct WatchStatisticsChartView: View {
    let statistics: [Statistics]
    let timeRange: WatchStatisticsView.TimeRange
    
    private var aggregatedStatistics: [Statistics] {
        let calendar = Calendar.current
        
        switch timeRange {
        case .day:
            return statistics
        case .week, .month:
            // Group statistics by day
            let groupedStats = Dictionary(grouping: statistics) { stat in
                calendar.startOfDay(for: stat.date)
            }
            
            // Aggregate statistics for each day
            return groupedStats.map { (date, stats) in
                let aggregated = Statistics(date: date)
                aggregated.timersStarted = stats.reduce(0) { $0 + $1.timersStarted }
                aggregated.timersCompleted = stats.reduce(0) { $0 + $1.timersCompleted }
                aggregated.subtasksCompleted = stats.reduce(0) { $0 + $1.subtasksCompleted }
                aggregated.totalFocusTime = stats.reduce(0) { $0 + $1.totalFocusTime }
                return aggregated
            }.sorted { $0.date < $1.date }
        }
    }
    
    var body: some View {
        Chart {
            ForEach(aggregatedStatistics) { stat in
                BarMark(
                    x: .value("Date", stat.date, unit: timeRange == .day ? .hour : .day),
                    y: .value("Focus Time", stat.totalFocusTime / 60)
                )
                .foregroundStyle(Color.accentColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .chartXScale(domain: getXAxisDomain())
        .chartXAxis {
            AxisMarks(values: getXAxisValues()) { value in
                AxisGridLine()
                AxisValueLabel(format: getXAxisLabelFormat())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel("\(value.index * 5) min")
            }
        }
    }
    
    private func getXAxisDomain() -> ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .day:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .hour, value: 24, to: startOfDay)!
            return startOfDay...endOfDay
            
        case .week:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
            return startOfWeek...endOfWeek
            
        case .month:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            return startOfMonth...endOfMonth
        }
    }
    
    private func getXAxisValues() -> AxisMarkValues {
        switch timeRange {
        case .day:
            return .stride(by: .hour, count: 4)
        case .week:
            return .stride(by: .day, count: 1)
        case .month:
            return .stride(by: .day, count: 5)
        }
    }
    
    private func getXAxisLabelFormat() -> Date.FormatStyle {
        switch timeRange {
        case .day:
            return .dateTime.hour()
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.day()
        }
    }
}

struct WatchStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.caption)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .bold()
        }
    }
}

#Preview {
    WatchStatisticsView()
        .modelContainer(for: TomaTask.self, inMemory: true)
} 

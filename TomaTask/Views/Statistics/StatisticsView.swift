import SwiftData
import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var statistics: [Statistics]
    
    @State var store = Store()
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedDate = Date()
    @State private var showingPaywall = false
    
    enum TimeRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
    }
    
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
            if isSubscribed {
                statisticsContent
            } else {
                paywallContent
            }
        }
        .navigationTitle("Statistics")
    }
    
    private var statisticsContent: some View {
        List {
            Section {
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical)
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Focus Time")
                        .font(.headline)
                    
                    if filteredStatistics.isEmpty {
                        Text("No data available for the selected time range")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        StatisticsChartView(
                            statistics: filteredStatistics,
                            timeRange: selectedTimeRange
                        )
                    }
                }
                .padding(.vertical)
            }
            
            Section {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                    StatCard(
                        title: "Timers Started",
                        value: "\(filteredStatistics.reduce(0) { $0 + $1.timersStarted })",
                        icon: "play.circle.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Timers Completed",
                        value: "\(filteredStatistics.reduce(0) { $0 + $1.timersCompleted })",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Subtasks Completed",
                        value: "\(filteredStatistics.reduce(0) { $0 + $1.subtasksCompleted })",
                        icon: "list.bullet.circle.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Total Focus Time",
                        value: formatTime(filteredStatistics.reduce(0) { $0 + $1.totalFocusTime }),
                        icon: "clock.fill",
                        color: .purple
                    )
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
        }
    }
    
    private var paywallContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.accentColor)
            
            Text("Statistics")
                .font(.title)
                .bold()
            
            Text("Track your productivity and progress with detailed statistics. Upgrade to Pro to unlock this feature.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button {
                showingPaywall = true
            } label: {
                Text("Upgrade to Pro")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $showingPaywall) {
            SubscriptionStoreContentView()
        }
    }
    
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

struct StatisticsChartView: View {
    let statistics: [Statistics]
    let timeRange: StatisticsView.TimeRange
    
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
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(height: 200)
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
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
            return startOfMonth...endOfMonth
        }
    }
    
    private func getXAxisValues() -> AxisMarkValues {
        switch timeRange {
        case .day:
            return .stride(by: .hour, count: 6)
        case .week:
            return .stride(by: .day, count: 1)
        case .month:
            return .stride(by: .day, count: 7)
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        StatisticsView()
    }
} 

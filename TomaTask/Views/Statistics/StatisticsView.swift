import SwiftData
import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(Store.self) private var store
    @Query private var statistics: [Statistics]

    @State private var displayedMonth = Date()
    @State private var selectedDay: Date?
    @State private var showingPaywall = false

    private let calendar = Calendar.current

    private var isSubscribed: Bool {
        !store.purchasedSubscriptions.isEmpty
    }

    private var focusByDay: [Date: TimeInterval] {
        StatisticsAggregator.dailyFocusMap(from: statistics)
    }

    private var dayTotals: [Date: StatisticsAggregator.DayTotal] {
        StatisticsAggregator.dailyTotals(from: statistics)
    }

    private var weekFocusSeconds: TimeInterval {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return focusByDay
            .filter { $0.key >= startOfWeek }
            .reduce(0) { $0 + $1.value }
    }

    private var monthFocusSeconds: TimeInterval {
        guard let monthStart = calendar.dateInterval(of: .month, for: displayedMonth)?.start,
              let monthEnd = calendar.dateInterval(of: .month, for: displayedMonth)?.end
        else { return 0 }
        return focusByDay
            .filter { $0.key >= monthStart && $0.key < monthEnd }
            .reduce(0) { $0 + $1.value }
    }

    private var currentStreak: Int {
        StatisticsAggregator.currentStreak(focusByDay: focusByDay)
    }

    private var longestStreak: Int {
        StatisticsAggregator.longestStreak(focusByDay: focusByDay)
    }

    private var activeDaysInDisplayedMonth: Int {
        guard let monthStart = calendar.dateInterval(of: .month, for: displayedMonth)?.start,
              let monthEnd = calendar.dateInterval(of: .month, for: displayedMonth)?.end
        else { return 0 }
        return focusByDay.filter { $0.key >= monthStart && $0.key < monthEnd && $0.value > 0 }.count
    }

    private var bestDayInDisplayedMonth: (date: Date, seconds: TimeInterval)? {
        guard let monthStart = calendar.dateInterval(of: .month, for: displayedMonth)?.start,
              let monthEnd = calendar.dateInterval(of: .month, for: displayedMonth)?.end
        else { return nil }
        let monthMap = focusByDay.filter { $0.key >= monthStart && $0.key < monthEnd }
        return StatisticsAggregator.bestDay(in: monthMap)
    }

    private var weekChartData: [(date: Date, minutes: Double)] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return (0..<7).compactMap { offset -> (Date, Double)? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfWeek) else { return nil }
            let start = calendar.startOfDay(for: day)
            return (start, (focusByDay[start] ?? 0) / 60)
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
        .sheet(isPresented: Binding(
            get: { selectedDay != nil },
            set: { if !$0 { selectedDay = nil } }
        )) {
            if let selectedDay {
                DayFocusDetailSheet(
                    date: selectedDay,
                    total: dayTotals[calendar.startOfDay(for: selectedDay)]
                )
            }
        }
    }

    private var statisticsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headline

                TomatoSplashCalendarView(
                    focusByDay: focusByDay,
                    displayedMonth: $displayedMonth,
                    selectedDay: $selectedDay
                )

                metricGrid

                weekChartSection
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(StatisticsAggregator.formatFocusTime(weekFocusSeconds)) this week")
                .font(.title2.weight(.bold))
                .fontDesign(.rounded)

            HStack(spacing: 10) {
                Label("\(currentStreak)-day streak", systemImage: "flame.fill")
                    .foregroundStyle(StatisticsAggregator.splashDeep)

                Text("·")
                    .foregroundStyle(.secondary)

                Text("Best run \(longestStreak)")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline.weight(.semibold))
            .fontDesign(.rounded)
        }
        .padding(.top, 8)
    }

    private var metricGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Active days",
                value: "\(activeDaysInDisplayedMonth)",
                icon: "calendar",
                color: StatisticsAggregator.splashCoral
            )
            StatCard(
                title: "Month focus",
                value: StatisticsAggregator.formatFocusTime(monthFocusSeconds),
                icon: "clock.fill",
                color: StatisticsAggregator.splashDeep
            )
            StatCard(
                title: "Best day",
                value: bestDayValue,
                icon: "star.fill",
                color: .orange
            )
            StatCard(
                title: "Longest streak",
                value: "\(longestStreak)",
                icon: "flame.fill",
                color: StatisticsAggregator.splashDeep
            )
        }
    }

    private var bestDayValue: String {
        guard let best = bestDayInDisplayedMonth else { return "—" }
        return StatisticsAggregator.formatFocusTime(best.seconds)
    }

    private var weekChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This week")
                .font(.headline.weight(.semibold))
                .fontDesign(.rounded)

            Chart {
                ForEach(weekChartData, id: \.date) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(StatisticsAggregator.splashDeep.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

    private var paywallContent: some View {
        VStack(spacing: 20) {
            ZStack {
                TomatoSplashShape(seed: 42)
                    .fill(StatisticsAggregator.splashDeep.opacity(0.9))
                    .frame(width: 88, height: 88)
                Image(systemName: "calendar")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("Tomato splash calendar")
                .font(.title.weight(.bold))
                .fontDesign(.rounded)

            Text("See every focus day as a tomato hit — streaks, heat, and a stage full of smashed tomatoes. Unlock with Progressive Pro.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button {
                showingPaywall = true
            } label: {
                Text("Upgrade to Pro")
                    .font(.headline.weight(.bold))
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(OnboardingStyle.tomatoRed)
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $showingPaywall) {
            SubscriptionStoreContentView()
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
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title2.weight(.bold))
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        StatisticsView()
            .environment(Store())
    }
}

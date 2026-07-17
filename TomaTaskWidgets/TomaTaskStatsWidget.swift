//
//  TomaTaskStatsWidget.swift
//  TomaTaskWidgets
//

import Charts
import SwiftUI
import WidgetKit

/// Home Screen widget showing weekly focus, streaks, and the tomato splash calendar.
struct TomaTaskStatsWidget: Widget {
    let kind = SharedStatsStore.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsWidgetProvider()) { entry in
            StatsWidgetEntryView(entry: entry)
                .widgetURL(URL(string: "tomatask://statistics"))
        }
        .configurationDisplayName("Focus Stats")
        .description("Week focus and streaks in small/medium; tomato splash calendar in large.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

// MARK: - Timeline

struct StatsWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedStatsStore.Snapshot
}

struct StatsWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> StatsWidgetEntry {
        StatsWidgetEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (StatsWidgetEntry) -> Void) {
        if context.isPreview {
            completion(StatsWidgetEntry(date: .now, snapshot: .placeholder))
            return
        }
        completion(StatsWidgetEntry(date: .now, snapshot: SharedStatsStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StatsWidgetEntry>) -> Void) {
        let entry = StatsWidgetEntry(date: .now, snapshot: SharedStatsStore.load())
        let calendar = Calendar.current
        let tomorrow = calendar.nextDate(
            after: .now,
            matching: DateComponents(hour: 0, minute: 1),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(tomorrow)))
    }
}

// MARK: - Root

struct StatsWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: StatsWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallStatsWidgetView(metrics: StatsWidgetMetrics(snapshot: entry.snapshot, now: entry.date))
            case .systemMedium:
                MediumStatsWidgetView(metrics: StatsWidgetMetrics(snapshot: entry.snapshot, now: entry.date))
            default:
                LargeStatsWidgetView(metrics: StatsWidgetMetrics(snapshot: entry.snapshot, now: entry.date))
            }
        }
        .containerBackground(for: .widget) {
            StatisticsAggregator.stageFloor
        }
    }
}

// MARK: - Metrics

struct StatsWidgetMetrics {
    let focusByDay: [Date: TimeInterval]
    let now: Date
    private let calendar = Calendar.current

    init(snapshot: SharedStatsStore.Snapshot, now: Date = .now) {
        self.focusByDay = snapshot.focusByDay
        self.now = now
    }

    var weekFocusSeconds: TimeInterval {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        return focusByDay
            .filter { $0.key >= startOfWeek }
            .reduce(0) { $0 + $1.value }
    }

    var monthFocusSeconds: TimeInterval {
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start,
              let monthEnd = calendar.dateInterval(of: .month, for: now)?.end
        else { return 0 }
        return focusByDay
            .filter { $0.key >= monthStart && $0.key < monthEnd }
            .reduce(0) { $0 + $1.value }
    }

    var currentStreak: Int {
        StatisticsAggregator.currentStreak(focusByDay: focusByDay, calendar: calendar, now: now)
    }

    var longestStreak: Int {
        StatisticsAggregator.longestStreak(focusByDay: focusByDay, calendar: calendar)
    }

    var activeDaysInMonth: Int {
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start,
              let monthEnd = calendar.dateInterval(of: .month, for: now)?.end
        else { return 0 }
        return focusByDay.filter { $0.key >= monthStart && $0.key < monthEnd && $0.value > 0 }.count
    }

    var bestDayInMonth: (date: Date, seconds: TimeInterval)? {
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start,
              let monthEnd = calendar.dateInterval(of: .month, for: now)?.end
        else { return nil }
        let monthMap = focusByDay.filter { $0.key >= monthStart && $0.key < monthEnd }
        return StatisticsAggregator.bestDay(in: monthMap)
    }

    var bestDayValue: String {
        guard let best = bestDayInMonth else { return "—" }
        return StatisticsAggregator.formatFocusTime(best.seconds)
    }

    var weekChartData: [(date: Date, minutes: Double)] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        return (0..<7).compactMap { offset -> (Date, Double)? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfWeek) else { return nil }
            let start = calendar.startOfDay(for: day)
            return (start, (focusByDay[start] ?? 0) / 60)
        }
    }

    var monthTitle: String {
        now.formatted(.dateTime.month(.wide).year())
    }

    var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1
        return Array(symbols[firstWeekday...]) + Array(symbols[..<firstWeekday])
    }

    var daysInMonthGrid: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: now),
              let firstWeekdayOfMonth = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else { return [] }

        let leadingEmpty = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7
        let dayCount = calendar.range(of: .day, in: .month, for: now)?.count ?? 0

        var cells: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for day in 0..<dayCount {
            if let date = calendar.date(byAdding: .day, value: day, to: monthInterval.start),
               let normalized = StatisticsAggregator.normalizedDay(date, calendar: calendar) {
                cells.append(normalized)
            }
        }
        while cells.count % 7 != 0 {
            cells.append(nil)
        }
        return cells
    }

    func focusSeconds(on date: Date) -> TimeInterval {
        guard let day = StatisticsAggregator.normalizedDay(date, calendar: calendar) else { return 0 }
        return focusByDay[day] ?? 0
    }
}

// MARK: - Small

private struct SmallStatsWidgetView: View {
    let metrics: StatsWidgetMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(StatisticsAggregator.splashDeep)

            Spacer(minLength: 0)

            Text(StatisticsAggregator.formatFocusTime(metrics.weekFocusSeconds))
                .font(.title.weight(.bold))
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("this week")
                .font(.subheadline.weight(.semibold))
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)

            Label("\(metrics.currentStreak)-day streak", systemImage: "flame.fill")
                .font(.caption.weight(.semibold))
                .fontDesign(.rounded)
                .foregroundStyle(StatisticsAggregator.splashDeep)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
    }
}

// MARK: - Medium

private struct MediumStatsWidgetView: View {
    let metrics: StatsWidgetMetrics

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(StatisticsAggregator.formatFocusTime(metrics.weekFocusSeconds)) this week")
                    .font(.title3.weight(.bold))
                    .fontDesign(.rounded)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                Label("\(metrics.currentStreak)-day streak", systemImage: "flame.fill")
                    .font(.caption.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundStyle(StatisticsAggregator.splashDeep)

                Text("Best run \(metrics.longestStreak)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    StatsWidgetMetricChip(
                        title: "Active",
                        value: "\(metrics.activeDaysInMonth)",
                        icon: "calendar",
                        color: StatisticsAggregator.splashCoral
                    )
                    StatsWidgetMetricChip(
                        title: "Month",
                        value: StatisticsAggregator.formatFocusTime(metrics.monthFocusSeconds),
                        icon: "clock.fill",
                        color: StatisticsAggregator.splashDeep
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            StatsWidgetWeekChart(data: metrics.weekChartData)
                .frame(width: 148)
        }
        .padding(16)
    }
}

// MARK: - Large

private struct LargeStatsWidgetView: View {
    let metrics: StatsWidgetMetrics

    var body: some View {
        StatsWidgetCalendarView(metrics: metrics, compact: false)
            .padding(14)
    }
}

// MARK: - Shared chrome

private struct StatsWidgetMetricChip: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: icon)
                .font(.caption2)
                .foregroundStyle(color)
                .labelStyle(.titleAndIcon)
                .lineLimit(1)

            Text(value)
                .font(.caption.weight(.bold))
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct StatsWidgetWeekChart: View {
    let data: [(date: Date, minutes: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("This week")
                .font(.caption.weight(.semibold))
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)

            Chart {
                ForEach(data, id: \.date) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(StatisticsAggregator.splashDeep.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .font(.caption2)
                }
            }
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
        }
        .padding(10)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct StatsWidgetCalendarView: View {
    let metrics: StatsWidgetMetrics
    var compact: Bool = true

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: compact ? 3 : 6), count: 7)
    }

    private var cellHeight: CGFloat { compact ? 22 : 36 }
    private var splashSize: CGFloat { compact ? 18 : 30 }
    private var emptyDotSize: CGFloat { compact ? 16 : 26 }
    private var dayFontSize: CGFloat { compact ? 8 : 12 }
    private var todayRingSize: CGFloat { compact ? 20 : 34 }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 8 : 12) {
            Text(metrics.monthTitle)
                .font(compact ? .subheadline.weight(.bold) : .headline.weight(.bold))
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity)

            LazyVGrid(columns: columns, spacing: compact ? 4 : 8) {
                ForEach(Array(metrics.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.system(size: compact ? 9 : 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(metrics.daysInMonthGrid.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(for: date)
                    } else {
                        Color.clear.frame(height: cellHeight)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(compact ? 10 : 14)
        .background(
            RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                .strokeBorder(StatisticsAggregator.splashDeep.opacity(0.08), lineWidth: 1)
        )
    }

    private func dayCell(for date: Date) -> some View {
        let focus = metrics.focusSeconds(on: date)
        let intensity = StatisticsAggregator.intensity(for: focus)
        let color = StatisticsAggregator.splashColor(intensity: intensity)
        let isToday = Calendar.current.isDateInToday(date)
        let dayNumber = Calendar.current.component(.day, from: date)
        let seed = UInt64(abs(date.timeIntervalSinceReferenceDate))

        return ZStack {
            if focus > 0 {
                LiquidTomatoSplash(
                    seed: seed,
                    color: color,
                    size: splashSize,
                    explosiveness: 0.55 + CGFloat(intensity) * 0.45,
                    showHighlight: !compact
                )
            } else {
                Circle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: emptyDotSize, height: emptyDotSize)
            }

            Text("\(dayNumber)")
                .font(.system(size: dayFontSize, weight: focus > 0 ? .bold : .medium, design: .rounded))
                .foregroundStyle(focus > 0 ? Color.white : Color.secondary)

            if isToday {
                Circle()
                    .strokeBorder(StatisticsAggregator.splashDeep.opacity(0.55), lineWidth: compact ? 1 : 1.5)
                    .frame(width: todayRingSize, height: todayRingSize)
            }
        }
        .frame(height: cellHeight)
        .frame(maxWidth: .infinity)
    }
}

#Preview("Small", as: .systemSmall) {
    TomaTaskStatsWidget()
} timeline: {
    StatsWidgetEntry(date: .now, snapshot: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    TomaTaskStatsWidget()
} timeline: {
    StatsWidgetEntry(date: .now, snapshot: .placeholder)
}

#Preview("Large", as: .systemLarge) {
    TomaTaskStatsWidget()
} timeline: {
    StatsWidgetEntry(date: .now, snapshot: .placeholder)
}

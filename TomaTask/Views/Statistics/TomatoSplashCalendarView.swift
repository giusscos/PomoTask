import SwiftUI

struct TomatoSplashCalendarView: View {
    let focusByDay: [Date: TimeInterval]
    @Binding var displayedMonth: Date
    @Binding var selectedDay: Date?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var cellFrames: [DayCellFrame] = []
    @State private var revealedDays: Set<Date> = []
    @State private var animationToken = 0
    @State private var revealTask: Task<Void, Never>?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1
        return Array(symbols[firstWeekday...]) + Array(symbols[..<firstWeekday])
    }

    private var daysInGrid: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeekdayOfMonth = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else { return [] }

        let leadingEmpty = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7
        let dayCount = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 0

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

    private var activeDays: [Date] {
        daysInGrid.compactMap { date in
            guard let date, focusSeconds(on: date) > 0 else { return nil }
            return date
        }
        .sorted()
    }

    /// Frames for days that actually have focus — joined by calendar day, not Date equality.
    private var assaultTargets: [DayCellFrame] {
        cellFrames.compactMap { frame in
            let seconds = focusSeconds(on: frame.date)
            guard seconds > 0, frame.frame.width > 1 else { return nil }
            return DayCellFrame(date: frame.date, focusSeconds: seconds, frame: frame.frame)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(daysInGrid.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(for: date)
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(StatisticsAggregator.stageFloor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(StatisticsAggregator.splashDeep.opacity(0.08), lineWidth: 1)
        )
        .coordinateSpace(name: "tomatoStage")
        .overlay {
            if !reduceMotion {
                TomatoAssaultOverlay(
                    targets: assaultTargets,
                    animationToken: animationToken,
                    onImpact: { date in
                        reveal(date)
                    },
                    onFinished: {
                        // Ensure every focus day is visible even if a throw was skipped.
                        revealAllActiveDays(animated: true)
                    }
                )
                .allowsHitTesting(false)
            }
        }
        .onPreferenceChange(DayCellFramesKey.self) { frames in
            // Deduplicate by day components.
            var best: [Date: DayCellFrame] = [:]
            for frame in frames where frame.frame.width > 1 {
                let day = calendar.startOfDay(for: frame.date)
                best[day] = DayCellFrame(
                    date: day,
                    focusSeconds: focusSeconds(on: day),
                    frame: frame.frame
                )
            }
            cellFrames = Array(best.values)
        }
        .onAppear {
            startAssaultSequence()
        }
        .onChange(of: displayedMonth) { _, _ in
            startAssaultSequence()
        }
        .onChange(of: activeDays.map(\.timeIntervalSinceReferenceDate)) { _, _ in
            // Stats may load after first paint.
            if revealedDays.isEmpty {
                startAssaultSequence()
            }
        }
        .onDisappear {
            revealTask?.cancel()
        }
    }

    /// Robust focus lookup — matches by calendar day, not exact Date equality.
    private func focusSeconds(on date: Date) -> TimeInterval {
        let day = calendar.startOfDay(for: date)
        if let exact = focusByDay[day], exact > 0 { return exact }
        for (key, value) in focusByDay where value > 0 {
            if calendar.isDate(key, inSameDayAs: day) {
                return value
            }
        }
        return 0
    }

    private func startAssaultSequence() {
        revealTask?.cancel()
        revealedDays = []
        animationToken += 1

        let days = activeDays
        guard !days.isEmpty else {
            return
        }

        if reduceMotion {
            revealedDays = Set(days)
            return
        }

        // Primary: UIKit assault calls reveal(date) on impact.
        // Safety net: if preferences/UIKit never fire, still show splashes.
        revealTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard !Task.isCancelled else { return }
            if revealedDays.count < days.count {
                revealAllActiveDays(animated: true)
            }
        }
    }

    private func reveal(_ date: Date) {
        let day = calendar.startOfDay(for: date)
        guard !revealedDays.contains(day) else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            _ = revealedDays.insert(day)
        }
    }

    private func revealAllActiveDays(animated: Bool) {
        let days = Set(activeDays)
        guard revealedDays != days else { return }
        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                revealedDays = days
            }
        } else {
            revealedDays = days
        }
    }

    private var header: some View {
        HStack {
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(StatisticsAggregator.splashDeep)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text(monthTitle)
                .font(.headline.weight(.bold))
                .fontDesign(.rounded)

            Spacer()

            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(canGoForward ? StatisticsAggregator.splashDeep : .secondary.opacity(0.35))
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!canGoForward)
        }
    }

    private var canGoForward: Bool {
        let thisMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let displayed = calendar.dateInterval(of: .month, for: displayedMonth)?.start ?? displayedMonth
        return displayed < thisMonth
    }

    private func dayCell(for date: Date) -> some View {
        let focus = focusSeconds(on: date)
        let intensity = StatisticsAggregator.intensity(for: focus)
        let color = StatisticsAggregator.splashColor(intensity: intensity)
        let isToday = calendar.isDateInToday(date)
        let isSelected = selectedDay.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        let dayNumber = calendar.component(.day, from: date)
        let seed = UInt64(abs(date.timeIntervalSinceReferenceDate))
        let showSplash = focus > 0 && revealedDays.contains(where: { calendar.isDate($0, inSameDayAs: date) })

        return Button {
            selectedDay = date
        } label: {
            ZStack {
                if focus > 0 {
                    LiquidTomatoSplash(
                        seed: seed,
                        color: color,
                        size: 32,
                        explosiveness: 0.55 + CGFloat(intensity) * 0.55
                    )
                    .opacity(showSplash ? 1 : 0)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 30, height: 30)
                }

                Text("\(dayNumber)")
                    .font(.caption.weight(focus > 0 && showSplash ? .bold : .medium))
                    .fontDesign(.rounded)
                    .foregroundStyle(focus > 0 && showSplash ? Color.white : Color.secondary)
                    .shadow(color: showSplash ? .black.opacity(0.2) : .clear, radius: 1)

                if isToday {
                    Circle()
                        .strokeBorder(StatisticsAggregator.splashDeep.opacity(0.55), lineWidth: 1.5)
                        .frame(width: 36, height: 36)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .scaleEffect(isSelected ? 1.08 : 1)
        }
        .buttonStyle(.plain)
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: DayCellFramesKey.self,
                    value: [
                        DayCellFrame(
                            date: date,
                            focusSeconds: focus,
                            frame: geo.frame(in: .named("tomatoStage"))
                        )
                    ]
                )
            }
        )
        .accessibilityLabel(accessibilityLabel(for: date, focus: focus))
    }

    private func accessibilityLabel(for date: Date, focus: TimeInterval) -> String {
        let day = date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        if focus > 0 {
            return String(localized: "\(day), \(StatisticsAggregator.formatFocusTime(focus)) focused")
        }
        return String(localized: "\(day), no focus")
    }

    private func shiftMonth(by value: Int) {
        guard let next = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            displayedMonth = next
        }
    }
}

struct DayFocusDetailSheet: View {
    let date: Date
    let total: StatisticsAggregator.DayTotal?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Focus time", value: StatisticsAggregator.formatFocusTime(total?.totalFocusTime ?? 0))
                    LabeledContent("Timers started", value: "\(total?.timersStarted ?? 0)")
                    LabeledContent("Timers completed", value: "\(total?.timersCompleted ?? 0)")
                } header: {
                    Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                }
            }
            .navigationTitle("Day splash")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

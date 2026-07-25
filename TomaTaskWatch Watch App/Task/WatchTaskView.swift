//
//  WatchTaskView.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import WatchKit

struct WatchTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @State var task: TomaTask

    @State private var timer: Timer?
    @State var time: TimeInterval = 0
    @State private var isRunning = false
    @State private var pauseTime = false
    @State private var repetition = 0

    @State private var startAnchor: Date?
    @State private var timeAtAnchor: TimeInterval = 0
    @State private var pendingFocusSeconds: TimeInterval = 0
    @State private var timerSecondsElapsed = 0
    @State private var sessionStats: Statistics?

    var maxDuration: TimeInterval {
        Double(task.maxDuration * 60)
    }

    var pauseDuration: TimeInterval {
        Double(task.pauseDuration * 60)
    }

    private var canStop: Bool {
        isRunning || pauseTime || repetition > 0 || time != maxDuration
    }

    var body: some View {
        ZStack {
            BrandColors.phaseColor(isBreak: pauseTime)
                .ignoresSafeArea()

            VStack(spacing: 6) {
                Text(pauseTime ? "Break" : (task.title.isEmpty ? "Focus" : task.title))
                    .font(.caption2.weight(.semibold))
                    .fontWidth(.condensed)
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .opacity(0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(formattedTime())
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text("\(min(repetition + 1, task.repetition))/\(task.repetition)")
                    .font(.caption2.weight(.medium))
                    .opacity(0.75)

                HStack(spacing: 24) {
                    Button {
                        restartTimer()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canStop)
                    .opacity(canStop ? 1 : 0.35)

                    Button {
                        togglePlayPause()
                    } label: {
                        Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 36))
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .foregroundStyle(.white)
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if time == 0 {
                time = maxDuration
            }
        }
        .onDisappear {
            if isRunning {
                pauseTimer()
            }
        }
    }

    func formattedTime() -> String {
        SharedTimerStore.formatted(time)
    }

    private func togglePlayPause() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func startTimer() {
        if task.repetition == repetition {
            repetition = 0
            pauseTime = false
            time = maxDuration
        }

        let stats = ensureSessionStats()
        stats.timersStarted += 1
        try? modelContext.save()

        WatchTimerRuntime.shared.start()
        WatchSessionNotifier.schedule(after: time, isBreak: pauseTime)

        startAnchor = Date()
        timeAtAnchor = time
        timerSecondsElapsed = 0

        timer?.invalidate()
        let tick = Timer(timeInterval: 0.25, repeats: true) { _ in
            guard let anchor = startAnchor else { return }
            let elapsed = Date().timeIntervalSince(anchor)
            let newTime = max(0, timeAtAnchor - elapsed)

            if !pauseTime {
                let newSecondsElapsed = Int(elapsed)
                let delta = newSecondsElapsed - timerSecondsElapsed
                if delta > 0 {
                    pendingFocusSeconds += TimeInterval(delta)
                    timerSecondsElapsed = newSecondsElapsed
                }
            }

            if newTime > 0 {
                time = newTime
            } else {
                time = 0
                handlePhaseCompletion()
            }
        }
        RunLoop.main.add(tick, forMode: .common)
        timer = tick
        isRunning = true
    }

    private func pauseTimer() {
        startAnchor = nil
        flushFocusStats()
        isRunning = false
        timer?.invalidate()
        timer = nil
        WatchTimerRuntime.shared.stop()
        WatchSessionNotifier.cancel()
    }

    private func handlePhaseCompletion() {
        flushFocusStats()
        pauseTimer()
        playSound()

        pauseTime.toggle()

        if pauseTime {
            repetition += 1
            if task.repetition == repetition {
                let stats = ensureSessionStats()
                stats.timersCompleted += 1
                try? modelContext.save()
                // Session complete — skip a trailing break.
                pauseTime = false
                time = maxDuration
                return
            }
        }

        time = pauseTime ? pauseDuration : maxDuration
    }

    func restartTimer() {
        startAnchor = nil
        flushFocusStats()
        isRunning = false
        repetition = 0
        pauseTime = false
        timer?.invalidate()
        timer = nil
        WatchTimerRuntime.shared.stop()
        WatchSessionNotifier.cancel()
        time = maxDuration
        sessionStats = nil
    }

    func playSound() {
        WKInterfaceDevice.current().play(.notification)
    }

    private func ensureSessionStats() -> Statistics {
        if let sessionStats { return sessionStats }
        let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
        sessionStats = stats
        return stats
    }

    private func flushFocusStats() {
        guard pendingFocusSeconds > 0 else { return }
        let stats = ensureSessionStats()
        stats.totalFocusTime += pendingFocusSeconds
        pendingFocusSeconds = 0
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        WatchTaskView(task: TomaTask())
            .modelContainer(for: TomaTask.self, inMemory: true)
    }
}

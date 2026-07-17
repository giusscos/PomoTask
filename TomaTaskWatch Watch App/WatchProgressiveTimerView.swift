//
//  WatchProgressiveTimerView.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import WatchKit

private let watchDefaultTimeStart: Double = 5 * 60
private let watchDefaultMinSeconds: Double = 3 * 60
private let watchDefaultMaxSeconds: Double = 25 * 60
private let watchBreakMinSeconds: Double = 3 * 60
private let watchBreakMaxSeconds: Double = 8 * 60

struct WatchProgressiveTimerView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var time: TimeInterval = watchDefaultTimeStart
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var isBreakTime = false
    @State private var selectedTime = watchDefaultTimeStart
    @State private var lastFocusDuration = watchDefaultTimeStart
    @State private var showingSheet = false
    @State private var awaitingPlayAfterBreak = false

    @State private var startAnchor: Date?
    @State private var timeAtAnchor: TimeInterval = 0
    @State private var pendingFocusSeconds: TimeInterval = 0
    @State private var timerSecondsElapsed = 0
    @State private var sessionStats: Statistics?

    /// True when the active session was started/mirrored from iPhone.
    @State private var mirrorsPhoneSession = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text(statusTitle)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(SharedTimerStore.formatted(time))
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()

                HStack(spacing: 24) {
                    Button {
                        resetTimer()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.title2)
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isRunning && time == selectedTime && !awaitingPlayAfterBreak)

                    Button {
                        togglePlayPause()
                    } label: {
                        Label(
                            isRunning ? "Pause" : "Start",
                            systemImage: isRunning ? "pause.fill" : "play.fill"
                        )
                        .font(.title2)
                        .labelStyle(.iconOnly)
                        .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                }
                .foregroundStyle(.primary)
            }
            .padding()
            .navigationTitle("Progressive")
            .sheet(isPresented: $showingSheet) {
                WatchFeedbackSheet(
                    currentFocusSeconds: lastFocusDuration,
                    onFlow: { applyFlow() },
                    onShorter: { applyShorter() },
                    onBreak: { applyBreak() }
                )
            }
            .onAppear {
                adoptCompanionSnapshotIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: .watchCompanionSnapshotDidUpdate)) { _ in
                adoptCompanionSnapshotIfNeeded()
            }
        }
    }

    private var statusTitle: String {
        if awaitingPlayAfterBreak { return "Break over" }
        return isBreakTime ? "Break time" : "Focus time"
    }

    private func togglePlayPause() {
        awaitingPlayAfterBreak = false
        if isRunning {
            pauseTimer()
        } else {
            mirrorsPhoneSession = false
            startTimer(ownsSession: true)
        }
    }

    // MARK: - Timer

    private func startTimer(ownsSession: Bool) {
        if ownsSession {
            let stats = ensureSessionStats()
            stats.timersStarted += 1
            try? modelContext.save()

            mirrorsPhoneSession = false
            WatchTimerRuntime.shared.start()
            WatchSessionNotifier.schedule(after: time, isBreak: isBreakTime)
            SharedTimerSync.publishRunning(
                title: isBreakTime ? "Break" : "Progressive",
                timeRemaining: time,
                phaseDuration: selectedTime,
                isBreak: isBreakTime
            )
        } else {
            mirrorsPhoneSession = true
            WatchTimerRuntime.shared.start()
            WatchSessionNotifier.cancel()
        }

        startAnchor = Date()
        timeAtAnchor = time
        timerSecondsElapsed = 0

        timer?.invalidate()
        let tick = Timer(timeInterval: 0.25, repeats: true) { _ in
            guard let anchor = startAnchor else { return }
            let elapsed = Date().timeIntervalSince(anchor)
            let newTime = max(0, timeAtAnchor - elapsed)

            if !isBreakTime && ownsSession {
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
                handleLocalCompletion()
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

        if time > 0 {
            SharedTimerSync.publishPaused(
                title: isBreakTime ? "Break" : "Progressive",
                timeRemaining: time,
                phaseDuration: selectedTime,
                isBreak: isBreakTime
            )
        } else {
            SharedTimerSync.publishIdle(phaseDuration: selectedTime)
        }
    }

    private func resetTimer() {
        startAnchor = nil
        flushFocusStats()
        isRunning = false
        timer?.invalidate()
        timer = nil
        WatchTimerRuntime.shared.stop()
        WatchSessionNotifier.cancel()
        mirrorsPhoneSession = false
        awaitingPlayAfterBreak = false
        showingSheet = false
        isBreakTime = false
        time = watchDefaultTimeStart
        selectedTime = watchDefaultTimeStart
        lastFocusDuration = watchDefaultTimeStart
        sessionStats = nil
        SharedTimerSync.publishIdle(phaseDuration: watchDefaultTimeStart)
    }

    private func handleLocalCompletion() {
        if mirrorsPhoneSession {
            isRunning = false
            timer?.invalidate()
            timer = nil
            startAnchor = nil
            WatchTimerRuntime.shared.stop()
            return
        }

        let wasBreak = isBreakTime
        pauseTimer()
        WKInterfaceDevice.current().play(.notification)

        flushFocusStats()
        let stats = ensureSessionStats()
        stats.timersCompleted += 1
        try? modelContext.save()

        if wasBreak {
            isBreakTime = false
            selectedTime = lastFocusDuration
            time = lastFocusDuration
            awaitingPlayAfterBreak = true
        } else {
            showingSheet = true
        }
    }

    // MARK: - Feedback

    private func applyFlow() {
        let next = min(lastFocusDuration + watchDefaultMinSeconds, watchDefaultMaxSeconds)
        lastFocusDuration = next
        selectedTime = next
        time = next
        isBreakTime = false
        showingSheet = false
        startTimer(ownsSession: true)
    }

    private func applyShorter() {
        let next = max(lastFocusDuration - watchDefaultMinSeconds, watchDefaultMinSeconds)
        lastFocusDuration = next
        selectedTime = next
        time = next
        isBreakTime = false
        awaitingPlayAfterBreak = true
        showingSheet = false
        SharedTimerSync.publishPaused(
            title: "Progressive",
            timeRemaining: time,
            phaseDuration: selectedTime,
            isBreak: false
        )
    }

    private func applyBreak() {
        let raw = lastFocusDuration * 0.2
        let breakSeconds = min(max(raw, watchBreakMinSeconds), watchBreakMaxSeconds)
        selectedTime = breakSeconds
        time = breakSeconds
        isBreakTime = true
        showingSheet = false
        startTimer(ownsSession: true)
    }

    // MARK: - Companion sync

    private func adoptCompanionSnapshotIfNeeded() {
        let snapshot = SharedTimerStore.load()
        let progressiveTitles = ["Progressive", "Break"]
        guard !snapshot.isActive || progressiveTitles.contains(snapshot.title) else { return }

        // Ignore echoes of our own Watch-owned publishes while actively timing.
        if isRunning && !mirrorsPhoneSession { return }

        SharedTimerSync.suppressWatchBroadcast = true
        defer { SharedTimerSync.suppressWatchBroadcast = false }

        timer?.invalidate()
        timer = nil
        startAnchor = nil

        isBreakTime = snapshot.isBreak
        selectedTime = snapshot.phaseDuration
        if !snapshot.isBreak {
            lastFocusDuration = snapshot.phaseDuration
        }

        if snapshot.isRunning {
            time = snapshot.displayedRemaining
            guard time > 0 else {
                isRunning = false
                return
            }
            awaitingPlayAfterBreak = false
            startTimer(ownsSession: false)
        } else if snapshot.isActive {
            time = snapshot.remainingWhenPaused
            isRunning = false
            mirrorsPhoneSession = true
            awaitingPlayAfterBreak = !snapshot.isBreak && snapshot.remainingWhenPaused > 0
            WatchTimerRuntime.shared.stop()
            WatchSessionNotifier.cancel()
        } else if !isRunning {
            time = snapshot.phaseDuration > 0 ? snapshot.phaseDuration : watchDefaultTimeStart
            selectedTime = time
            lastFocusDuration = time
            mirrorsPhoneSession = false
            awaitingPlayAfterBreak = false
            isBreakTime = false
            WatchTimerRuntime.shared.stop()
            WatchSessionNotifier.cancel()
        }
    }

    // MARK: - Stats

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

struct WatchFeedbackSheet: View {
    @Environment(\.dismiss) private var dismiss

    let currentFocusSeconds: Double
    let onFlow: () -> Void
    let onShorter: () -> Void
    let onBreak: () -> Void

    private var flowNext: Double {
        min(currentFocusSeconds + watchDefaultMinSeconds, watchDefaultMaxSeconds)
    }

    private var shorterNext: Double {
        max(currentFocusSeconds - watchDefaultMinSeconds, watchDefaultMinSeconds)
    }

    private var breakNext: Double {
        let raw = currentFocusSeconds * 0.2
        return min(max(raw, watchBreakMinSeconds), watchBreakMaxSeconds)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("How focused were you?")
                .font(.headline)

            Button(role: .destructive) {
                onBreak()
                dismiss()
            } label: {
                Text("Need a break · \(minutesLabel(breakNext))")
                    .frame(maxWidth: .infinity)
            }

            Button {
                onShorter()
                dismiss()
            } label: {
                Text("A bit much · \(minutesLabel(shorterNext))")
            }
            .tint(.gray)

            Button {
                onFlow()
                dismiss()
            } label: {
                Text("In the flow · \(minutesLabel(flowNext))")
            }
            .tint(.blue)
        }
    }

    private func minutesLabel(_ seconds: Double) -> String {
        "\(max(1, Int((seconds / 60).rounded())))′"
    }
}

#Preview {
    WatchProgressiveTimerView()
        .modelContainer(for: TomaTask.self, inMemory: true)
}

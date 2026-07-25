//
//  WatchProgressiveTimerView.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import WatchKit

struct WatchProgressiveTimerView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var time: TimeInterval = ProgressiveDuration.defaultTimeStart
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var isBreakTime = false
    @State private var selectedTime = ProgressiveDuration.defaultTimeStart
    @State private var lastFocusDuration = ProgressiveDuration.defaultTimeStart
    @State private var showingSheet = false
    @State private var showingStruggleSheet = false
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
            ZStack {
                BrandColors.phaseColor(isBreak: isBreakTime)
                    .ignoresSafeArea()

                VStack(spacing: 6) {
                    Text(statusTitle)
                        .font(.caption2.weight(.semibold))
                        .fontWidth(.condensed)
                        .textCase(.uppercase)
                        .tracking(0.8)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(SharedTimerStore.formatted(time))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.vertical, 4)

                    HStack(spacing: 18) {
                        Button {
                            resetTimer()
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

                        Button {
                            pauseForStruggle()
                        } label: {
                            Image(systemName: "exclamationmark.bubble.fill")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canStruggle)
                        .opacity(canStruggle ? 1 : 0.35)
                        .accessibilityLabel("I'm struggling")
                    }
                }
                .padding(.horizontal, 8)
                .foregroundStyle(.white)
            }
            .navigationTitle("Progressive")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showingSheet) {
                WatchFeedbackSheet(
                    currentFocusSeconds: lastFocusDuration,
                    onFlow: { applyFlow() },
                    onShorter: { applyShorter() },
                    onBreak: { applyBreak() }
                )
            }
            .sheet(isPresented: $showingStruggleSheet) {
                WatchStruggleSheet(
                    onKeepGoing: { applyStruggleKeepGoing() },
                    onShorten: { applyStruggleShorten() },
                    onBreakNow: { applyStruggleBreakNow() }
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
        if isBreakTime { return "Break" }
        let next = ProgressiveDuration.increased(lastFocusDuration)
        if next > lastFocusDuration {
            return "Focus · to \(ProgressiveDuration.minutesLabel(next))"
        }
        return "Focus · \(ProgressiveDuration.minutesLabel(lastFocusDuration))"
    }

    private var canStop: Bool {
        isRunning || time != selectedTime || awaitingPlayAfterBreak || isBreakTime
    }

    private var canStruggle: Bool {
        isRunning && !isBreakTime && !mirrorsPhoneSession
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

    private func pauseForStruggle() {
        guard canStruggle else { return }
        pauseTimer()
        showingStruggleSheet = true
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
        showingStruggleSheet = false
        isBreakTime = false
        time = ProgressiveDuration.defaultTimeStart
        selectedTime = ProgressiveDuration.defaultTimeStart
        lastFocusDuration = ProgressiveDuration.defaultTimeStart
        sessionStats = nil
        SharedTimerSync.publishIdle(phaseDuration: ProgressiveDuration.defaultTimeStart)
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
        let next = ProgressiveDuration.increased(lastFocusDuration)
        lastFocusDuration = next
        selectedTime = next
        time = next
        isBreakTime = false
        showingSheet = false
        startTimer(ownsSession: true)
    }

    private func applyShorter() {
        let next = ProgressiveDuration.decreased(lastFocusDuration)
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
        let breakSeconds = ProgressiveDuration.breakDuration(forFocusSeconds: lastFocusDuration)
        selectedTime = breakSeconds
        time = breakSeconds
        isBreakTime = true
        showingSheet = false
        startTimer(ownsSession: true)
    }

    // MARK: - Struggle

    private func applyStruggleKeepGoing() {
        showingStruggleSheet = false
        startTimer(ownsSession: true)
    }

    private func applyStruggleShorten() {
        time = ProgressiveDuration.shortenedRemaining(time)
        selectedTime = time
        showingStruggleSheet = false
        startTimer(ownsSession: true)
    }

    private func applyStruggleBreakNow() {
        let breakSeconds = ProgressiveDuration.breakDuration(forFocusSeconds: lastFocusDuration)
        selectedTime = breakSeconds
        time = breakSeconds
        isBreakTime = true
        showingStruggleSheet = false
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
            showingStruggleSheet = false
            startTimer(ownsSession: false)
        } else if snapshot.isActive {
            time = snapshot.remainingWhenPaused
            isRunning = false
            mirrorsPhoneSession = true
            awaitingPlayAfterBreak = !snapshot.isBreak && snapshot.remainingWhenPaused > 0
            WatchTimerRuntime.shared.stop()
            WatchSessionNotifier.cancel()
        } else if !isRunning {
            time = snapshot.phaseDuration > 0 ? snapshot.phaseDuration : ProgressiveDuration.defaultTimeStart
            selectedTime = time
            lastFocusDuration = time
            mirrorsPhoneSession = false
            awaitingPlayAfterBreak = false
            isBreakTime = false
            showingStruggleSheet = false
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

    private var flowNext: Double { ProgressiveDuration.increased(currentFocusSeconds) }
    private var shorterNext: Double { ProgressiveDuration.decreased(currentFocusSeconds) }
    private var breakNext: Double { ProgressiveDuration.breakDuration(forFocusSeconds: currentFocusSeconds) }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("How focused were you?")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Button {
                    onBreak()
                    dismiss()
                } label: {
                    Text("Need a break · \(ProgressiveDuration.minutesLabel(breakNext))")
                        .frame(maxWidth: .infinity)
                }
                .tint(BrandColors.breakRed)

                Button {
                    onShorter()
                    dismiss()
                } label: {
                    Text("A bit much · \(ProgressiveDuration.minutesLabel(shorterNext))")
                        .frame(maxWidth: .infinity)
                }
                .tint(.gray)

                Button {
                    onFlow()
                    dismiss()
                } label: {
                    Text("In the flow · \(ProgressiveDuration.minutesLabel(flowNext))")
                        .frame(maxWidth: .infinity)
                }
                .tint(BrandColors.tomatoRed)
            }
            .padding(.top, 4)
        }
    }
}

struct WatchStruggleSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onKeepGoing: () -> Void
    let onShorten: () -> Void
    let onBreakNow: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Take a breath")
                    .font(.headline)

                Text("What would help?")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Button {
                    onKeepGoing()
                    dismiss()
                } label: {
                    Text("Keep going")
                        .frame(maxWidth: .infinity)
                }
                .tint(BrandColors.tomatoRed)

                Button {
                    onShorten()
                    dismiss()
                } label: {
                    Text("Shorten remaining")
                        .frame(maxWidth: .infinity)
                }
                .tint(.gray)

                Button {
                    onBreakNow()
                    dismiss()
                } label: {
                    Text("Break now")
                        .frame(maxWidth: .infinity)
                }
                .tint(BrandColors.breakRed)
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    WatchProgressiveTimerView()
        .modelContainer(for: TomaTask.self, inMemory: true)
}

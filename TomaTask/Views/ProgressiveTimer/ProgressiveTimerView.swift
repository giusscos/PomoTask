//
//  ProgressiveTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 23/10/24.
//

import SwiftUI
import TipKit
import UserNotifications

var defaultTimeStart: Double = 5 * 60
var defaultMinSeconds: Double = 3 * 60
var defaultMaxSeconds: Double = 25 * 60
private let defaultBreakMinSeconds: Double = 3 * 60
private let defaultBreakMaxSeconds: Double = 8 * 60

// MARK: - Duration helpers

enum ProgressiveDuration {
    static func increased(_ seconds: Double) -> Double {
        min(seconds + defaultMinSeconds, defaultMaxSeconds)
    }
    
    static func decreased(_ seconds: Double) -> Double {
        max(seconds - defaultMinSeconds, defaultMinSeconds)
    }
    
    /// ~20% of last focus, clamped to 3–8 minutes.
    static func breakDuration(forFocusSeconds focus: Double) -> Double {
        let raw = focus * 0.2
        return min(max(raw, defaultBreakMinSeconds), defaultBreakMaxSeconds)
    }
    
    /// Cut remaining by ~1/3, floor 1 minute.
    static func shortenedRemaining(_ seconds: Double) -> Double {
        max(seconds * (2.0 / 3.0), 60)
    }
    
    static func minutesLabel(_ seconds: Double) -> String {
        let mins = max(1, Int((seconds / 60).rounded()))
        return "\(mins)′"
    }
}

enum ProgressiveNextAction {
    case none
    case autoStart
}

struct ProgressiveTimerView: View {
    enum ColorMode: String, CaseIterable, Identifiable {
        case solid
        case mesh
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .solid: String(localized: "Solid")
            case .mesh: String(localized: "Gradient")
            }
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @AppStorage(SessionAlertStorage.alarmEnabled) private var alarmEnabled = true
    @AppStorage("preventScreenLock") private var preventScreenLock = true
    
    @State private var showingFocusFeedback = false
    @State private var showingStruggleSheet = false
    @State private var awaitingPlayAfterBreak = false
    @State private var nextAction: ProgressiveNextAction = .none
    
    @State private var selectedTime: Double = defaultTimeStart
    @State private var lastFocusDuration: Double = defaultTimeStart
    @State private var timer: Timer?
    @State var time: TimeInterval = 0
    @State private var isRunning: Bool = false
    @State private var isBreakTime: Bool = false
    
    // Accrue focus seconds locally; flush to SwiftData on session boundaries
    @State private var pendingFocusSeconds: TimeInterval = 0
    @State private var sessionStats: Statistics?

    // Wall-clock anchor — recomputed each tick so Timer drift is impossible.
    @State private var startAnchor: Date?
    @State private var timeAtAnchor: TimeInterval = 0
    @State private var timerSecondsElapsed: Int = 0

    // Background timer state
    @State private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    @State private var backgroundTime: TimeInterval = 0
    @State private var backgroundStartDate: Date?
    
    private let tomatoRed = Color(red: 0.86, green: 0.14, blue: 0.14)
    private let breakRed = Color(red: 0.72, green: 0.22, blue: 0.28)
    private let startTimerTip = StartTimerTip()
    
    private var remainingMinutes: Double {
        time / 60
    }
    
    private var phaseDurationMinutes: Int {
        max(1, Int((selectedTime / 60).rounded()))
    }
    
    private var toolbarSubtitle: String {
        if awaitingPlayAfterBreak {
            return String(localized: "Break over · ready when you are")
        }
        if isBreakTime {
            return String(localized: "Break")
        }
        let next = ProgressiveDuration.increased(lastFocusDuration)
        if next > lastFocusDuration {
            return String(localized: "Focus · building to \(ProgressiveDuration.minutesLabel(next))")
        }
        return String(localized: "Focus · \(ProgressiveDuration.minutesLabel(lastFocusDuration))")
    }
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = verticalSizeClass == .compact
            let stemWidth = min(geo.size.width, geo.size.height)
            
            ZStack(alignment: .top) {
                (isBreakTime ? breakRed : tomatoRed)
                    .ignoresSafeArea()
                
                PomodoroStemView()
                    .frame(width: stemWidth)
                    .offset(y: -stemWidth * 0.32)
                    .allowsHitTesting(false)
                    .ignoresSafeArea(edges: .top)
                    .zIndex(2)
                
                VStack(spacing: 0) {
                    if isLandscape {
                        Spacer(minLength: 0)
                            .frame(maxHeight: 4)
                    } else {
                        Spacer(minLength: 0)
                    }
                    
                    dialSection
                        .padding(.horizontal, 8)
                    
                    Spacer(minLength: isLandscape ? 4 : 8)
                        .frame(maxHeight: isLandscape ? 4 : 20)
                    
                    playPauseButton
                        .popoverTip(startTimerTip, arrowEdge: .bottom)
                    
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .foregroundStyle(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Progressive")
                        .font(.title3.weight(.bold))
                        .fontDesign(.rounded)
                        .lineLimit(1)
                    
                    Text(toolbarSubtitle)
                        .font(.subheadline.weight(.semibold))
                        .fontWidth(.condensed)
                        .opacity(0.75)
                        .textCase(.uppercase)
                        .tracking(1.2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(.white)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                if isRunning && !isBreakTime {
                    struggleButton
                }
                
                Menu {
                    Button {
                        alarmEnabled.toggle()
                        if !alarmEnabled {
                            AlarmPlayer.shared.stop()
                            SessionAlarmScheduler.cancel()
                        }
                    } label: {
                        Label(
                            alarmEnabled ? "Alarm Sound: On" : "Alarm Sound: Off",
                            systemImage: alarmEnabled
                                ? "bell.and.waves.left.and.right.fill"
                                : "bell.slash.fill"
                        )
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.default, value: alarmEnabled)
                    }
                    
                    Button {
                        preventScreenLock.toggle()
                        UIApplication.shared.isIdleTimerDisabled = preventScreenLock
                    } label: {
                        Label(
                            preventScreenLock ? "Screen Always On" : "Screen Auto-Lock",
                            systemImage: preventScreenLock ? "sun.max.fill" : "moon.zzz.fill"
                        )
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.default, value: preventScreenLock)
                    }
                    
                    if time != selectedTime || isRunning || isBreakTime || awaitingPlayAfterBreak {
                        Button(role: .destructive) {
                            resetTimer()
                        } label: {
                            Label("Reset Timer", systemImage: "arrow.counterclockwise")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .sheet(isPresented: $showingFocusFeedback, onDismiss: applyPostFeedbackState) {
            FocusFeedbackSheet(
                currentFocusSeconds: lastFocusDuration,
                onFlow: { handleFlow() },
                onABitMuch: { handleABitMuch() },
                onNeedBreak: { handleNeedBreak() }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingStruggleSheet) {
            StruggleSheet(
                onKeepGoing: { handleStruggleKeepGoing() },
                onShorten: { handleStruggleShorten() },
                onBreakNow: { handleStruggleBreakNow() }
            )
            .presentationDetents([.medium])
        }
        .onAppear {
            time = defaultTimeStart
            selectedTime = defaultTimeStart
            lastFocusDuration = defaultTimeStart
            UIApplication.shared.isIdleTimerDisabled = preventScreenLock
            adoptSharedSessionIfNeeded()
            consumeWidgetPendingPlayIfNeeded()
        }
        .onDisappear {
            resetTimer()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if isRunning {
                startBackgroundTimer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if isRunning {
                stopBackgroundTimer()
                updateTimerFromBackground()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusSessionRemoteToggle)) { _ in
            handleRemoteToggleIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: .watchCompanionSnapshotDidUpdate)) { _ in
            adoptCompanionSnapshotIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: .tomaTaskDeepLink)) { notification in
            guard let path = notification.userInfo?["path"] as? String else { return }
            switch path {
            case "pause":
                guard isRunning else { return }
                isRunning = false
                pauseTimer()
            case "play":
                startFromDeepLink()
            case "start":
                // Tab switch may remount this view; pending flag covers that race.
                WidgetDeepLink.pendingPlay = true
                startFromDeepLink()
            default:
                break
            }
        }
        .statusBarHidden(false)
    }
    
    // MARK: - Dial
    
    private var dialSection: some View {
        PomodoroDialPicker(
            formattedTime: formattedTime(),
            remainingMinutes: remainingMinutes,
            maxMinutes: phaseDurationMinutes,
            isInteractive: false,
            onWind: { _ in }
        )
    }
    
    // MARK: - Play / Pause
    
    private var playPauseButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            awaitingPlayAfterBreak = false
            isRunning.toggle()
            if isRunning {
                startTimer()
            } else {
                pauseTimer()
            }
            startTimerTip.invalidate(reason: .actionPerformed)
        } label: {
            Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: verticalSizeClass == .compact ? 48 : 64))
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRunning ? "Pause" : "Start")
    }

    private func consumeWidgetPendingPlayIfNeeded() {
        guard WidgetDeepLink.consumePendingPlay() else { return }
        // Wait a beat so the tab transition finishes before starting.
        DispatchQueue.main.async {
            startFromDeepLink()
        }
    }

    private func startFromDeepLink() {
        guard !isRunning, !showingFocusFeedback, !showingStruggleSheet else { return }
        awaitingPlayAfterBreak = false
        isRunning = true
        startTimer()
        WidgetDeepLink.pendingPlay = false
    }

    private func toggleFromRemote() {
        if isRunning {
            pauseTimer()
        } else {
            startFromDeepLink()
        }
    }

    private func handleRemoteToggleIfNeeded() {
        let snapshot = SharedTimerStore.load()
        let ownsSession = isRunning || awaitingPlayAfterBreak || isBreakTime
        let progressiveIdle = !snapshot.isActive || snapshot.title == "Progressive" || snapshot.title == "Break"
        guard ownsSession || progressiveIdle else { return }
        FocusSessionRemote.markHandled()
        toggleFromRemote()
    }

    private func adoptSharedSessionIfNeeded() {
        let snapshot = SharedTimerStore.load()
        guard snapshot.isActive else {
            SharedTimerSync.publishIdle(phaseDuration: selectedTime)
            return
        }
        applySnapshot(snapshot, republish: false)
    }

    /// Adopts Watch / App Group Progressive state without echoing back over WatchConnectivity.
    private func adoptCompanionSnapshotIfNeeded() {
        let snapshot = SharedTimerStore.load()
        let progressiveTitles = ["Progressive", "Break"]
        guard !snapshot.isActive || progressiveTitles.contains(snapshot.title) else { return }

        if !snapshot.isActive {
            guard isRunning || awaitingPlayAfterBreak || showingFocusFeedback || time != selectedTime else { return }
            // Companion cleared the session (Watch stop / idle).
            SharedTimerSync.suppressWatchBroadcast = true
            defer { SharedTimerSync.suppressWatchBroadcast = false }
            startAnchor = nil
            flushFocusStats()
            isRunning = false
            timer?.invalidate()
            timer = nil
            LiveActivityManager.endAll()
            SessionAlarmScheduler.cancel()
            isBreakTime = false
            awaitingPlayAfterBreak = false
            showingFocusFeedback = false
            showingStruggleSheet = false
            time = snapshot.phaseDuration > 0 ? snapshot.phaseDuration : defaultTimeStart
            selectedTime = time
            lastFocusDuration = time
            return
        }

        applySnapshot(snapshot, republish: false)
    }

    private func applySnapshot(_ snapshot: SharedTimerStore.Snapshot, republish: Bool) {
        SharedTimerSync.suppressWatchBroadcast = !republish
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
            guard time > 0 else { return }
            isRunning = true
            awaitingPlayAfterBreak = false
            startTimer(fromAdoption: true)
        } else {
            time = snapshot.remainingWhenPaused
            isRunning = false
            awaitingPlayAfterBreak = !snapshot.isBreak && snapshot.remainingWhenPaused > 0
            if time > 0 {
                LiveActivityManager.update(timeRemaining: time, isBreak: isBreakTime, isPaused: true)
            }
        }
    }
    
    private var struggleButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            pauseTimer()
            showingStruggleSheet = true
        } label: {
            Image(systemName: "exclamationmark.bubble")
                .foregroundStyle(.white.opacity(0.9))
        }
        .accessibilityLabel("I'm struggling")
    }
    
    func formattedTime() -> String {
        let displaySeconds = time > 0 ? Int(time.rounded(.up)) : 0
        let minutes = displaySeconds / 60
        let seconds = displaySeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Feedback handlers
    
    private func handleFlow() {
        let next = ProgressiveDuration.increased(lastFocusDuration)
        lastFocusDuration = next
        selectedTime = next
        isBreakTime = false
        nextAction = .autoStart
        showingFocusFeedback = false
    }
    
    private func handleABitMuch() {
        let next = ProgressiveDuration.decreased(lastFocusDuration)
        lastFocusDuration = next
        selectedTime = next
        isBreakTime = false
        nextAction = .none
        showingFocusFeedback = false
    }
    
    private func handleNeedBreak() {
        let breakSeconds = ProgressiveDuration.breakDuration(forFocusSeconds: lastFocusDuration)
        selectedTime = breakSeconds
        isBreakTime = true
        nextAction = .autoStart
        showingFocusFeedback = false
    }
    
    private func applyPostFeedbackState() {
        time = selectedTime
        let shouldAutoStart = nextAction == .autoStart
        nextAction = .none
        if shouldAutoStart {
            isRunning = true
            startTimer()
        }
    }
    
    // MARK: - Struggle handlers
    
    private func handleStruggleKeepGoing() {
        showingStruggleSheet = false
        isRunning = true
        startTimer()
    }
    
    private func handleStruggleShorten() {
        time = ProgressiveDuration.shortenedRemaining(time)
        selectedTime = time
        SessionAlarmScheduler.cancel()
        showingStruggleSheet = false
        isRunning = true
        startTimer()
    }
    
    private func handleStruggleBreakNow() {
        let breakSeconds = ProgressiveDuration.breakDuration(forFocusSeconds: lastFocusDuration)
        selectedTime = breakSeconds
        time = breakSeconds
        isBreakTime = true
        SessionAlarmScheduler.cancel()
        showingStruggleSheet = false
        isRunning = true
        startTimer()
    }
    
    // MARK: - Stats
    
    private func ensureSessionStats() -> Statistics {
        if let sessionStats {
            return sessionStats
        }
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
        SharedStatsSync.publish(using: modelContext)
    }
    
    // MARK: - Timer
    
    func startTimer(fromAdoption: Bool = false) {
        if !fromAdoption {
            let stats = ensureSessionStats()
            stats.timersStarted += 1
            try? modelContext.save()
        }
        
        LiveActivityManager.start(
            taskTitle: isBreakTime ? "Break" : "Progressive Timer",
            timeRemaining: time,
            isBreak: isBreakTime
        )
        SharedTimerSync.publishRunning(
            title: isBreakTime ? "Break" : "Progressive",
            timeRemaining: time,
            phaseDuration: selectedTime,
            isBreak: isBreakTime
        )
        
        Task {
            if SessionAlarmScheduler.hasActiveAlarm {
                SessionAlarmScheduler.resume()
            } else {
                await SessionAlarmScheduler.schedule(
                    duration: time,
                    isBreak: isBreakTime,
                    title: isBreakTime ? "Break complete" : "Focus complete"
                )
            }
        }
        
        // Anchor to wall-clock so drift is zero regardless of run-loop delays.
        startAnchor = Date()
        timeAtAnchor = time
        timerSecondsElapsed = 0

        timer?.invalidate()
        let t = Timer(timeInterval: 0.1, repeats: true) { _ in
            guard let anchor = startAnchor else { return }

            let elapsed = Date().timeIntervalSince(anchor)
            let newTime = max(0, timeAtAnchor - elapsed)

            if !isBreakTime {
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
                pauseTimer()
                Task { @MainActor in
                    SessionCompletionAlert.handleSessionFinished(isBreak: isBreakTime)
                }

                flushFocusStats()
                let stats = ensureSessionStats()
                stats.timersCompleted += 1
                try? modelContext.save()

                handlePhaseCompletion()
            }
        }
        // .common mode keeps ticking while the user interacts with the UI.
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }
    
    private func handlePhaseCompletion() {
        if isBreakTime {
            // Break over: restore last focus duration, wait for play
            isBreakTime = false
            selectedTime = lastFocusDuration
            time = lastFocusDuration
            awaitingPlayAfterBreak = true
            isRunning = false
        } else {
            // Focus complete: ask how it felt
            awaitingPlayAfterBreak = false
            showingFocusFeedback = true
        }
    }
    
    func pauseTimer() {
        startAnchor = nil
        flushFocusStats()
        isRunning = false
        timer?.invalidate()
        
        if time > 0 {
            SessionAlarmScheduler.pause()
            LiveActivityManager.update(timeRemaining: time, isBreak: isBreakTime, isPaused: true)
            SharedTimerSync.publishPaused(
                title: isBreakTime ? "Break" : "Progressive",
                timeRemaining: time,
                phaseDuration: selectedTime,
                isBreak: isBreakTime
            )
        } else {
            LiveActivityManager.endAll()
            SharedTimerSync.publishIdle(phaseDuration: selectedTime)
        }
    }
    
    func resetTimer() {
        startAnchor = nil
        flushFocusStats()
        AlarmPlayer.shared.stop()
        SessionAlarmScheduler.cancel()
        isRunning = false
        timer?.invalidate()
        LiveActivityManager.endAll()
        SharedTimerSync.publishIdle(phaseDuration: defaultTimeStart)
        
        isBreakTime = false
        awaitingPlayAfterBreak = false
        showingFocusFeedback = false
        showingStruggleSheet = false
        nextAction = .none
        time = defaultTimeStart
        selectedTime = defaultTimeStart
        lastFocusDuration = defaultTimeStart
        sessionStats = nil
    }
    
    private func startBackgroundTimer() {
        backgroundStartDate = Date()
        backgroundTime = time
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [self] in
            endBackgroundTask()
        }
        
        SessionCompletionAlert.scheduleBackgroundNotification(after: time, isBreak: isBreakTime)
    }
    
    private func stopBackgroundTimer() {
        endBackgroundTask()
        SessionCompletionAlert.cancelPending()
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func updateTimerFromBackground() {
        guard let startDate = backgroundStartDate else { return }
        
        let elapsedTime = Date().timeIntervalSince(startDate)
        if !isBreakTime {
            pendingFocusSeconds += min(elapsedTime, backgroundTime)
        }
        time = max(0, backgroundTime - elapsedTime)
        backgroundStartDate = nil
        // Re-anchor so the foreground timer resumes from the correct position.
        startAnchor = Date()
        timeAtAnchor = time
        timerSecondsElapsed = 0

        if time == 0 {
            handleTimerCompletion()
        } else {
            LiveActivityManager.update(timeRemaining: time, isBreak: isBreakTime, isPaused: false)
            SharedTimerSync.publishRunning(
                title: isBreakTime ? "Break" : "Progressive",
                timeRemaining: time,
                phaseDuration: selectedTime,
                isBreak: isBreakTime
            )
        }
    }
    
    private func handleTimerCompletion() {
        Task { @MainActor in
            SessionCompletionAlert.handleSessionFinished(isBreak: isBreakTime)
        }

        flushFocusStats()
        let stats = ensureSessionStats()
        stats.timersCompleted += 1
        try? modelContext.save()

        LiveActivityManager.endAll()
        isRunning = false
        timer?.invalidate()
        handlePhaseCompletion()
    }
}

// MARK: - Focus feedback

struct FocusFeedbackSheet: View {
    let currentFocusSeconds: Double
    let onFlow: () -> Void
    let onABitMuch: () -> Void
    let onNeedBreak: () -> Void
    
    private var flowNext: Double { ProgressiveDuration.increased(currentFocusSeconds) }
    private var shorterNext: Double { ProgressiveDuration.decreased(currentFocusSeconds) }
    private var breakNext: Double { ProgressiveDuration.breakDuration(forFocusSeconds: currentFocusSeconds) }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("How focused did you feel?")
                .font(.title2.weight(.semibold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                feedbackButton(
                    title: "In the flow",
                    subtitle: String(localized: "\(ProgressiveDuration.minutesLabel(currentFocusSeconds)) → \(ProgressiveDuration.minutesLabel(flowNext)) · starts next"),
                    background: Color.accentColor,
                    action: onFlow
                )
                
                feedbackButton(
                    title: "A bit much",
                    subtitle: String(localized: "\(ProgressiveDuration.minutesLabel(currentFocusSeconds)) → \(ProgressiveDuration.minutesLabel(shorterNext)) · tap play when ready"),
                    background: Color.gray,
                    action: onABitMuch
                )
                
                feedbackButton(
                    title: "Need a break",
                    subtitle: String(localized: "\(ProgressiveDuration.minutesLabel(breakNext)) break · starts next"),
                    background: Color.red,
                    action: onNeedBreak
                )
            }
            .frame(maxWidth: 500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    private func feedbackButton(
        title: String,
        subtitle: String,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .opacity(0.9)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(background)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Struggle

struct StruggleSheet: View {
    let onKeepGoing: () -> Void
    let onShorten: () -> Void
    let onBreakNow: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Take a breath")
                .font(.title2.weight(.semibold))
                .fontDesign(.rounded)
            
            Text("You're paused. What would help?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                struggleButton(
                    title: "Keep going",
                    subtitle: "Resume this focus block",
                    background: Color.accentColor,
                    action: onKeepGoing
                )
                
                struggleButton(
                    title: "Shorten remaining",
                    subtitle: "Cut about a third, then resume",
                    background: Color.gray,
                    action: onShorten
                )
                
                struggleButton(
                    title: "Break now",
                    subtitle: "Start a short break",
                    background: Color.red,
                    action: onBreakNow
                )
            }
            .frame(maxWidth: 500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    private func struggleButton(
        title: String,
        subtitle: String,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .opacity(0.9)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(background)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TabView {
        Tab("Progressive", systemImage: "dial.medium") {
            NavigationStack {
                ProgressiveTimerView()
            }
        }
        
        Tab("Classic", systemImage: "timer") {
            NavigationStack {
                TaskView(task: TomaTask(title: "Deep Work", maxDuration: 25, pauseDuration: 5, repetition: 4))
            }
        }
    }
    .environment(Store())
    .task { try? Tips.configure([.displayFrequency(.immediate)]) }
}

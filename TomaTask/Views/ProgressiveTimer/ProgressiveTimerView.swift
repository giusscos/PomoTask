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

struct ProgressiveTimerView: View {
    enum ColorMode: String, CaseIterable, Identifiable {
        case solid = "Solid"
        case mesh = "Gradient"
        var id: String { self.rawValue }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @AppStorage(SessionAlertStorage.alarmEnabled) private var alarmEnabled = true
    @AppStorage("preventScreenLock") private var preventScreenLock = true
    
    @State private var showingSheet: Bool = false
    
    @State private var selectedTime: Double = defaultTimeStart
    @State private var timer: Timer?
    @State var time: TimeInterval = 0
    @State private var isRunning: Bool = false
    @State private var isBreakTime: Bool = false
    
    // Accrue focus seconds locally; flush to SwiftData on session boundaries
    @State private var pendingFocusSeconds: TimeInterval = 0
    @State private var sessionStats: Statistics?
    
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
                    
                    Text(isBreakTime ? "Break" : "Focus")
                        .font(.subheadline.weight(.semibold))
                        .fontWidth(.condensed)
                        .opacity(0.75)
                        .textCase(.uppercase)
                        .tracking(1.2)
                }
                .foregroundStyle(.white)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
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
                    
                    if time != selectedTime || isRunning || isBreakTime {
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
        .sheet(isPresented: $showingSheet, onDismiss: {
            time = selectedTime
        }) {
            FeedbackSheet(selectedTime: $selectedTime, breakTime: $isBreakTime)
        }
        .onAppear {
            time = defaultTimeStart
            UIApplication.shared.isIdleTimerDisabled = preventScreenLock
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
        .onReceive(NotificationCenter.default.publisher(for: .tomaTaskDeepLink)) { notification in
            guard let path = notification.userInfo?["path"] as? String, path == "pause", isRunning else { return }
            isRunning = false
            pauseTimer()
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
    
    func formattedTime() -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
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
    }
    
    func startTimer() {
        let stats = ensureSessionStats()
        stats.timersStarted += 1
        try? modelContext.save()
        
        LiveActivityManager.start(
            taskTitle: isBreakTime ? "Break" : "Progressive Timer",
            timeRemaining: time,
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
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if time > 0 {
                isRunning = true
                
                time -= 1
                pendingFocusSeconds += 1
            } else {
                pauseTimer()
                Task { @MainActor in
                    SessionCompletionAlert.handleSessionFinished(isBreak: isBreakTime)
                }
                
                flushFocusStats()
                let stats = ensureSessionStats()
                stats.timersCompleted += 1
                try? modelContext.save()
                
                showingSheet = true
            }
        }
    }
    
    func pauseTimer() {
        flushFocusStats()
        isRunning = false
        timer?.invalidate()
        
        if time > 0 {
            SessionAlarmScheduler.pause()
            LiveActivityManager.update(timeRemaining: time, isBreak: isBreakTime, isPaused: true)
        } else {
            LiveActivityManager.endAll()
        }
    }
    
    func resetTimer() {
        flushFocusStats()
        AlarmPlayer.shared.stop()
        SessionAlarmScheduler.cancel()
        isRunning = false
        timer?.invalidate()
        LiveActivityManager.endAll()
        
        isBreakTime = false
        time = defaultTimeStart
        selectedTime = defaultTimeStart
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
        pendingFocusSeconds += min(elapsedTime, backgroundTime)
        time = max(0, backgroundTime - elapsedTime)
        backgroundStartDate = nil
        
        if time == 0 {
            handleTimerCompletion()
        } else {
            LiveActivityManager.update(timeRemaining: time, isBreak: isBreakTime, isPaused: false)
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
        showingSheet = true
        isRunning = false
        timer?.invalidate()
    }
}

struct FeedbackSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedTime: Double
    @Binding var breakTime: Bool
    
    var body: some View {
        VStack {
            Text("How do you feel?")
                .font(.title)
                .fontWeight(.semibold)
            
            VStack {
                Button {
                    takeABreak()
                } label: {
                    Text("I need a break")
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                Button {
                    useTheSameTime()
                } label: {
                    Text("I need less time")
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                Button {
                    increaseTime()
                } label: {
                    Text("I'm in the flow")
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: 500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    func takeABreak() {
        selectedTime = 5 * 60
        setBreak()
    }
    
    func setNoBreak() {
        breakTime = false
        dismiss()
    }
    
    func setBreak() {
        breakTime = true
        dismiss()
    }
    
    func useTheSameTime() {
        selectedTime = selectedTime - defaultMinSeconds <= defaultMinSeconds ? defaultMinSeconds : selectedTime - defaultMinSeconds
        setNoBreak()
    }
    
    func increaseTime() {
        selectedTime = selectedTime + defaultMinSeconds <= defaultMaxSeconds ? selectedTime + defaultMinSeconds : defaultMaxSeconds
        setNoBreak()
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

//
//  SessionTimerEngine.swift
//  TomaTask
//

import SwiftUI
import SwiftData
import UIKit

@Observable
@MainActor
final class SessionTimerEngine {
    var time: TimeInterval = 0
    var isRunning = false
    var isBreak = false
    var repetition = 0
    /// 1 → 0 as the current phase elapses.
    var progress: Double = 1
    /// Solid-timer fill height (drains on focus, fills on break).
    var fillHeight: CGFloat = screenSize
    var isComplete = false
    
    private var timer: Timer?
    private var pendingFocusSeconds: TimeInterval = 0
    private var sessionStats: Statistics?
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var backgroundTime: TimeInterval = 0
    private var backgroundStartDate: Date?
    
    private var taskTitle: String = ""
    private var maxDuration: TimeInterval = 25 * 60
    private var pauseDuration: TimeInterval = 5 * 60
    private var targetRepetitions: Int = 4
    private var useSolidFill = true
    
    private weak var modelContext: ModelContext?
    
    var formattedTime: String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var phaseTotal: TimeInterval {
        isBreak ? pauseDuration : maxDuration
    }
    
    var displayTitle: String {
        taskTitle.isEmpty ? "Classic Timer" : taskTitle
    }
    
    func configure(
        task: TomaTask,
        modelContext: ModelContext,
        useSolidFill: Bool
    ) {
        self.modelContext = modelContext
        self.taskTitle = task.title
        self.maxDuration = Double(task.maxDuration * 60)
        self.pauseDuration = Double(task.pauseDuration * 60)
        self.targetRepetitions = task.repetition
        self.useSolidFill = useSolidFill
        
        if time == 0 && !isRunning && repetition == 0 && !isBreak {
            time = maxDuration
            progress = 1
            fillHeight = screenSize
        }
    }
    
    func updateSolidFillPreference(_ useSolid: Bool) {
        useSolidFill = useSolid
    }
    
    // MARK: - Controls
    
    func togglePlayPause() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }
    
    func start() {
        if isComplete {
            repetition = 0
            isBreak = false
            isComplete = false
            time = maxDuration
            progress = 1
            fillHeight = screenSize
        }
        
        guard let modelContext else { return }
        
        let stats = ensureSessionStats(modelContext)
        stats.timersStarted += 1
        try? modelContext.save()
        
        LiveActivityManager.start(
            taskTitle: displayTitle,
            timeRemaining: time,
            isBreak: isBreak
        )
        
        let alarmTitle = taskTitle.isEmpty
            ? (isBreak ? "Break complete" : "Focus complete")
            : taskTitle
        
        Task {
            if SessionAlarmScheduler.hasActiveAlarm {
                SessionAlarmScheduler.resume()
            } else {
                await SessionAlarmScheduler.schedule(
                    duration: time,
                    isBreak: isBreak,
                    title: alarmTitle
                )
            }
        }
        
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    func pause() {
        flushFocusStats()
        isRunning = false
        timer?.invalidate()
        timer = nil
        SessionAlarmScheduler.pause()
        LiveActivityManager.update(timeRemaining: time, isBreak: isBreak, isPaused: true)
    }
    
    func stop() {
        flushFocusStats()
        AlarmPlayer.shared.stop()
        SessionAlarmScheduler.cancel()
        LiveActivityManager.endAll()
        
        isRunning = false
        isBreak = false
        isComplete = false
        repetition = 0
        timer?.invalidate()
        timer = nil
        time = maxDuration
        progress = 1
        fillHeight = screenSize
        sessionStats = nil
        pendingFocusSeconds = 0
    }
    
    /// Winding the dial: sets remaining time. Dragging back to full phase duration resets the session.
    func windDial(toMinutes minutes: Int) {
        guard !isRunning else { return }
        
        let capped = max(0, min(minutes, Int(phaseTotal / 60)))
        let fullMinutes = Int(phaseTotal / 60)
        
        // Dragged fully back → reset whole session (like rewinding a physical pomodoro).
        if capped >= fullMinutes {
            stop()
            return
        }
        
        isComplete = false
        time = TimeInterval(capped * 60)
        updateProgressVisuals()
        SessionAlarmScheduler.cancel()
        LiveActivityManager.endAll()
    }
    
    /// Fractional minutes remaining — drives smooth dial “rotation”.
    var remainingMinutes: Double {
        time / 60.0
    }
    
    var phaseDurationMinutes: Int {
        max(1, Int(phaseTotal / 60))
    }
    
    // MARK: - Lifecycle
    
    func handleResignActive() {
        guard isRunning else { return }
        backgroundStartDate = Date()
        backgroundTime = time
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        SessionCompletionAlert.scheduleBackgroundNotification(after: time, isBreak: isBreak)
    }
    
    func handleBecomeActive() {
        guard isRunning else { return }
        endBackgroundTask()
        SessionCompletionAlert.cancelPending()
        applyBackgroundElapsed()
    }
    
    func handleDeepLinkPause() {
        guard isRunning else { return }
        pause()
    }
    
    func tearDown() {
        flushFocusStats()
        isRunning = false
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
        SessionAlarmScheduler.cancel()
        LiveActivityManager.endAll()
    }
    
    // MARK: - Private
    
    private func tick() {
        guard time > 0 else {
            completePhase()
            return
        }
        
        time -= 1
        if !isBreak {
            pendingFocusSeconds += 1
        }
        updateProgressVisuals()
    }
    
    private func completePhase() {
        let finishedBreak = isBreak
        isBreak.toggle()
        
        if isBreak {
            repetition += 1
            if repetition >= targetRepetitions {
                flushFocusStats()
                if let modelContext {
                    let stats = ensureSessionStats(modelContext)
                    stats.timersCompleted += 1
                    try? modelContext.save()
                }
                isComplete = true
                isBreak = false
            }
        }
        
        finishPhaseTransition(finishedBreak: finishedBreak)
    }
    
    private func finishPhaseTransition(finishedBreak: Bool) {
        flushFocusStats()
        
        Task { @MainActor in
            SessionCompletionAlert.handleSessionFinished(isBreak: finishedBreak)
        }
        
        isRunning = false
        timer?.invalidate()
        timer = nil
        LiveActivityManager.endAll()
        
        if isComplete {
            time = maxDuration
            progress = 1
            fillHeight = screenSize
        } else {
            time = isBreak ? pauseDuration : maxDuration
            progress = 1
            fillHeight = isBreak ? 0 : screenSize
        }
    }
    
    private func updateProgressVisuals() {
        let total = max(phaseTotal, 1)
        progress = max(0, min(1, time / total))
        
        guard useSolidFill else { return }
        
        if isBreak {
            fillHeight = screenSize * (1 - progress)
        } else {
            fillHeight = screenSize * progress
        }
    }
    
    private func applyBackgroundElapsed() {
        guard let startDate = backgroundStartDate else { return }
        
        let elapsed = Date().timeIntervalSince(startDate)
        if !isBreak {
            pendingFocusSeconds += min(elapsed, backgroundTime)
        }
        time = max(0, backgroundTime - elapsed)
        backgroundStartDate = nil
        updateProgressVisuals()
        
        if time == 0 {
            completePhase()
        } else {
            LiveActivityManager.update(timeRemaining: time, isBreak: isBreak, isPaused: false)
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func ensureSessionStats(_ context: ModelContext) -> Statistics {
        if let sessionStats { return sessionStats }
        let stats = Statistics.getDailyStats(from: Date(), context: context)
        sessionStats = stats
        return stats
    }
    
    private func flushFocusStats() {
        guard pendingFocusSeconds > 0, let modelContext else { return }
        let stats = ensureSessionStats(modelContext)
        stats.totalFocusTime += pendingFocusSeconds
        pendingFocusSeconds = 0
        try? modelContext.save()
    }
}

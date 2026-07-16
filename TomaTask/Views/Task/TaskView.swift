//
//  TaskView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI
import UserNotifications

enum TaskSheet: Identifiable {
    case tasks
    case colorCustomization
    
    var id: Int {
        switch self {
        case .tasks: return 1
        case .colorCustomization: return 2
        }
    }
}

struct TaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(Store.self) private var store
    
    @State var task: TomaTask
    
    @State var hideUI: Bool = false

    @State private var activeSheet: TaskSheet?

    // AppStorage for colors using hex strings
    @AppStorage("meshColor1Hex") private var meshColor1Hex: String = "#000000" // Black
    @AppStorage("meshColor2Hex") private var meshColor2Hex: String = "#FFA500" // Orange
    @AppStorage("meshColor3Hex") private var meshColor3Hex: String = "#FF0000" // Red
    @AppStorage("colorMode") private var storedColorMode: String = "solid"
    @AppStorage(SessionAlertStorage.alarmEnabled) private var alarmEnabled = true
    
    // Derived state from AppStorage
    @State var meshColor1: Color = .black
    @State var meshColor2: Color = .orange
    @State var meshColor3: Color = .red
    @State private var colorMode: ProgressiveTimerView.ColorMode = .solid
    
    @State var heigth: CGFloat = screenSize
    
    @State private var timer: Timer?
    @State var time: TimeInterval = 0
    
    @State private var isRunning: Bool = false
    @State private var pauseTime: Bool = false
    @State private var repetition: Int = 0
    @State private var initialTime: TimeInterval = 0
    
    // Accrue focus seconds locally; flush to SwiftData on session boundaries
    @State private var pendingFocusSeconds: TimeInterval = 0
    @State private var sessionStats: Statistics?
    
    // Background timer state
    @State private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    @State private var backgroundTime: TimeInterval = 0
    @State private var backgroundStartDate: Date?
    
    var maxDuration : TimeInterval {
        Double(task.maxDuration * 60)
    }
    
    var pauseDuration : TimeInterval {
        Double(task.pauseDuration * 60)
    }
    
    var isSubscribed: Bool {
        !store.purchasedSubscriptions.isEmpty
    }
    
    var body: some View {
        VStack {
            ZStack {
                Group {
                    if colorMode == .solid || !isSubscribed {
                        SolidTimer(heigth: heigth, color: meshColor1)
                    } else {
                        MeshGradientTimer(
                            time: time,
                            meshColor1: meshColor1,
                            meshColor2: meshColor2,
                            meshColor3: meshColor3
                        )
                    }
                }
                .onTapGesture {
                    withAnimation {
                        hideUI.toggle()
                    }
                }
                
                VStack {
                    if task.repetition != repetition {
                        HStack (alignment: .bottom) {
                            Text(pauseTime ? "Pause time" : "Work time")
                                .font(.headline)
                            
                            Text("\(repetition)/\(task.repetition)")
                                .font(.caption)
                        }
                    }
                    
                    if task.repetition != repetition {
                        Text(formattedTime())
                            .font(.largeTitle)
                            .bold()
                    } else {
                        Text("Congratulations! You completed the TomoTask!")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .bold()
                    }
                    
                    HStack {
                        if isRunning || pauseTime || time < maxDuration {
                            Button {
                                restartTimer()
                            } label: {
                                Label("Stop", systemImage: "stop.fill")
                                    .font(.title)
                                    .labelStyle(.iconOnly)
                            }
                        }
                        
                        Button {
                            isRunning.toggle()
                            
                            isRunning ? startTimer() : stopTimer()
                        } label: {
                            Label(!isRunning ? "Start" : "Paus", systemImage: isRunning ? "pause.fill" : "play.fill")
                                .font(.title)
                                .labelStyle(.iconOnly)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                }
                .foregroundStyle(.primary)
                .hideUIAnimation(hideUI: hideUI)
                
                if(!task.unwrappedTasks.isEmpty) {
                    Button {
                        withAnimation {
                            activeSheet = .tasks
                        }
                    } label: {
                        Label("Tasks", systemImage: "checklist")
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius: 10, x: 0, y: 4)
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .onAppear(){
            time = maxDuration
            loadSavedColors()
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear() {
            stopTimer()
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
            stopTimer()
        }
        .background(TabBarHidingBridge())
        .toolbar(hideUI ? .hidden : .visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    Button {
                        alarmEnabled.toggle()
                        if !alarmEnabled {
                            AlarmPlayer.shared.stop()
                            SessionAlarmScheduler.cancel()
                        }
                    } label: {
                        Label("Toggle alarm", systemImage: alarmEnabled ? "bell.and.waves.left.and.right.fill" : "bell.slash.fill")
                            .labelStyle(.iconOnly)
                            .contentTransition(.symbolEffect(.replace))
                    }

                    Button {
                        activeSheet = .colorCustomization
                    } label: {
                        Label("Customize Colors", systemImage: "paintpalette.fill")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .tasks:
                SubTaskList(tasks: task.tasks ?? [])
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(32)
                    .presentationBackground(.regularMaterial)
            case .colorCustomization:
                ColorCustomizationView(
                    meshColor1: $meshColor1,
                    meshColor2: $meshColor2,
                    meshColor3: $meshColor3,
                    colorMode: $colorMode,
                    isSubscribed: isSubscribed,
                    onColorChange: saveColors
                )
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
                .presentationCornerRadius(32)
                .presentationBackground(.thinMaterial)
            }
        }
    }
    
    // Load saved colors from AppStorage
    private func loadSavedColors() {
        meshColor1 = Color.fromHexString(meshColor1Hex)
        meshColor2 = Color.fromHexString(meshColor2Hex)
        meshColor3 = Color.fromHexString(meshColor3Hex)
        colorMode = storedColorMode == "mesh" ? .mesh : .solid
    }
    
    // Save colors to AppStorage
    private func saveColors() {
        meshColor1Hex = meshColor1.toHexString()
        meshColor2Hex = meshColor2.toHexString()
        meshColor3Hex = meshColor3.toHexString()
        storedColorMode = colorMode == .mesh ? "mesh" : "solid"
    }
    
    func formattedTime () -> String {
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
        if task.repetition == repetition {
            repetition = 0
            time = maxDuration
            heigth = screenSize
        }
        
        initialTime = time
        let stats = ensureSessionStats()
        stats.timersStarted += 1
        try? modelContext.save()
        
        LiveActivityManager.start(
            taskTitle: task.title.isEmpty ? "Classic Timer" : task.title,
            timeRemaining: time,
            isBreak: pauseTime
        )
        
        Task {
            if SessionAlarmScheduler.hasActiveAlarm {
                SessionAlarmScheduler.resume()
            } else {
                await SessionAlarmScheduler.schedule(
                    duration: time,
                    isBreak: pauseTime,
                    title: task.title.isEmpty ? (pauseTime ? "Break complete" : "Focus complete") : task.title
                )
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if(time > 0) {
                isRunning = true
                
                time -= 1
                pendingFocusSeconds += 1
                
                if(pauseTime && colorMode == .solid) {
                    heigth += screenSize / CGFloat(maxDuration / 1)
                } else if (!pauseTime && colorMode == .solid) {
                    heigth -= screenSize / CGFloat(maxDuration / 1)
                }
            } else {
                pauseTime.toggle()
                
                if pauseTime {
                    repetition += 1
                    
                    if task.repetition == repetition {
                        flushFocusStats()
                        let stats = ensureSessionStats()
                        stats.timersCompleted += 1
                        try? modelContext.save()
                    }
                }
                
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        flushFocusStats()
        
        let didComplete = time == 0
        // Timer loop toggles pauseTime before calling stopTimer, so the finished
        // phase is the opposite of the upcoming phase stored in pauseTime.
        let finishedBreak = !pauseTime
        
        if task.repetition == repetition {
            pauseTime = false
        }
        
        if didComplete {
            Task { @MainActor in
                SessionCompletionAlert.handleSessionFinished(isBreak: finishedBreak)
            }
        }
        
        isRunning = false
        
        timer?.invalidate()
        
        if didComplete {
            LiveActivityManager.endAll()
            time = pauseTime ? pauseDuration : maxDuration
        } else {
            SessionAlarmScheduler.pause()
            LiveActivityManager.update(timeRemaining: time, isBreak: pauseTime, isPaused: true)
        }
    }
    
    func restartTimer() {
        flushFocusStats()
        AlarmPlayer.shared.stop()
        SessionAlarmScheduler.cancel()
        LiveActivityManager.endAll()
        
        isRunning = false
        
        repetition = 0
        
        timer?.invalidate()
        
        time = maxDuration
        heigth = screenSize
        sessionStats = nil
    }
    
    private func startBackgroundTimer() {
        backgroundStartDate = Date()
        backgroundTime = time
        
        // Start background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [self] in
            endBackgroundTask()
        }
        
        SessionCompletionAlert.scheduleBackgroundNotification(after: time, isBreak: pauseTime)
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
            LiveActivityManager.update(timeRemaining: time, isBreak: pauseTime, isPaused: false)
        }
    }
    
    private func handleTimerCompletion() {
        pauseTime.toggle()
        
        if pauseTime {
            repetition += 1
            
            if task.repetition == repetition {
                flushFocusStats()
                let stats = ensureSessionStats()
                stats.timersCompleted += 1
                try? modelContext.save()
            }
        }
        
        stopTimer()
    }
}

// Tells UINavigationController to animate the tab bar out/in with push/pop
private struct TabBarHidingBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TabBarHidingController { TabBarHidingController() }
    func updateUIViewController(_ vc: TabBarHidingController, context: Context) {}
}

private final class TabBarHidingController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        parent?.hidesBottomBarWhenPushed = true
    }
}

#Preview {
    TaskView(task: TomaTask())
        .environment(Store())
}

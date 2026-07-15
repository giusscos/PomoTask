//
//  ProgressiveTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 23/10/24.
//

import SwiftUI
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
    @Environment(Store.self) private var store
    
    @State var hideUI: Bool = false
    @State var dimDisplay: Bool = false
    @State private var showingColorCustomization: Bool = false
    
    @State private var showingSheet: Bool = false
    
    @State private var meshValue1 = Float.random(in: 0.5...0.7)
    @State private var meshValue2 = Float.random(in: 0.4...0.8)
    
    // AppStorage for colors using hex strings
    @AppStorage("meshColor1Hex") private var meshColor1Hex: String = "#000000" // Black
    @AppStorage("meshColor2Hex") private var meshColor2Hex: String = "#FFA500" // Orange
    @AppStorage("meshColor3Hex") private var meshColor3Hex: String = "#FF0000" // Red
    @AppStorage("colorMode") private var storedColorMode: String = "solid"
    
    // Derived state from AppStorage
    @State var meshColor1: Color = .black
    @State var meshColor2: Color = .orange
    @State var meshColor3: Color = .red
    @State private var colorMode: ColorMode = .solid
        
    @State var heigth: CGFloat = screenSize
    
    @State private var selectedTime: Double = defaultTimeStart
    @State private var timer: Timer?
    @State var time: TimeInterval = 0
    @State private var isRunning: Bool = false
    @State private var isBreakTime: Bool = false
    @State private var initialTime: TimeInterval = 0
    
    // Accrue focus seconds locally; flush to SwiftData on session boundaries
    @State private var pendingFocusSeconds: TimeInterval = 0
    @State private var sessionStats: Statistics?
    
    // Background timer state
    @State private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    @State private var backgroundTime: TimeInterval = 0
    @State private var backgroundStartDate: Date?
    
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
                
                TimerActions(dimDisplay: $dimDisplay, showingColorCustomization: $showingColorCustomization, backButton: false)
                    .hideUIAnimation(hideUI: hideUI)
                
                VStack (spacing: 8) {
                    Text(!isBreakTime ? "Focus time" : "Break time")
                        .font(.headline)
                    
                    Text(formattedTime())
                        .font(.system(size: 48, weight: .bold))
                    
                    HStack {
                        Button {
                            resetTimer()
                        } label: {
                            Label("Stop", systemImage: "stop.fill")
                                .font(.title)
                                .labelStyle(.iconOnly)
                                .contentTransition(.symbolEffect(.replace))
                                .opacity(time == selectedTime ? 0.3 : 1)
                        }.disabled(time == selectedTime)
                        
                        Button {
                            isRunning.toggle()
                            
                            isRunning ? startTimer() : pauseTimer()
                        } label: {
                            Label(!isRunning ? "Start" : "Pause", systemImage: isRunning ? "pause.fill" : "play.fill")
                                .font(.title)
                                .contentTransition(.symbolEffect(.replace))
                                .labelStyle(.iconOnly)
                        }
                    }.foregroundStyle(.primary)
                }
                .hideUIAnimation(hideUI: hideUI)
            }
        }
        .toolbar(hideUI ? .hidden : .visible, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingSheet, onDismiss: {
            time = selectedTime
            
            if !isBreakTime && colorMode == .solid {
                heigth = screenSize
            }
        }) {
            FeedbackSheet(selectedTime: $selectedTime, breakTime: $isBreakTime)
        }
        .sheet(isPresented: $showingColorCustomization) {
            ColorCustomizationView(
                meshColor1: $meshColor1,
                meshColor2: $meshColor2,
                meshColor3: $meshColor3,
                colorMode: $colorMode,
                isSubscribed: isSubscribed,
                onColorChange: saveColors
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([UIDevice.current.userInterfaceIdiom == .pad ? .large : .medium])
            .presentationCornerRadius(32)
            .presentationBackground(.thinMaterial)
        }
        .onAppear(){
            time = defaultTimeStart
            
            if colorMode == .solid {
                heigth = screenSize
            }
            
            // Load saved colors when the view appears
            loadSavedColors()
        }
        .onDisappear() {
            resetTimer()
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
    
    func handleMeshAnimation() {
        meshValue1 = cos(.random(in: 0.0...1.0)) > 0 ? Float.random(in: 0.5...0.7) : Float.random(in: 0.4...0.8)
        meshValue2 = cos(.random(in: 0.0...1.0)) < 0 ? Float.random(in: 0.4...0.6) : Float.random(in: 0.5...0.7)
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
        initialTime = time
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
            if colorMode == .mesh {
                handleMeshAnimation()
            }
            
            
            if(time > 0) {
                isRunning = true
                
                time -= 1
                pendingFocusSeconds += 1
                
                if(isBreakTime && colorMode == .solid) {
                    heigth += screenSize / CGFloat(selectedTime / 1)
                } else if (!isBreakTime && colorMode == .solid) {
                    heigth -= screenSize / CGFloat(selectedTime / 1)
                }
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
        hideUI = false
        
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
        hideUI = false
        LiveActivityManager.endAll()
        
        isBreakTime = false
        time = defaultTimeStart
        selectedTime = defaultTimeStart
        sessionStats = nil
        
        if colorMode == .solid {
            heigth = screenSize
        }
    }
    
    private func startBackgroundTimer() {
        backgroundStartDate = Date()
        backgroundTime = time
        
        // Start background task
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

struct HideUIAnimationModifier: ViewModifier {
    var hideUI: Bool
    
    func body(content: Content) -> some View {
        content
            .blur(radius: hideUI ? 10 : 0)
            .opacity(hideUI ? 0 : 1)
            .scaleEffect(hideUI ? 2 : 1)
            .animation(.spring(), value: hideUI)
    }
}

extension View {
    func hideUIAnimation(hideUI: Bool) -> some View {
        self.modifier(HideUIAnimationModifier(hideUI: hideUI))
    }
}

#Preview {
    ProgressiveTimerView()
        .environment(Store())
}

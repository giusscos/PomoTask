//
//  ProgressiveTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 23/10/24.
//

import SwiftUI
import AudioToolbox
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
    
    @State var store = Store()
    
    @State var hideUI: Bool = false
    @State var alarmSound: Bool = true
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
                
                TimerActions(alarmSound: $alarmSound, dimDisplay: $dimDisplay, showingColorCustomization: $showingColorCustomization, backButton: false)
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
            .presentationDetents([.medium])
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
    }
    
    // Load saved colors from AppStorage
    private func loadSavedColors() {
        meshColor1 = hexStringToColor(meshColor1Hex)
        meshColor2 = hexStringToColor(meshColor2Hex)
        meshColor3 = hexStringToColor(meshColor3Hex)
        colorMode = storedColorMode == "mesh" ? .mesh : .solid
    }
    
    // Save colors to AppStorage
    private func saveColors() {
        meshColor1Hex = colorToHexString(meshColor1)
        meshColor2Hex = colorToHexString(meshColor2)
        meshColor3Hex = colorToHexString(meshColor3)
        storedColorMode = colorMode == .mesh ? "mesh" : "solid"
    }
    
    // Convert Color to Hex String
    private func colorToHexString(_ color: Color) -> String {
        let uiColor = UIColor(color)
        let components = uiColor.cgColor.components ?? [0, 0, 0, 0]
        let r: CGFloat = components[0]
        let g: CGFloat = components[1]
        let b: CGFloat = components[2]
        
        let hexString = String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        return hexString
    }
    
    // Convert Hex String to Color
    private func hexStringToColor(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        return Color(red: r, green: g, blue: b)
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
    
    func startTimer() {
        initialTime = time
        let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
        stats.timersStarted += 1
        try? modelContext.save()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if colorMode == .mesh {
                handleMeshAnimation()
            }
            
            
            if(time > 0) {
                isRunning = true
                
                time -= 1
                
                stats.totalFocusTime += 1
                
                if(isBreakTime && colorMode == .solid) {
                    heigth += screenSize / CGFloat(selectedTime / 1)
                } else if (!isBreakTime && colorMode == .solid) {
                    heigth -= screenSize / CGFloat(selectedTime / 1)
                }
            } else {
                pauseTimer()
                
                if alarmSound {
                    playSound()
                }
                
                
                let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
                stats.timersCompleted += 1
                try? modelContext.save()
                
                showingSheet = true
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        hideUI = false
    }
    
    func resetTimer() {
        pauseTimer()
        
        isBreakTime = false
        
        time = defaultTimeStart
        
        selectedTime = defaultTimeStart
        
        if colorMode == .solid {
            heigth = screenSize
        }
    }
   
    func playSound() {
        AudioServicesPlaySystemSound(1005)
    }
    
    private func startBackgroundTimer() {
        backgroundStartDate = Date()
        backgroundTime = time
        
        // Start background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [self] in
            endBackgroundTask()
        }
        
        // Schedule notification for timer completion
        scheduleNotification(for: time)
    }
    
    private func stopBackgroundTimer() {
        endBackgroundTask()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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
        time = max(0, backgroundTime - elapsedTime)
        
        if time == 0 {
            handleTimerCompletion()
        }
    }
    
    private func scheduleNotification(for timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = isBreakTime ? "Break Time Complete" : "Focus Time Complete"
        content.body = "Your \(isBreakTime ? "break" : "focus") session has ended."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "timerCompletion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func handleTimerCompletion() {
        if alarmSound {
            playSound()
        }
        
        let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
        stats.timersCompleted += 1
        try? modelContext.save()
        
        showingSheet = true
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
}

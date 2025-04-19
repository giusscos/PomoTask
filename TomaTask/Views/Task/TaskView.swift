//
//  TomaTaskView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI
import AudioToolbox

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
    
    @State var store = Store()
    
    @State var task: TomaTask
    
    @State var hideUI: Bool = false
    @State var dimDisplay: Bool = false
    @State var alarmSound: Bool = true
    
    @State private var activeSheet: TaskSheet?
    
    // AppStorage for colors using hex strings
    @AppStorage("meshColor1Hex") private var meshColor1Hex: String = "#000000" // Black
    @AppStorage("meshColor2Hex") private var meshColor2Hex: String = "#FFA500" // Orange
    @AppStorage("meshColor3Hex") private var meshColor3Hex: String = "#FF0000" // Red
    @AppStorage("colorMode") private var storedColorMode: String = "solid"
    
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
                
                TimerActions(alarmSound: $alarmSound, dimDisplay: $dimDisplay, showingColorCustomization: Binding(
                    get: { self.activeSheet == .colorCustomization },
                    set: { if $0 { self.activeSheet = .colorCustomization } else { self.activeSheet = nil } }
                ))
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
            
            // Load saved colors when the view appears
            loadSavedColors()
        }
        .navigationBarBackButtonHidden()
        .toolbar(hideUI ? .hidden : .visible, for: .tabBar)
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
    
    func startTimer() {
        if task.repetition == repetition {
            repetition = 0
            time = maxDuration
            heigth = screenSize
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if(time > 0) {
                isRunning = true
                
                time -= 1
                
                if(pauseTime) {
                    heigth += screenSize / CGFloat(maxDuration / 1)
                } else {
                    heigth -= screenSize / CGFloat(maxDuration / 1)
                }
            } else {
                pauseTime.toggle()
                
                if pauseTime {
                    repetition += 1
                }
                
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        if(task.repetition == repetition){
            pauseTime = false
        }
        
        if(alarmSound) {
            playSound()
        }
        
        isRunning = false
        
        timer?.invalidate()
        
        if(time == 0){
            time = pauseTime ? pauseDuration : maxDuration
        }
    }
    
    func restartTimer() {
        isRunning = false
        
        repetition = 0
        
        timer?.invalidate()
        
        time = maxDuration
        heigth = screenSize
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(1005)
    }
}

#Preview {
    TaskView(task: TomaTask())
}

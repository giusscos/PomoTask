//
//  ProgressiveTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 23/10/24.
//

import SwiftUI
import AudioToolbox
import ActivityKit
import UserNotifications

var defaultTimeStart: Double = 5 * 60
var defaultMinSeconds: Double = 3 * 60
var defaultMaxSeconds: Double = 25 * 60

let notificationCenter = UNUserNotificationCenter.current()

struct ProgressiveTimer: View {
    @State private var alarmSound: Bool = true
    @State private var dimDisplay: Bool = false
    @State private var showingSheet: Bool = false
    
    @State private var meshValue1 = Float.random(in: 0.5...0.7)
    @State private var meshValue2 = Float.random(in: 0.4...0.8)
    
    @State private var selectedTime: Double = defaultTimeStart
    @State private var totalTime: TimeInterval = defaultTimeStart
    @State private var remainingTime: TimeInterval = defaultTimeStart
    @State private var startTime: Date? = nil
    @State private var timer: Timer? = nil
    @State private var expirationDate: Date = Date()
    
    @State private var isRunning: Bool = false
    @State private var isBreakTime: Bool = false
    
    let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    func handleMeshAnimation() {
        meshValue1 = cos(.random(in: 0.0...1.0)) > 0 ? Float.random(in: 0.5...0.7) : Float.random(in: 0.4...0.8)
        meshValue2 = cos(.random(in: 0.0...1.0)) < 0 ? Float.random(in: 0.4...0.6) : Float.random(in: 0.5...0.7)
    }
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .overlay {
                        MeshGradient(
                            width: 3,
                            height: 4,
                            points: [
                                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                                [0.0, 0.3], [meshValue1, 0.4], [1.0, 0.3],
                                [0.0, 0.6], [0.5, meshValue2], [1.0, 0.6],
                                [0.0, 1], [0.5, 1], [1.0, 1]
                            ],
                            colors: [
                                .black, .black, .black,
                                .orange, .orange, .orange,
                                .red, .red, .red,
                                .black, .black, .black
                            ],
                            smoothsColors: true,
                            colorSpace: .perceptual
                        ).animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: remainingTime)
                    }.ignoresSafeArea(.all)
                
                HStack {
                    Button {
                        alarmSound.toggle()
                    } label: {
                        Label("Toggle sound", systemImage: alarmSound ? "speaker.fill" : "speaker.slash.fill")
                            .labelStyle(.iconOnly)
                            .contentTransition(.symbolEffect(.replace))
                            .padding(8)
                            .foregroundColor(.white)
                            .bold()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 10, x: 0, y: 4)
                            .animation(.none, value: alarmSound)
                    }
                    
                    Button {
                        dimDisplay.toggle()
                        
                        UIApplication.shared.isIdleTimerDisabled = dimDisplay
                    } label: {
                        Label("Auto-lock", systemImage: dimDisplay ? "lock" : "lock.open")
                            .contentTransition(.symbolEffect(.replace))
                            .padding(8)
                            .foregroundColor(.white)
                            .bold()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius: 10, x: 0, y: 4)
                            .animation(.none, value: dimDisplay)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                
                VStack (spacing: 8) {
                    Text(!isBreakTime ? "Focus time" : "Break time")
                        .font(.headline)
                    
                    Text(timeFormatter.string(from: remainingTime) ?? "00:00")
                        .font(.system(size: 48, weight: .bold))
                    
                    HStack {
                        Button {
                            resetTimer()
                        } label: {
                            Label("Stop", systemImage: "stop.fill")
                                .font(.title)
                                .labelStyle(.iconOnly)
                                .contentTransition(.symbolEffect(.replace))
                                .opacity(remainingTime == selectedTime ? 0.3 : 1)
                        }.disabled(remainingTime == selectedTime)
                        
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
            }
        }
        .sheet(isPresented: $showingSheet, onDismiss: {
            remainingTime = selectedTime
            
            totalTime = selectedTime
            
            startTime = nil
        }) {
            FeedbackSheet(selectedTime: $selectedTime, breakTime: $isBreakTime)
        }
    }
    
    func startTimer() {
        isRunning = true
        
        if startTime == nil {
            startTime = Date()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            handleMeshAnimation()
            
            if let startTime = startTime {
                let elapsedTime = Date().timeIntervalSince(startTime)
                
                remainingTime = totalTime - elapsedTime
                
                if remainingTime <= 0 {
                    pauseTimer()
                    
                    remainingTime = 0
                    
                    if alarmSound {
                        playSound()
                    }
                    
                    showingSheet = true
                }
            }
        }
    }
    
    func killTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        startTime = nil
    }
    
    func pauseTimer() {
        killTimer()
        
        totalTime = remainingTime
    }
    
    func resetTimer() {
        killTimer()
        
        remainingTime = defaultTimeStart
        
        selectedTime = defaultTimeStart
        
        totalTime = defaultTimeStart
    }
   
    func playSound() {
        AudioServicesPlaySystemSound(1005)
    }
 }
                 
 struct FeedbackSheet: View {
     @Environment(\.dismiss) var dismiss
          
     @Binding var selectedTime: Double
     @Binding var breakTime: Bool
     
    var body: some View {
        NavigationStack {
            VStack {
                Text("How do you feel?")
                    .font(.title)
                    .fontWeight(.semibold)
                
                VStack {
                    Button {
                        breakTime = true
                        selectedTime = 5 * 60
                        
                        dismiss()
                    } label: {
                        Text("I need a break")
                            .padding()
                            .bold()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        breakTime = false
                        
                        selectedTime = selectedTime - defaultMinSeconds <= defaultMinSeconds ? defaultMinSeconds : selectedTime - defaultMinSeconds
                        
                        dismiss()
                    } label: {
                        Text("I need less time")
                            .padding()
                            .bold()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        breakTime = false
                        
                        selectedTime = selectedTime + defaultMinSeconds <= defaultMaxSeconds ? selectedTime + defaultMinSeconds : defaultMaxSeconds
                        
                        dismiss()
                    } label: {
                        Text("I'm in the flow")
                            .padding()
                            .bold()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
        }
    }
}

#Preview {
    ProgressiveTimer()
}

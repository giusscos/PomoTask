//
//  ProgressiveTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 23/10/24.
//

import SwiftUI
import AudioToolbox

var defaultTimeStart: Int = 3

struct ProgressiveTimer: View {
    @State private var alarmSound: Bool = true
    @State private var dimDisplay: Bool = false
    
    @State private var timer: Timer?
    @State private var timeRemaining: Int = defaultTimeStart // Inizialmente 5 minuti (300 secondi)
    
    @State private var isBreakTime: Bool = false
    @State private var isRunning: Bool = false
    @State private var showingSheet: Bool = false  // Per mostrare lo sheet di feedback
    
    @State private var selectedTime: Int = defaultTimeStart // Tempo selezionato per il prossimo Pomodoro
    @State private var feedbackMessage: String = ""  // Messaggio di feedback dall'utente
    
    @State private var meshValue1 = Float.random(in: 0.5...0.7)
    @State private var meshValue2 = Float.random(in: 0.4...0.8)
    
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
                        ).animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: timeRemaining)
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
                    
                    Text("\(timeString(from: timeRemaining))")
                        .font(.largeTitle)
                        .bold()
                    
                    HStack {
                        if timeRemaining < selectedTime {
                            Button {
                                restartTimer()
                            } label: {
                                Label("Stop", systemImage: "stop.fill")
                                    .font(.title)
                                    .labelStyle(.iconOnly)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }
                        
                        Button {
                            isRunning.toggle()
                            
                            isRunning ? startTimer() : stopTimer()
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
            timeRemaining = selectedTime
        }) {
            FeedbackSheet(selectedTime: $selectedTime, feedbackMessage: $feedbackMessage, breakTime: $isBreakTime)
        }
    }
                 
     // Convert seconds in mm:ss
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            meshValue1 = cos(Float(timeRemaining)) > 0 ? Float.random(in: 0.5...0.7) : Float.random(in: 0.4...0.8)
            
            meshValue2 = cos(Float(timeRemaining)) < 0 ? Float.random(in: 0.4...0.6) : Float.random(in: 0.5...0.7)
            
            if(timeRemaining > 0){
                isRunning = true
                
                timeRemaining -= 1
            } else {
                showingSheet = true
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        if(alarmSound && timeRemaining == 0) {
            playSound()
        }
        
        isRunning = false
        
        timer?.invalidate()
    }
    
    func restartTimer() {
        isBreakTime = false
        
        isRunning = false
        
        timer?.invalidate()

        timeRemaining = defaultTimeStart
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(1005)
    }
 }
                 
 struct FeedbackSheet: View {
    @Environment(\.dismiss) var dismiss
     
    var defaultMinMinutes = 3 * 60
    var defaultMaxMinutes = 25 * 60
     
    @Binding var selectedTime: Int
    @Binding var feedbackMessage: String
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
                        
                        selectedTime = selectedTime - defaultMinMinutes <= defaultMinMinutes ? defaultMinMinutes : selectedTime - defaultMinMinutes
                        
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
                        
                        selectedTime = selectedTime + defaultMinMinutes <= defaultMaxMinutes ? selectedTime + defaultMinMinutes : defaultMaxMinutes
                        
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

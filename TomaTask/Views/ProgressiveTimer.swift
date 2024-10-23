//
//  ProgressiveTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 23/10/24.
//

import SwiftUI
import AudioToolbox

var defaultTimeStart: Int = 1

struct ProgressiveTimer: View {
    var alarmSound: Bool = false
    
    @State private var timer: Timer?
    @State private var timeRemaining: Int = defaultTimeStart // Inizialmente 5 minuti (300 secondi)
    
    @State private var isBreakTime: Bool = false
    @State private var isRunning: Bool = false
    @State private var showingSheet: Bool = false  // Per mostrare lo sheet di feedback
    
    @State private var selectedTime: Int = defaultTimeStart // Tempo selezionato per il prossimo Pomodoro
    @State private var feedbackMessage: String = ""  // Messaggio di feedback dall'utente
    
    var body: some View {
        VStack {
            Text(!isBreakTime ? "Focus time" : "Break time")
                .font(.headline)
                .padding()
            
            Text("\(timeString(from: timeRemaining))")
                .font(.largeTitle)
                .bold()
                .padding()
            
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
                    Label(!isRunning ? "Start" : "Paus", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .contentTransition(.symbolEffect(.replace))
                        .labelStyle(.iconOnly)
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
        if(alarmSound) {
            playSound()
        }
        
        isRunning = false
        
        timer?.invalidate()
    }
    
    func restartTimer() {
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
     
    @Binding var selectedTime: Int
    @Binding var feedbackMessage: String
    @Binding var breakTime: Bool
     
    @State private var goManual: Bool = false
    @State private var autoSelectedTime: Int = 180
    @State private var manualSelectedTime: Int = 180
     
    let feedbackMessages: [Int: String] = [
        180: "I need to slow down",
        300: "I can't complete a task in time",
        600: "I just complete all my task",
        900: "I just complete a good amount of tasks",
        1200: "I just complete a simple task"
     ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("How do you feel?")
                    .font(.title)
                
                Picker("How do you feel?", selection: $autoSelectedTime) {
                    ForEach(feedbackMessages.sorted(by: <), id: \.key) { key, value in
                        Text("\(value)").tag(key)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Button{
                    withAnimation (.spring()) {
                        goManual.toggle()
                    }
                } label: {
                    Text(!goManual ? "Select a duration manually" : "Duration based on how you felt")
                        .bold()
                }
                
                if (goManual) {
                    Picker("Select a duration", selection: $manualSelectedTime) {
                        ForEach([180, 300, 480, 600, 900, 1200], id: \.self) { time in
                            Text("\(time / 60) minutes").tag(time)
                        }
                    }.pickerStyle(.navigationLink)
                }
                
                HStack {
                    Button {
                        selectNextTime()
                        breakTime = true
                        dismiss()
                    } label: {
                        Text("Start Break Time")
                            .padding()
                            .bold()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    Button {
                        selectNextTime()
                        
                        breakTime = false
                        
                        dismiss()
                    } label: {
                        Text("Start Focus Time")
                            .padding()
                            .bold()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }.frame(maxHeight: .infinity, alignment: .bottom)
                
            }.padding()
        }
    }
     
     func selectNextTime() {
         selectedTime = goManual ? manualSelectedTime : autoSelectedTime
     }
}
                 
                 
#Preview {
    ProgressiveTimer()
}

//
//  WatchProgressiveTimerView.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import WatchKit

// Constants for the timer
let defaultTimeStart: Double = 5 * 60
let defaultMinSeconds: Double = 3 * 60
let defaultMaxSeconds: Double = 25 * 60

struct WatchProgressiveTimerView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var time: TimeInterval = defaultTimeStart
    @State private var timer: Timer?
    @State private var isRunning: Bool = false
    @State private var isBreakTime: Bool = false
    @State private var selectedTime: Double = defaultTimeStart
    @State private var showingSheet: Bool = false
    
    // Derived state from AppStorage
    @State var meshColor1: Color = .black
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(!isBreakTime ? "Focus time" : "Break time")
                    .font(.headline)
                
                Text(formattedTime())
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack (spacing: 24) {
                    Button {
                        resetTimer()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.title2)
                            .labelStyle(.iconOnly)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                    .disabled(time == selectedTime)
                    
                    Button {
                        isRunning.toggle()
                        
                        isRunning ? startTimer() : pauseTimer()
                    } label: {
                        Label(!isRunning ? "Start" : "Pause", systemImage: isRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .contentTransition(.symbolEffect(.replace))
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                }
                .foregroundStyle(.primary)
            }
            .padding()
            .navigationTitle("Progressive")
            .sheet(isPresented: $showingSheet, onDismiss: {
                time = selectedTime
            }) {
                WatchFeedbackSheet(selectedTime: $selectedTime, breakTime: $isBreakTime)
            }
            .onAppear() {
                time = defaultTimeStart
            }
            .onDisappear() {
                resetTimer()
            }
        }
    }
        
    func formattedTime() -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
        stats.timersStarted += 1
        try? modelContext.save()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            stats.totalFocusTime += 1
            
            if time > 0 {
                isRunning = true
                time -= 1
            } else {
                pauseTimer()
                playSound()
                
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
    }
    
    func resetTimer() {
        pauseTimer()
        isBreakTime = false
        time = defaultTimeStart
        selectedTime = defaultTimeStart
    }
    
    func playSound() {
        WKInterfaceDevice.current().play(.notification)
    }
}

struct WatchFeedbackSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedTime: Double
    @Binding var breakTime: Bool
    
    var body: some View {
        VStack {
            Text("How do you feel?")
                .font(.headline)
            
            Button {
                takeABreak()
            } label: {
                Text("I need a break")
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            Button {
                useTheSameTime()
            } label: {
                Text("I need less time")
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            Button {
                increaseTime()
            } label: {
                Text("I'm in the flow")
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
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
    WatchProgressiveTimerView()
        .modelContainer(for: TomaTask.self, inMemory: true)
} 

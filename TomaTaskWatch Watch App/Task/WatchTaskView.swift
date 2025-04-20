//
//  WatchTaskView.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import WatchKit

struct WatchTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var task: TomaTask
    
    @State private var timer: Timer?
    @State var time: TimeInterval = 0
    @State private var isRunning: Bool = false
    @State private var pauseTime: Bool = false
    @State private var repetition: Int = 0
    @State private var showingSubTasks: Bool = false
    
    var maxDuration: TimeInterval {
        Double(task.maxDuration * 60)
    }
    
    var pauseDuration: TimeInterval {
        Double(task.pauseDuration * 60)
    }
    
    var body: some View {
        VStack {
            // Timer UI
            VStack {
                Text(pauseTime ? "Break time" : "Focus time")
                    .font(.headline)
                
                Text(formattedTime())
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(repetition + 1)/\(task.repetition)")
                    .font(.caption)
                
                HStack (spacing: 24) {
                    Button {
                        restartTimer()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.title2)
                            .labelStyle(.iconOnly)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                    .disabled(time == maxDuration)
                    
                    Button {
                        isRunning.toggle()
                        
                        isRunning ? startTimer() : stopTimer()
                    } label: {
                        Label(!isRunning ? "Start" : "Pause", systemImage: isRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .contentTransition(.symbolEffect(.replace))
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 8)
                .foregroundStyle(.primary)
                
                if !task.unwrappedTasks.isEmpty {
                    Button {
                        showingSubTasks = true
                    } label: {
                        Label("Tasks", systemImage: "checklist")
                            .font(.subheadline)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingSubTasks) {
            WatchSubTaskList(tasks: task.unwrappedTasks)
        }
        .onAppear() {
            time = maxDuration
        }
        .onDisappear() {
            stopTimer()
        }
    }
    
    func formattedTime() -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        if task.repetition == repetition {
            repetition = 0
            time = maxDuration
        }
        
        let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
        stats.timersStarted += 1
        
        try? modelContext.save()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            stats.totalFocusTime += 1
            
            if time > 0 {
                isRunning = true
                time -= 1
            } else {
                pauseTime.toggle()
                
                if pauseTime {
                    repetition += 1
                    
                    if task.repetition == repetition {
                        let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
                        stats.timersCompleted += 1
                        try? modelContext.save()
                    }
                }
                
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        if task.repetition == repetition {
            pauseTime = false
        }
        
        if time == 0 {
            playSound()
        }
        
        isRunning = false
        timer?.invalidate()
        
        if time == 0 {
            time = pauseTime ? pauseDuration : maxDuration
        }
    }
    
    func restartTimer() {
        isRunning = false
        repetition = 0
        timer?.invalidate()
        time = maxDuration
    }
    
    func playSound() {
        WKInterfaceDevice.current().play(.notification)
    }
}


#Preview {
    NavigationStack {
        WatchTaskView(task: TomaTask())
            .modelContainer(for: TomaTask.self, inMemory: true)
    }
}

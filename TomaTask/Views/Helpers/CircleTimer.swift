//
//  CircleTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import SwiftUI

struct CircleTimer: View {
    var task: TomaTask
    
    @State var time: TimeInterval
    @State private var timeRemaining: TimeInterval = 10
    @State private var timer: Timer?
    
    @State private var isRunning: Bool = false
    @State private var pauseTime: Bool = false
    @State private var repetition: Int = 0
    
    var body: some View {
        VStack (spacing: 8) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .fill(Color.primary)
                
                Circle()
                    .trim(from: 0, to: CGFloat(1 - (time / task.maxDuration)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .fill(Color.accentColor)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: timeRemaining)
                
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
                            .foregroundColor(.black)
                    } else {
                        Text("Congratulations! You completed the TomoTask!")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .bold()
                            .foregroundColor(.black)
                    }
                
                    Button {
                        isRunning.toggle()
                        
                        isRunning ? startTimer() : stopTimer()
                    } label: {
                        Label(!isRunning ? "Start Timer" : "Stop Timer", systemImage: isRunning ? "pause.fill" : "play.fill")
                            .font(.headline)
                    }
                }
            }
            .padding()
        }
    }
    
    func formattedTime () -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        if task.repetition == repetition {
            repetition = 0
            time = task.maxDuration
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if(time > 0) {
                isRunning = true
                
                time -= 1
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
        
        isRunning = false
        timer?.invalidate()
        
        if(time == 0){
            time = pauseTime ? task.pauseDuration : task.maxDuration
        }
    }
}

#Preview {
    let task = TomaTask()
    
    return Group{
        CircleTimer(task: task, time: task.maxDuration)
    }
}

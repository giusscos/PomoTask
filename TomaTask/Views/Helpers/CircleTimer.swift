//
//  CircleTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import SwiftUI

extension Animation {
    static func ripple() -> Animation {
        Animation.spring(response: 1, dampingFraction: 1)
            .speed(1.5)
    }
}

struct CircleTimer: View {
    var task: TomaTask
    
    @State var time: TimeInterval
    
    @State private var timeRemaining: TimeInterval = 10
    @State private var timer: Timer?
    @State private var isRunning: Bool = false
    
    var body: some View {
        VStack (spacing: 8) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .fill(Color.black)
                
                Circle()
                    .trim(from: 0, to: CGFloat(1 - (time / task.maxDuration)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .fill(Color.orange)
                    .rotationEffect(.degrees(-90))
                    .animation(.ripple(), value: timeRemaining)
                
                VStack {
                    Text(formattedTime())
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.black)
                
                    Button {
                        withAnimation() {
                            isRunning.toggle()
                        }
                        
                        if isRunning {
                            startTimer()
                        } else {
                            stopTimer()
                        }
                    } label: {
                        Label(!isRunning ? "Start Timer" : "Stop Timer", systemImage: isRunning ? "stop.circle" : "play.circle")
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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if(time > 0) {
                isRunning = true
                time -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        
        if(time == 0){
            time = 10
        }
    }
}

#Preview {
    let task = TomaTask()
    
    return Group{
        CircleTimer(task: task, time: task.maxDuration)
    }
}

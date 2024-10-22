//
//  CircleTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import SwiftUI

let screenSize = UIScreen.main.bounds.height

struct TimerView: View {
    var task: TomaTask
    
    @State private var timer: Timer?
    @State var time: TimeInterval
    @State private var isRunning: Bool = false
    @State private var pauseTime: Bool = false
    @State private var repetition: Int = 0
    
    @State var heigth: CGFloat = screenSize
    
    var maxDuration : TimeInterval {
         Double(task.maxDuration * 60)
    }
        
    var pauseDuration : TimeInterval {
        Double(task.pauseDuration * 60)
    }
    
    var body: some View {
        VStack (spacing: 8) {
            ZStack {
                Rectangle()
                    .overlay(content: {
                        Color.red
                            .scaleEffect(y: heigth / screenSize, anchor: .bottom)
                            .background(.background)
                    })
                    .clipped()
                    .animation(.linear(duration: 1), value: heigth)
                
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
                        }
                    }
                }
                .foregroundStyle(.white)
                .blendMode(.difference)
            }
        }
        .ignoresSafeArea(.all)
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
                
                if(pauseTime){
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
}

#Preview {
    TimerView(task: TomaTask(), time: 30)
}

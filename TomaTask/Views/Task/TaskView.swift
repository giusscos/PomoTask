//
//  TomaTaskView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI
import AudioToolbox

struct TaskView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var task: TomaTask
    
    @State var hideUI: Bool = false
    @State var dimDisplay: Bool = false
    @State var alarmSound: Bool = true
    @State var isExpanded: Bool = false
    
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
    
    var body: some View {
        VStack {
            ZStack {
                SolidTimer(heigth: heigth)
                    .onTapGesture {
                        hideUI.toggle()
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
                }.onAppear(){
                    time = maxDuration
                }
                .foregroundStyle(.primary)
                .hideUIAnimation(hideUI: hideUI)
                
                TimerActions(alarmSound: $alarmSound, dimDisplay: $dimDisplay)
                    .hideUIAnimation(hideUI: hideUI)
                
                if(!task.unwrappedTasks.isEmpty) {
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        Label(isExpanded ? "Reduce timer" : "Expand timer", systemImage: isExpanded ? "chevron.up" : "chevron.down")
                            .labelStyle(.iconOnly)
                            .contentTransition(.symbolEffect(.replace))
                            .padding(8)
                            .foregroundColor(.white)
                            .bold()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 10, x: 0, y: 4)
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }.animation(.spring(), value: isExpanded)
            
            if(!task.unwrappedTasks.isEmpty && !isExpanded){
                SubTaskList(tasks: task.tasks ?? [])
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .move(edge: .bottom)))
            }
        }.navigationBarBackButtonHidden(true)
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
    TaskView(task: TomaTask(), time: 5)
}

//
//  TomaTaskView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct TaskView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var task: TomaTask
    @State var dimDisplay: Bool = false
    @State var alarmSound: Bool = false
    
    var time: TimeInterval {
        Double(task.maxDuration * 60)
    }
    
    var body: some View {
        portrait()
    }
    
    func portrait() -> some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Button (role: .destructive) {
                            dismiss()
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                                .labelStyle(.iconOnly)
                                .padding(8)
                                .foregroundColor(.white)
                                .bold()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 10, x: 0, y: 4)
                        }
                        
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
                        
                        Spacer()
                    }
                    Spacer()
                }.zIndex(1)
                .padding()
                
                TimerView(task: task, alarmSound: alarmSound, time: time)
            }
            
            if(!task.unwrappedTasks.isEmpty){
                SubTaskList(tasks: task.tasks ?? [])
            }
        }.navigationBarBackButtonHidden(true)
//        .ignoresSafeArea(.all)
    }
}

#Preview {
    TaskView(task: TomaTask())
}

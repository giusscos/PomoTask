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
    @State var alarmSound: Bool = true
    @State var isExpanded: Bool = false
    
    var time: TimeInterval {
        Double(task.maxDuration * 60)
    }
    
    var body: some View {
        portrait()
    }
    
    func portrait() -> some View {
        VStack {
            ZStack {
                TimerView(task: task, alarmSound: $alarmSound, time: time)
                            
                TimerActions(alarmSound: $alarmSound, dimDisplay: $dimDisplay)
                
                if(!task.unwrappedTasks.isEmpty) {
                    withAnimation {
                        Button {
                            isExpanded.toggle()
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
                        }.padding()
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                }
            }.animation(.spring(), value: isExpanded)
            
            if(!task.unwrappedTasks.isEmpty && !isExpanded){
                SubTaskList(tasks: task.tasks ?? [])
            }
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TaskView(task: TomaTask())
}

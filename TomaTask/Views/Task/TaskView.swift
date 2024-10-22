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
                        Spacer()
                    }
                    Spacer()
                }.zIndex(1)
                .padding()
                
                TimerView(task: task, time: time)
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

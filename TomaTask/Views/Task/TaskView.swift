//
//  TomaTaskView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct TaskView: View {
    @State var task: TomaTask
    
    var time: TimeInterval {
        Double(task.maxDuration * 60)
    }
    
    var body: some View {
        portrait()
    }
    
    func portrait() -> some View {
        VStack {
            TimerView(task: task, time: time)
            
            SubTaskList(tasks: task.tasks)
            
            if(!task.tasks.isEmpty){
                SubTaskList(tasks: task.tasks)
            }
        }.navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    TaskView(task: TomaTask())
}

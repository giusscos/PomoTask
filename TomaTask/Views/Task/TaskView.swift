//
//  TomaTaskView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct TaskView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State var task: TomaTask
    
    var time: TimeInterval {
        Double(task.maxDuration * 60)
    }
    
    var isLandscape: Bool { verticalSizeClass == .compact }
    
    var body: some View {
        if (isLandscape) {
            landscape()
        } else {
            portrait()
        }
    }
    
    func landscape() -> some View {
        HStack {
            CircleTimer(task: task, time: time)
            
            if(!task.tasks.isEmpty){
                SubTaskList(tasks: task.tasks)
            }
        }.navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all)
    }
    
    func portrait() -> some View {
        VStack {
            CircleTimer(task: task, time: time)
            
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

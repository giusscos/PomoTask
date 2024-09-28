//
//  TomaTaskView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct TomaTaskView: View {
    var task: TomaTask
    
    var body: some View {
        VStack {
            HStack {
                Text(task.title)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
            }
            .padding()
            
            CircleTimer(task: task, time: task.maxDuration)
            
            SubTaskList(tasks: task.tasks)
        }
    }
}

#Preview {
    TomaTaskView(task: ModelData().tomaTasks.first!)
}

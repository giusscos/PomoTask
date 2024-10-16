//
//  SubTaskList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct SubTaskList: View {
    var tasks: [SubTask]
    
    @State var tasksCompleted: Bool = false

    var body: some View {
        List {
            Button {
                tasksCompleted.toggle()
                
                tasks.forEach() { $0.isCompleted = tasksCompleted }
            } label: {
                Label(!tasksCompleted ? "Complete" : "Reset", systemImage: !tasksCompleted ? "plus.circle.fill" : "minus.circle.fill")
            }
            
            ForEach(tasks, id: \.self) { task in
                Label(task.text, systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .strikethrough(task.isCompleted)
                    .disabled(task.isCompleted)
                    .onTapGesture {
                        task.isCompleted.toggle()

                        setTasksCompleted()
                    }
            }
        }.onAppear() {
            setTasksCompleted()
        }
    }
    
    private func setTasksCompleted() {
        if(tasks.filter(\.isCompleted).count == tasks.count) {
            tasksCompleted = true
            return
        }
        
        tasksCompleted = false
    }
}


#Preview {
    SubTaskList(tasks: [SubTask(text: "Task 1", isCompleted: true)])
}

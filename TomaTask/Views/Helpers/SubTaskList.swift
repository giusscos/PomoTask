//
//  SubTaskList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI
import SwiftData

struct SubTaskList: View {
    @Environment(\.modelContext) private var modelContext

    var tasks: [SubTask]
    
    @State var tasksCompleted: Bool = false

    var body: some View {
        List {
            Button {
                tasksCompleted.toggle()
                
                tasks.forEach() { task in
                    if task.isCompleted != tasksCompleted {
                        task.isCompleted = tasksCompleted
                        
                        if tasksCompleted {
                            let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
                            
                            stats.subtasksCompleted += 1
                            
                            try? modelContext.save()
                        }
                    }
                }
            } label: {
                Label(!tasksCompleted ? "Complete" : "Reset", systemImage: !tasksCompleted ? "plus.circle.fill" : "minus.circle.fill")
                    .contentTransition(.symbolEffect(.replace))
            }
            .listRowBackground(Color.clear)
            
            ForEach(tasks, id: \.self) { task in
                Label(task.text, systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .strikethrough(task.isCompleted)
                    .disabled(task.isCompleted)
                    .onTapGesture {
                        let wasCompleted = task.isCompleted
                        task.isCompleted.toggle()
                        
                        if !wasCompleted && task.isCompleted {
                            let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
                            stats.subtasksCompleted += 1
                            try? modelContext.save()
                        }
                        
                        setTasksCompleted()
                    }
                    .listRowBackground(Color.clear)
            }
        }
        .padding()
        .listStyle(.plain)
        .background(Color.clear)
        .onAppear() {
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

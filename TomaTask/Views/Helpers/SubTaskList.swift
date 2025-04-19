//
//  SubTaskList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct SubTaskList: View {
//    @Environment(\.dismiss) var dismiss
    
    var tasks: [SubTask]
    
    @State var tasksCompleted: Bool = false

    var body: some View {
//        NavigationStack {
            List {
                Button {
                    tasksCompleted.toggle()
                    
                    tasks.forEach() { $0.isCompleted = tasksCompleted }
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
                            task.isCompleted.toggle()
                            
                            setTasksCompleted()
                        }
                        .listRowBackground(Color.clear)
                }
            }
            .padding()
            .listStyle(.plain)
            .background(Color.clear)
//            .toolbar(content: {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Label("Close", systemImage: "xmark.circle.fill")
//                            .font(.headline)
//                    }
//                }
//            })
            .onAppear() {
                setTasksCompleted()
            }
//        }
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

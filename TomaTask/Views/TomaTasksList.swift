//
//  TiimerList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import SwiftUI
import SwiftData

struct TomaTasksList: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var tomaTasks: [TomaTask]
    
    @State var selectedTask: TomaTask?
    
    var body: some View {
        NavigationSplitView {
            List {
                if (tomaTasks.isEmpty) {
                    Text("No tasks yet! Create one by tapping the plus button in the top right corner.")
                } else {
                    ForEach(tomaTasks) { task in
                        NavigationLink {
                            TaskView(task: task)
                        } label: {
                            TaskRow(task: task)
                        }.swipeActions (edge: .trailing) {
                            Button(role: .destructive) {
                                deleteTask(item: task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                selectedTask = task
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                }
            }.navigationTitle("Timers")
            .toolbar {
                Button {
                    addTask()
                } label: {
                    Label("Add timer", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
            }
            .sheet(item: $selectedTask) { task in
                EditTask(task: task)                
            }
        } detail: {
            Text("Select a TomaTask")
        }
    }
    
    private func addTask() {
        let tomatask = TomaTask()
        selectedTask = tomatask
        modelContext.insert(tomatask)
    }
    
    private func deleteTask(item: TomaTask) {
        modelContext.delete(item)
    }
}

#Preview {
    TomaTasksList(selectedTask: TomaTask())
}

//
//  WatchTomaTasksListView.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import SwiftData

struct WatchTomaTasksListView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var tomaTasks: [TomaTask]
    
    @State var selectedTask: TomaTask?
    @State var selectedCategory: TomaTask.Category = .study
    
    var body: some View {
        NavigationStack {
            List {
                if (tomaTasks.isEmpty) {
                    Text("No tasks")
                        .font(.caption)
                } else {
                    ForEach(tomaTasks) { task in
                        NavigationLink {
                            WatchTaskView(task: task)
                        } label: {
                            WatchTaskRow(task: task)
                        }
                        .swipeActions(edge: .trailing) {
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
                            .tint(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addTask()
                    } label: {
                        Label("Add", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(item: $selectedTask) { task in
                WatchEditTask(task: task)
            }
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
    WatchTomaTasksListView()
        .modelContainer(for: TomaTask.self, inMemory: true)
} 

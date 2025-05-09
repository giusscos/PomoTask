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
    @State var selectedCategory: TomaTask.Category = .study
    
    var body: some View {
        VStack {
            List {
                if (tomaTasks.isEmpty) {
                    Text("No tasks in this category yet!")
                        .font(.title3)
                } else {
                    ForEach(tomaTasks) { task in
                        NavigationLink {
                            TaskView(task: task)
                        } label: {
                            TaskRow(task: task)
                        }
                        .swipeActions (edge: .trailing) {
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
            .listStyle(.plain)
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItemGroup (placement: .topBarTrailing) {
                    Button {
                        addTask()
                    } label: {
                        Label("Add", systemImage: "plus")
                            .labelStyle(.titleOnly)
                    }
                }
            }
            .sheet(item: $selectedTask) { task in
                EditTask(task: task)
                    .onAppear() {
                        task.category = selectedCategory
                    }
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
    TomaTasksList(selectedTask: TomaTask())
}

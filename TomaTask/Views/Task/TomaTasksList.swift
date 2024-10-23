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
    
    var timers: [TomaTask] {
        tomaTasks.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationStack {
            Picker("Category", selection: $selectedCategory) {
                ForEach(TomaTask.Category.allCases) { season in
                    Text(season.rawValue).tag(season)
                }
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List {
                if (timers.isEmpty) {
                    Text("No tasks in this category yet!")
                        .font(.title3)
                } else {
                    ForEach(timers) { task in
                        NavigationLink {
                            TaskView(task: task)
                                .toolbar(.hidden, for: .tabBar)
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
            }.listStyle(.plain)
            .navigationTitle("Timers")
            .toolbar {
                Button {
                    addTask()
                } label: {
                    Label("Add", systemImage: "plus")
                    .labelStyle(.titleOnly)
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

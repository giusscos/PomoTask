//
//  WatchEditTask.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import SwiftData

struct WatchEditTask: View {
    @Environment(\.dismiss) var dismiss
    
    @Bindable var task: TomaTask
    
    @State var newSubTask: String = ""
    
    var body: some View {
        TabView {
            basicInfoTab
            
            subtasksTab
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle("Edit")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Basic Info Tab
    private var basicInfoTab: some View {
        List {
            Section {
                TextField("Task Title", text: $task.title)
            } header: {
                Text("Title")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                Picker("Duration", selection: $task.maxDuration) {
                    ForEach(1..<61) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                    
                Picker("Pause", selection: $task.pauseDuration) {
                    ForEach(1..<61) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                
                Picker("Repeat", selection: $task.repetition) {
                    ForEach(1..<10) { time in
                        Text("\(time) \(time == 1 ? "time" : "times")").tag(time)
                    }
                }
            } header: {
                Text("Time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Subtasks Tab
    private var subtasksTab: some View {
        List {
            Section {
                TextField("New subtask", text: $newSubTask)
                    .onSubmit {
                        addSubTask()
                    }
            } header: {
                Text("Add Subtask")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if task.unwrappedTasks.isEmpty {
                Section {
                    Text("No subtasks yet")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Section {
                    ForEach(task.unwrappedTasks, id: \.self) { subtask in
                        HStack {
                            Text(subtask.text)
                                .font(.caption)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button {
                                deleteSubTask(subtask)
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .foregroundStyle(.red)
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                } header: {
                    Text("Subtasks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func addSubTask() {
        guard !newSubTask.isEmpty else { return }
        
        if task.tasks == nil {
            task.tasks = []
        }
        
        task.tasks?.append(SubTask(text: newSubTask))
        newSubTask = ""
    }
    
    private func deleteSubTask(_ subtask: SubTask) {
        if let index = task.tasks?.firstIndex(of: subtask) {
            task.tasks?.remove(at: index)
        }
    }
}

#Preview {
    WatchEditTask(task: TomaTask())
        .modelContainer(for: TomaTask.self, inMemory: true)
}

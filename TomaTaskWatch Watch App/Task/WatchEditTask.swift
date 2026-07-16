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
    
    var body: some View {
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
        .navigationTitle("Edit")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    WatchEditTask(task: TomaTask())
        .modelContainer(for: TomaTask.self, inMemory: true)
}

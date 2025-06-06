//
//  CreateTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct EditTask: View {
    @Environment(\.dismiss) var dismiss
    
    @Bindable var task: TomaTask
    
    @State var newSubTask: String = ""
    
    var body: some View {
        VStack {
            Button("Back") {
                dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Form {
                TextField("Title", text: $task.title)
                    .foregroundStyle(.secondary)
                
                HStack {
                    VStack(alignment: .center, spacing: 0) {
                        Text("Tasks duration")
                        Picker("Tasks duration", selection: $task.maxDuration) {
                            ForEach(1..<61) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                    
                    VStack(alignment: .center, spacing: 0) {
                        Text("Pause duration")
                        Picker("Pause duration", selection: $task.pauseDuration) {
                            ForEach(1..<61) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Stepper(
                        "Reapeat \(task.repetition) \(task.repetition == 1 ? "time" : "times")",
                        value: $task.repetition,
                        in: 1...10
                    )
                }
                
                HStack {
                    Button("Add subTask", action: addSubTask)
                    
                    Spacer()
                    
                    TextField("SubTask title", text: $newSubTask)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                
                if(task.unwrappedTasks.count > 0) {
                    Text("SubTasks")
                        .fontWeight(.semibold)
                    
                    ForEach(task.tasks ?? []) { task in
                        Text(task.text)
                            .padding(.horizontal)
                    }
                    .onDelete(perform: deleteTask)
                }
            }
            
            Spacer()
        }
        .animation(.easeInOut, value: task.tasks)
    }
    
    private func addSubTask () {
        guard !newSubTask.isEmpty else { return }
                
        task.tasks?.append(SubTask(text: newSubTask))
        
        newSubTask = ""
    }
    
    private func deleteTask(at offsets: IndexSet) {
        task.tasks?.remove(atOffsets: offsets)
    }
}

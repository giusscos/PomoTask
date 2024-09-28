//
//  CreateTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct CreateTask: View {
    @Environment(\.modelContext) var context
    @Environment(ModelData.self) var modelData
    
    @State var title: String = ""
    @State var desc: String = ""
    @State var category: TomaTask.Category = TomaTask.Category.study
    @State var status: TomaTask.Status = TomaTask.Status.alien
    @State var maxDuration: Int = 25
    @State var pauseDuration: Int = 5
    @State var repetition: Int = 4
    @State var tasks: [SubTask] = []
    @State var newSubTask: String = ""
    
    @Binding var cancelChange: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .cancel) {
                    cancelChange = !cancelChange
                }
                
                Spacer()
                
                Button("Create", action: {
                    addTomaTask()
                })
            }.padding()
            
            List {
                VStack(alignment: .leading) {
                    Text("Category Task")
                    Picker("Category Task", selection: $category) {
                        ForEach(TomaTask.Category.allCases) { season in
                            Text(season.rawValue).tag(season)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading) {
                    Text("Icon Task")
                    Picker("Icon Task", selection: $status) {
                        ForEach(TomaTask.Status.allCases) { season in
                            Text(season.rawValue).tag(season)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                HStack {
                    Text("Task name")
                    
                    Spacer()
                    
                    TextField("Title", text: $title)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                VStack(alignment: .leading) {
                    Text("Task description")
                    
                    
                    TextField("Description", text: $desc, axis: .vertical)
                        .lineLimit(...2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom)
                }
                HStack {
                    VStack(alignment: .center, spacing: 0) {
                        Text("Tasks duration")
                        Picker("Tasks duration", selection: $maxDuration) {
                            ForEach(0..<61) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                    
                    VStack(alignment: .center, spacing: 0) {
                        Text("Pause duration")
                        Picker("Pause duration", selection: $pauseDuration) {
                            ForEach(0..<61) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Picker("Pomodoro repetition", selection: $repetition) {
                        ForEach(0..<10) { minute in
                            Text("\(minute) times").tag(minute)
                        }
                    }
                }
                
                if(tasks.count > 0) {
                    ForEach(tasks) { task in
                        Text(task.text)
                    }
                    .onDelete(perform: deleteTask)
                }
                
                HStack {
                    Button("Add subTask", action: addSubTask)
                    
                    Spacer()
                    
                    TextField("SubTask name", text: $newSubTask)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .animation(.easeInOut, value: tasks)
    }
    
    private func addSubTask () {
        guard !newSubTask.isEmpty else { return }
                
        tasks.append(SubTask(text: newSubTask))
        
        newSubTask = ""
    }
    
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    private func addTomaTask () {
        modelData.addTask(
            title: title,
            desc: desc,
            maxDuration: maxDuration,
            pauseDuration: pauseDuration,
            repetition: repetition,
            tasks: tasks,
            category: category,
            status: status
        )
        
        context.insert(TomaTask(
            title: title,
            desc: desc,
            maxDuration: TimeInterval(maxDuration * 60),
            pauseDuration: TimeInterval(pauseDuration * 60),
            repetition: repetition,
            tasks: tasks,
            category: category,
            status: status
            )
        )
        
        cancelChange = !cancelChange
    }
}

#Preview {
    CreateTask(cancelChange: .constant(true))
        .environment(ModelData(tomaTasks: [TomaTask()], profile: Profile()))
}

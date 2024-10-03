//
//  CreateTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct CreateTask: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) var context
    
    @State var title: String = ""
    @State var desc: String = ""
    @State var category: TomaTask.Category = TomaTask.Category.study
    @State var status: TomaTask.Status = TomaTask.Status.alien
    @State var maxDuration: Int = 25
    @State var pauseDuration: Int = 5
    @State var repetition: Int = 4
    @State var tasks: [SubTask] = []
    @State var newSubTask: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .cancel) {
                    defaultTask()
                    presentationMode.wrappedValue.dismiss()
                }
                
                Spacer()
                
                Button("Create", action: {
                    addTomaTask()
                })
            }.padding()
            
            List {
                VStack(alignment: .leading) {
                    Text("Category")
                    Picker("Category", selection: $category) {
                        ForEach(TomaTask.Category.allCases) { season in
                            Text(season.rawValue).tag(season)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading) {
                    Text("Icon")
                    Picker("Icon", selection: $status) {
                        ForEach(TomaTask.Status.allCases) { season in
                            Text(season.rawValue).tag(season)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
                
               TextField("Title", text: $title)
                    .foregroundStyle(.secondary)
                
                TextField("Description", text: $desc, axis: .vertical)
                    .lineLimit(...2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
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
                            ForEach(1..<61) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Picker("Pomodoro repetition", selection: $repetition) {
                        ForEach(1..<10) { rep in
                            Text("\(rep) \(rep == 1 ? "time" : "times")").tag(rep)
                        }
                    }
                }
                
                if(tasks.count > 0) {
                    Text("SubTasks")
                        .fontWeight(.semibold)
                    
                    ForEach(tasks) { task in
                        Text(task.text)
                            .padding(.horizontal)
                    }
                    .onDelete(perform: deleteTask)
                }
                
                HStack {
                    Button("Add subTask", action: addSubTask)
                    
                    Spacer()
                    
                    TextField("SubTask title", text: $newSubTask)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .animation(.easeInOut, value: tasks)
    }
    
    private func defaultTask () {
        title = ""
        desc = ""
        category = TomaTask.Category.study
        status = TomaTask.Status.alien
        maxDuration = 25
        pauseDuration = 5
        repetition = 4
        tasks = []
        newSubTask = ""
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
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    CreateTask()
}

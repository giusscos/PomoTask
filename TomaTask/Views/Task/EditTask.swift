//
//  CreateTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct EditTask: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var task: TomaTask
    var isNew: Bool = false
    
    @State private var title: String
    @State private var maxDuration: Int
    @State private var pauseDuration: Int
    @State private var repetition: Int
    @State private var category: TomaTask.Category
    @State private var subtaskTexts: [String]
    
    @State private var newSubTask: String = ""
    @State private var showDiscardAlert: Bool = false
    
    init(task: TomaTask, isNew: Bool = false) {
        self.task = task
        self.isNew = isNew
        _title = State(initialValue: task.title)
        _maxDuration = State(initialValue: task.maxDuration)
        _pauseDuration = State(initialValue: task.pauseDuration)
        _repetition = State(initialValue: task.repetition)
        _category = State(initialValue: task.category)
        _subtaskTexts = State(initialValue: task.unwrappedTasks.map(\.text))
    }
    
    private var hasChanges: Bool {
        title != task.title ||
        maxDuration != task.maxDuration ||
        pauseDuration != task.pauseDuration ||
        repetition != task.repetition ||
        category != task.category ||
        subtaskTexts != task.unwrappedTasks.map(\.text)
    }
    
    private var totalFocusTime: Int { maxDuration * repetition }
    private var totalBreakTime: Int { pauseDuration * repetition }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Deep Work, Morning Study…", text: $title)
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TomaTask.Category.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                }
                
                Section {
                    HorizontalRulerPicker(
                        label: "Focus",
                        unit: "min",
                        value: $maxDuration,
                        range: 1...120
                    )
                    .padding(.vertical, 12)
                    
                    HorizontalRulerPicker(
                        label: "Break",
                        unit: "min",
                        value: $pauseDuration,
                        range: 1...60
                    )
                    .padding(.vertical, 12)
                    
                    HorizontalRulerPicker(
                        label: "Repetitions",
                        unit: "×",
                        value: $repetition,
                        range: 1...20,
                        majorStep: 2,
                        itemWidth: 28
                    )
                    .padding(.vertical, 12)
                } header: {
                    Text("Duration")
                } footer: {
                    Text("Total: \(totalFocusTime) min focus + \(totalBreakTime) min break = \(totalFocusTime + totalBreakTime) min")
                }
                
                Section {
                    HStack {
                        TextField("Add a subtask…", text: $newSubTask)
                            .onSubmit(addSubTask)
                        
                        if !newSubTask.isEmpty {
                            Button(action: addSubTask) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.tint)
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    ForEach(subtaskTexts, id: \.self) { text in
                        HStack(spacing: 8) {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(text)
                        }
                    }
                    .onDelete(perform: deleteSubTask)
                } header: {
                    Text("Subtasks")
                } footer: {
                    if subtaskTexts.isEmpty {
                        Text("Optional. Add steps to follow during this timer session.")
                    }
                }
            }
            .navigationTitle(isNew ? "New Timer" : "Edit Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: handleCancel) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveChanges()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .alert(isNew ? "Discard Timer?" : "Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) {
                    if isNew {
                        modelContext.delete(task)
                    }
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text(isNew ? "This timer will not be saved." : "Your edits will be lost.")
            }
        }
        .animation(.easeInOut, value: newSubTask.isEmpty)
        .animation(.easeInOut, value: subtaskTexts.count)
    }
    
    private func handleCancel() {
        if isNew && !hasChanges {
            modelContext.delete(task)
            dismiss()
        } else if hasChanges || isNew {
            showDiscardAlert = true
        } else {
            dismiss()
        }
    }
    
    private func saveChanges() {
        if isNew {
            modelContext.insert(task)
        }
        task.title = title
        task.maxDuration = maxDuration
        task.pauseDuration = pauseDuration
        task.repetition = repetition
        task.category = category
        
        let oldSubtasks = task.tasks ?? []
        oldSubtasks.forEach { modelContext.delete($0) }
        task.tasks = subtaskTexts.map { SubTask(text: $0) }
    }
    
    private func addSubTask() {
        let trimmed = newSubTask.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        subtaskTexts.append(trimmed)
        newSubTask = ""
    }
    
    private func deleteSubTask(at offsets: IndexSet) {
        subtaskTexts.remove(atOffsets: offsets)
    }
}

#Preview {
    EditTask(task: TomaTask(), isNew: true)
}

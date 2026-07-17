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
    
    @State private var showDiscardAlert: Bool = false
    
    init(task: TomaTask, isNew: Bool = false) {
        self.task = task
        self.isNew = isNew
        _title = State(initialValue: task.title)
        _maxDuration = State(initialValue: task.maxDuration)
        _pauseDuration = State(initialValue: task.pauseDuration)
        _repetition = State(initialValue: task.repetition)
        _category = State(initialValue: task.category)
    }
    
    private var hasChanges: Bool {
        title != task.title ||
        maxDuration != task.maxDuration ||
        pauseDuration != task.pauseDuration ||
        repetition != task.repetition ||
        category != task.category
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
                            Text(cat.displayName).tag(cat)
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
                    Text("Total: \(totalFocusTime) min focus + \(totalBreakTime) min break = \(totalFocusTime + totalBreakTime) min",
                         comment: "Timer edit footer summarizing focus and break totals")
                }
                
            }
            .navigationTitle(isNew ? "New Timer" : "Edit Timer")
            .navigationBarTitleDisplayMode(.inline)
            .tint(OnboardingStyle.tomatoRed)
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
    }
}

#Preview {
    EditTask(task: TomaTask(), isNew: true)
}

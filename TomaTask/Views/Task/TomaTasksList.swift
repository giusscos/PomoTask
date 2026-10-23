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

    /// Set by `ClassicTabView` on regular width: tapping a row opens it in the detail column.
    var openedTaskID: Binding<PersistentIdentifier?>? = nil

    @State private var sheetConfig: EditSheetConfig?
    @State private var selection = Set<PersistentIdentifier>()
    @State private var editMode: EditMode = .inactive
    @State private var showDeleteConfirmation = false
    
    private var isSelecting: Bool { editMode.isEditing }
    
    private var allSelected: Bool {
        !tomaTasks.isEmpty && selection.count == tomaTasks.count
    }

    struct EditSheetConfig: Identifiable {
        let id = UUID()
        let task: TomaTask
        let isNew: Bool
    }
    
    var body: some View {
        Group {
            if tomaTasks.isEmpty {
                ContentUnavailableView {
                    Label("No Timers Yet", systemImage: "timer")
                } description: {
                    Text("Create a timer to start a focused work session with the Pomodoro technique.")
                } actions: {
                    Button(action: addTask) {
                        Label("Create Your First Timer", systemImage: "plus")
                            .font(.headline)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                // Multi-select: tap Select, drag along the circles, or two-finger swipe down the list.
                List(selection: $selection) {
                    ForEach(tomaTasks, id: \.persistentModelID) { task in
                        Group {
                            if openedTaskID != nil {
                                TaskRow(task: task)
                            } else {
                                NavigationLink {
                                    TaskView(task: task)
                                } label: {
                                    TaskRow(task: task)
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteTask(item: task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                sheetConfig = EditSheetConfig(task: task, isNew: false)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(isSelecting && !selection.isEmpty ? Text("\(selection.count) Selected") : Text("Timers"))
        .tint(OnboardingStyle.tomatoRed)
        .environment(\.editMode, $editMode)
        .animation(.default, value: isSelecting)
        .toolbar {
            if isSelecting {
                ToolbarItem(placement: .topBarLeading) {
                    Button(allSelected ? "Deselect All" : "Select All") {
                        selection = allSelected ? [] : Set(tomaTasks.map(\.persistentModelID))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { endSelection() }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(selection.isEmpty)
                    // Attached to the button so the iOS 26 popover points at the trash icon.
                    .confirmationDialog(
                        selection.count == 1 ? Text("Delete Timer?") : Text("Delete \(selection.count) Timers?"),
                        isPresented: $showDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive, action: deleteSelected)
                    } message: {
                        Text("This can’t be undone.")
                    }
                }
            } else {
                if !tomaTasks.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Select") {
                            withAnimation { editMode = .active }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addTask) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .toolbar(isSelecting ? .hidden : .automatic, for: .tabBar)
        .onChange(of: editMode) { _, mode in
            // In the split view a single selection means "opened", so start multi-select empty.
            if !mode.isEditing || openedTaskID != nil { selection.removeAll() }
        }
        .onChange(of: selection) { _, newSelection in
            guard let openedTaskID, !isSelecting, let id = newSelection.first else { return }
            openedTaskID.wrappedValue = id
        }
        .onChange(of: tomaTasks.count) { _, count in
            if count == 0 { endSelection() }
        }
        .sheet(item: $sheetConfig) { config in
            EditTask(task: config.task, isNew: config.isNew)
                .id(config.task.persistentModelID)
        }
    }
    
    private func addTask() {
        let tomatask = TomaTask()
        sheetConfig = EditSheetConfig(task: tomatask, isNew: true)
    }
    
    private func deleteTask(item: TomaTask) {
        modelContext.delete(item)
    }
    
    private func deleteSelected() {
        for task in tomaTasks where selection.contains(task.persistentModelID) {
            modelContext.delete(task)
        }
        try? modelContext.save()
        endSelection()
    }
    
    private func endSelection() {
        withAnimation {
            editMode = .inactive
            selection.removeAll()
        }
    }
}

#Preview {
    TomaTasksList()
}

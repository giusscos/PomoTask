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
    
    @State private var sheetConfig: EditSheetConfig?

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
                List {
                    ForEach(tomaTasks) { task in
                        NavigationLink {
                            TaskView(task: task)
                        } label: {
                            TaskRow(task: task)
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
        .navigationTitle("Timers")
        .tint(OnboardingStyle.tomatoRed)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: addTask) {
                    Image(systemName: "plus")
                }
            }
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
}

#Preview {
    TomaTasksList()
}

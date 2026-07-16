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
                emptyStateView
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
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "timer")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                Text("No Timers Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Create a timer to start a focused work session with the Pomodoro technique.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: addTask) {
                Label("Create Your First Timer", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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

//
//  TiimerList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import SwiftUI
import SwiftData

struct TomaTasksList: View {
    @Environment(\.modelContext) var context
    
    @Query private var tomaTasks: [TomaTask]
    
    @State private var showingProfile = false
    
    @State private var showingAddTomaTask = false
    
    var body: some View {
        NavigationSplitView {
            List {
                Button {
                    showingAddTomaTask.toggle()
                } label: {
                    Label("Add TomaTask", systemImage: "plus")
                }
                
                ForEach(tomaTasks) { task in
                    NavigationLink {
                        TomaTaskView(task: task)
                    } label: {
                        TaskRow(task: task)
                    }
                }.onDelete { indexes in
                    for index in indexes {
                        let task = tomaTasks[index]
                        deleteTask(item: task)
                    }
                }
            }
            .navigationTitle("TomaTasks")
            .toolbar {
                Button {
                    showingProfile.toggle()
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }
            .fullScreenCover(isPresented: $showingProfile, content: {
                ProfileView()
            })
            .sheet(isPresented: $showingAddTomaTask) {
                CreateTask()
            }
        } detail: {
            Text("Select a TomaTask")
        }
    }
    
    private func deleteTask(item: TomaTask) {
        context.delete(item)
    }
}

#Preview {
    TomaTasksList()
        .environment(ModelData())
}

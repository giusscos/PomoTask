//
//  TiimerList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import SwiftUI

struct TomaTaskList: View {
    @Environment(ModelData.self) var modelData
    
    var tonaTasks: [TomaTask] {
        modelData.tomaTasks
    }
    
    @State private var showingProfile = false
    
    @State private var showingAddTomaTask = false
    
    var body: some View {
        NavigationSplitView{
            List {
                Button {
                    showingAddTomaTask.toggle()
                } label: {
                    Label("Add TomaTask", systemImage: "plus")
                }
                
                ForEach(tonaTasks) { task in
                    NavigationLink {
                        TomaTaskView(task: task)
                    } label: {
                        TaskRow(task: task)
                    }
                }
            }
            .navigationTitle("TomaTasks")
            .toolbar {
                Button {
                    showingProfile.toggle()
                } label: {
                    Label("User Profile", systemImage: "person.crop.circle")
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environment(modelData)
            }
            .sheet(isPresented: $showingAddTomaTask) {
                CreateTask(cancelChange: $showingAddTomaTask)
                    .environment(modelData)
            }
        } detail: {
            Text("Select a TomaTask")
        }
    }
}

#Preview {
    TomaTaskList()
        .environment(ModelData())
}

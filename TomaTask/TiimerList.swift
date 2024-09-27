//
//  TiimerList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import SwiftUI

struct TiimerList: View {
    var body: some View {
        NavigationSplitView{
            List {
                NavigationLink {
                    CircleTimer()
                } label: {
                    HStack {
                        Text("🚀")
                            .font(.largeTitle)
                        
                        VStack (alignment: .leading) {
                            Text("TomaTask 1")
                                .font(.headline)
                            Text("Description")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("TomaTasks")
            .toolbar() {
                Button {
                    addTomaTask()
                } label: {
                    Label("Add", systemImage: "add.circle")
                }
            }
        } detail: {
            Text("Select a TomaTask")
        }
    }
    
    func addTomaTask() {
        print("Add TomaTask")
    }
}

#Preview {
    TiimerList()
}

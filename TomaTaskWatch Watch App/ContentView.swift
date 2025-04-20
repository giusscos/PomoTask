//
//  ContentView.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            WatchStatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            WatchProgressiveTimerView()
                .tabItem {
                    Label("Progressive", systemImage: "dial.medium")
                }
            
            WatchTomaTasksListView()
                .tabItem {
                    Label("Tasks", systemImage: "timer")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TomaTask.self, inMemory: true)
}

//
//  ClassicTabView.swift
//  TomaTask
//

import SwiftData
import SwiftUI

/// Classic tab root: a single stack on compact width, list + timer side by side on
/// regular width (iPhone Duo inner display, iPad).
struct ClassicTabView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query private var tomaTasks: [TomaTask]

    @State private var openedTaskID: PersistentIdentifier?

    private var openedTask: TomaTask? {
        tomaTasks.first { $0.persistentModelID == openedTaskID }
    }

    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                TomaTasksList(openedTaskID: $openedTaskID)
            } detail: {
                if let openedTask {
                    NavigationStack {
                        TaskView(task: openedTask)
                    }
                    .id(openedTask.persistentModelID)
                } else {
                    ContentUnavailableView {
                        Label("Pick a Timer", systemImage: "timer")
                    } description: {
                        Text("Choose a timer from the list to start a focus session.")
                    }
                }
            }
            .tint(OnboardingStyle.tomatoRed)
        } else {
            NavigationStack {
                TomaTasksList()
            }
        }
    }
}

#Preview {
    ClassicTabView()
}

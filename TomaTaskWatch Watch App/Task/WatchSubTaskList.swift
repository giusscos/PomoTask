//
//  WatchSubTaskList.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI
import SwiftData

struct WatchSubTaskList: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var tasks: [SubTask]
    
    var body: some View {
        List {
            ForEach(tasks, id: \.self) { task in
                Label(task.text, systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .strikethrough(task.isCompleted)
                    .onTapGesture {
                        let wasCompleted = task.isCompleted
                        task.isCompleted.toggle()
                        
                        if !wasCompleted && task.isCompleted {
                            let stats = Statistics.getDailyStats(from: Date(), context: modelContext)
                            stats.subtasksCompleted += 1
                            try? modelContext.save()
                        }
                    }
            }
        }
        .navigationTitle("Subtasks")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}


#Preview {
    WatchSubTaskList(tasks: [])
}

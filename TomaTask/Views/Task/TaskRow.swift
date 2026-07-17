//
//  TaskRow.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct TaskRow: View {
    var task: TomaTask
    
    private var totalFocusTime: Int { task.maxDuration * task.repetition }
    private var categoryEmoji: String { task.category.emoji }
    private let maxDots = 6
    
    var body: some View {
        HStack(spacing: 12) {
            Text(categoryEmoji)
                .font(.title2)
                .frame(width: 46, height: 46)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(task.title.isEmpty ? "Untitled Timer" : task.title)
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundStyle(task.title.isEmpty ? .secondary : .primary)
                    
                    Spacer()
                    
                    Text("\(totalFocusTime) min")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                }
                
                HStack(spacing: 2) {
                    ForEach(0..<min(task.repetition, maxDots), id: \.self) { _ in
                        Text("🍅")
                            .font(.system(size: 11))
                    }
                    
                    if task.repetition > maxDots {
                        Text("+\(task.repetition - maxDots)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 2)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("\(task.maxDuration)′ focus")
                        Text("·").foregroundStyle(.tertiary)
                        Text("\(task.pauseDuration)′ break")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskRow(task: TomaTask())
}

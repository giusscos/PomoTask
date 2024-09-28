//
//  TaskRow.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct TaskRow: View {
    var task: TomaTask
    
    var body: some View {
        HStack {
            Text(task.status.rawValue)
                .font(.largeTitle)
            
            VStack (alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                Text(task.desc)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    TaskRow(task: TomaTask())
}

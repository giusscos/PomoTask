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
        HStack (alignment: .lastTextBaseline) {
            HStack (alignment: .lastTextBaseline, spacing: 0) {
                Text("\(task.maxDuration)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                
                Text(" min X ")
                    .font(.headline)
                
                Text("\(task.repetition)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.accentColor)
            }
            
            Text(task.title)
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Spacer()
                
        }
    }
}

#Preview {
    TaskRow(task: TomaTask())
}

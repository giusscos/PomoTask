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
        VStack (alignment: .leading) {
            if(task.title != "") {
                Text(task.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            
            HStack (alignment: .lastTextBaseline, spacing: 0) {
                Text("\(task.maxDuration)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                    .shadow(radius: 10, y: 4)
                
                Text(" min X ")
                    .font(.headline)
                
                Text("\(task.repetition)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                    .shadow(radius: 10, y: 4)
                
                Text(" \(task.repetition == 1 ? "time" : "times")")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    TaskRow(task: TomaTask())
}

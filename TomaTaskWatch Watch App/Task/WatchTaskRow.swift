//
//  WatchTaskRow.swift
//  TomaTaskWatch Watch App
//
//  Created by Giuseppe Cosenza on 20/04/25.
//

import SwiftUI

struct WatchTaskRow: View {
    var task: TomaTask
    
    var body: some View {
        VStack(alignment: .leading) {
            if(task.title != "") {
                Text(task.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text("\(task.maxDuration)")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                
                Text(" min for ")
                    .font(.caption2)
                
                Text("\(task.repetition)")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                
                Text(" \(task.repetition == 1 ? "time" : "times")")
                    .font(.caption2)
            }
        }
    }
}


#Preview {
    WatchTaskRow(task: TomaTask())
}

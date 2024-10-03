//
//  SubTaskList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct SubTaskList: View {
    var tasks: [SubTask]
        
    var body: some View {
        List {
            Text("Sub tasks")
                .font(.title)
                .fontWeight(.semibold)
            
            ForEach(tasks, id: \.self) { task in
                HStack {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .renderingMode(.original)
                        .foregroundStyle(Color.accentColor)
                    
                    Text(task.text)
                        .strikethrough(task.isCompleted)
                }
                .disabled(task.isCompleted)
                .onTapGesture {
                    task.isCompleted.toggle()
                }
            }
        }
    }
}


#Preview {
    SubTaskList(tasks: [SubTask(text: "SubTomaTask 1", isCompleted: false)])
}

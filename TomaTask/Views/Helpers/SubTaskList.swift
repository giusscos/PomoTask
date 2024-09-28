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
            ForEach(tasks, id: \.self) { task in
                HStack {
                    Text("🚀")
                        .font(.largeTitle)
                    
                    Text(task.text)
                }
            }
        }
    }
}

#Preview {
    SubTaskList(tasks: [SubTask(text: "SubTomaTask 1", isCompleted: true)])
}

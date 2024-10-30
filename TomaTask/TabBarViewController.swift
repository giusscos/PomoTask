//
//  TabBarViewController.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 22/10/24.
//

import SwiftUI

struct TabBarViewController: View {    
    var body: some View {
        TabView {
            Tab("Progressive", systemImage: "dial.medium") {
                NavigationStack {
                    ProgressiveTimerList()
                }
            }
            
            Tab("Classic", systemImage: "timer") {
                NavigationStack {
                    TomaTasksList()
                }
            }
        }
    }
}

#Preview {
    TabBarViewController()
}

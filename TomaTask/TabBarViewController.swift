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
                ProgressiveTimer()
            }

            Tab("Classic", systemImage: "timer") {
                TimerController()
            }            
        }
    }
}

#Preview {
    TabBarViewController()
}

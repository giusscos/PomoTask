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
            Tab("Timers", systemImage: "timer") {
                TimerController()
            }
            
            Tab("Progressive Timer", systemImage: "dial.medium") {
                Text("Progressive timer available soon!")
                    .bold()
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    TabBarViewController()
}

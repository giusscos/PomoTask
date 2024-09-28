//
//  ContentView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 25/09/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TomaTasksList()
    }
}

#Preview {
    ContentView()
        .environment(ModelData(tomaTasks: [TomaTask()], profile: Profile()))
}

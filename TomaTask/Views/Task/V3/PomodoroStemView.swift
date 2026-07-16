//
//  PomodoroStemView.swift
//  TomaTask
//

import SwiftUI

/// Full-width green tomato stem, oriented with the nub up behind the Dynamic Island.
struct PomodoroStemView: View {
    var body: some View {
        Image("tomato_stem")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

#Preview {
    GeometryReader { geo in
        ZStack(alignment: .top) {
            Color(red: 0.86, green: 0.15, blue: 0.15)
                .ignoresSafeArea()
            PomodoroStemView()
                // Pull up so the stem sits behind the Dynamic Island.
                .offset(y: -geo.size.width * 0.14)
        }
        .ignoresSafeArea(edges: .top)
    }
}

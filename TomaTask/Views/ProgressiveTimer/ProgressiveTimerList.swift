//
//  ProgressiveTimerList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 29/10/24.
//

import SwiftUI

struct ProgressiveTimerList: View {
    @Namespace private var namespace
    
    @State private var colorSets: [(Color, Color, Color)] = [
        (.black, .red, .orange),
        (.black, .green, .blue),
        (.black, .yellow, .purple),
        (.black, .indigo, .pink)
    ]
    
    var body: some View {
        ScrollView {
            ForEach(0..<colorSets.count, id: \.self) { index in
                let colors = colorSets[index]
                
                NavigationLink {
                    ProgressiveTimerView(meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                        .navigationTransition(.zoom(sourceID: index, in: namespace))
                } label: {
                    ProgressiveTimerRow(isLocked: index != 0, meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.3)
                }
                .disabled(index != 0)
                .matchedTransitionSource(id: index, in: namespace)
                .buttonStyle(PlainButtonStyle())
            }
        }.padding(.horizontal)
    }
}

#Preview {
    ProgressiveTimerList()
}

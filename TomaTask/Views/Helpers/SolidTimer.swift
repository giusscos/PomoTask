//
//  CircleTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import SwiftUI

struct SolidTimer: View {
    var heigth: CGFloat
    var color: Color = .red
        
    var body: some View {
            Rectangle()
                .overlay(content: {
                    color
                        .scaleEffect(y: heigth / screenSize, anchor: .bottom)
                        .background(.background)
                })
                .clipped()
                .animation(.linear(duration: 2), value: heigth)
                .ignoresSafeArea(.all)
    }
}

#Preview {
    SolidTimer(heigth: screenSize, color: .blue)
}

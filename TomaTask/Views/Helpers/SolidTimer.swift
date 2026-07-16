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
    
    /// Keeps the “empty” area in the same light/dark family as the fill,
    /// so chrome and labels never sit on a sudden system white/black flash.
    private var stableBase: Color {
        color.isLight ? Color.white : Color.black
    }
        
    var body: some View {
        Rectangle()
            .overlay {
                ZStack(alignment: .bottom) {
                    stableBase
                    
                    color
                        .frame(height: max(0, heigth))
                }
            }
            .clipped()
            .animation(.linear(duration: 1), value: heigth)
            .ignoresSafeArea(.all)
    }
}

#Preview {
    SolidTimer(heigth: screenSize, color: .blue)
}

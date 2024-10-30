//
//  ProgressiveTimerRow.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 30/10/24.
//

import SwiftUI

struct ProgressiveTimerRow: View {
    var isLocked: Bool
    
    var meshColor1: Color
    var meshColor2: Color
    var meshColor3: Color
    
    @State private var meshValue1 = Float.random(in: 0.5...0.7)
    @State private var meshValue2 = Float.random(in: 0.4...0.8)
    
    var body: some View {
        ZStack {
            Rectangle()
                .overlay {
                    MeshGradient(
                        width: 3,
                        height: 4,
                        points: [
                            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                            [0.0, 0.3], [meshValue1, 0.4], [1.0, 0.3],
                            [0.0, 0.6], [0.5, meshValue2], [1.0, 0.6],
                            [0.0, 1], [0.5, 1], [1.0, 1]
                        ],
                        colors: [
                            meshColor1, meshColor1, meshColor1,
                            meshColor3, meshColor3, meshColor3,
                            meshColor2, meshColor2, meshColor2,
                            meshColor1, meshColor1, meshColor1,
                        ],
                        smoothsColors: true,
                        colorSpace: .perceptual
                    )
                    //                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: remainingTime)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.largeTitle)
                    .shadow(radius: 10, x: 0, y: 4)
                    .padding()
                    .foregroundStyle(.ultraThinMaterial)
            }
        }
    }
}

#Preview {
    ProgressiveTimerRow(isLocked: true, meshColor1: .black, meshColor2: .red, meshColor3: .orange)
}

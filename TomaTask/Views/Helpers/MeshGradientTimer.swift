//
//  MeshGradientTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 31/10/24.
//

import SwiftUI

struct MeshGradientTimer: View {
    var meshValue1 = Float.random(in: 0.5...0.7)
    var meshValue2 = Float.random(in: 0.4...0.8)
    
    var time: Double? = 0
    
    var meshColor1: Color
    var meshColor2: Color
    var meshColor3: Color
    
    var body: some View {
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
            }
            .ignoresSafeArea(.all)
            .animation(.easeInOut(duration: 2).repeatForever(), value: time)
    }
}

#Preview {
    MeshGradientTimer(time: 30, meshColor1: .black, meshColor2: .red, meshColor3: .orange)
}

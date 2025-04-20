//
//  MeshGradientTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 31/10/24.
//

import SwiftUI

struct MeshGradientTimer: View {
    var time: Double? = 0
    
    // Animation parameters
    private let breathingDuration: Double = 4.0
    private let minScale: Float = 0.4
    private let maxScale: Float = 0.8
    
    var meshColor1: Color
    var meshColor2: Color
    var meshColor3: Color
    
    private var breathingProgress: Float {
        guard let time = time else { return 0.5 }
        
        // Calculate the current cycle position
        let cycle = time.truncatingRemainder(dividingBy: breathingDuration)
        let progress = cycle / breathingDuration
        
        // Calculate the sine wave value
        let sineValue = sin(progress * .pi * 2)
        let normalizedSine = (sineValue + 1) / 2
        
        // Calculate the final scale value
        let scaleRange = maxScale - minScale
        return minScale + (scaleRange * Float(normalizedSine))
    }
    
    var body: some View {
        Rectangle()
            .overlay {
                MeshGradient(
                    width: 3,
                    height: 4,
                    points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.3], [breathingProgress, 0.4], [1.0, 0.3],
                        [0.0, 0.6], [0.5, breathingProgress], [1.0, 0.6],
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
            .animation(.easeInOut(duration: 5), value: time)
    }
}

#Preview {
    MeshGradientTimer(time: 30, meshColor1: .black, meshColor2: .red, meshColor3: .orange)
}

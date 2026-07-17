import SwiftUI

/// Seeded RNG so splash silhouettes stay stable per day.
struct SeededGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    mutating func nextDouble() -> Double {
        Double(next() % 10_000) / 10_000
    }

    mutating func nextCGFloat(in range: ClosedRange<CGFloat>) -> CGFloat {
        range.lowerBound + CGFloat(nextDouble()) * (range.upperBound - range.lowerBound)
    }
}

/// Liquid splat: ragged body + radial tendrils + satellite droplets.
struct TomatoSplashShape: Shape {
    var seed: UInt64
    /// 0 = tight blot, 1 = wide explosive splash.
    var explosiveness: CGFloat = 0.85

    func path(in rect: CGRect) -> Path {
        var rng = SeededGenerator(seed: seed)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let minSide = min(rect.width, rect.height)
        let baseRadius = minSide * 0.28

        var path = Path()

        // Core body with deep cusps between lobes (reads as wet splash, not polygon).
        let lobes = 9 + Int(rng.next() % 4)
        var bodyPoints: [CGPoint] = []
        for i in 0..<lobes {
            let t = Double(i) / Double(lobes)
            let angle = t * .pi * 2 - .pi / 2
            let spike = rng.nextDouble() > 0.55
            let radiusFactor: Double = spike
                ? (0.95 + rng.nextDouble() * 0.85 * Double(explosiveness))
                : (0.55 + rng.nextDouble() * 0.35)
            let radius = baseRadius * radiusFactor
            let jitter = (rng.nextDouble() - 0.5) * 0.28
            bodyPoints.append(
                CGPoint(
                    x: center.x + CGFloat(cos(angle + jitter)) * radius,
                    y: center.y + CGFloat(sin(angle + jitter)) * radius
                )
            )
        }

        if let first = bodyPoints.first {
            path.move(to: first)
            for i in 0..<bodyPoints.count {
                let current = bodyPoints[i]
                let next = bodyPoints[(i + 1) % bodyPoints.count]
                let mid = CGPoint(x: (current.x + next.x) / 2, y: (current.y + next.y) / 2)
                // Pull control toward center for cusps between lobes.
                let pull = 0.35 + rng.nextDouble() * 0.35
                let control = CGPoint(
                    x: mid.x + (center.x - mid.x) * pull,
                    y: mid.y + (center.y - mid.y) * pull
                )
                path.addQuadCurve(to: next, control: control)
            }
            path.closeSubpath()
        }

        // Radial tendrils (drips / spray lines).
        let tendrilCount = 4 + Int(rng.next() % 4)
        for _ in 0..<tendrilCount {
            let angle = rng.nextDouble() * .pi * 2
            let startR = baseRadius * (0.55 + rng.nextDouble() * 0.25)
            let length = baseRadius * (0.45 + rng.nextDouble() * 0.9) * explosiveness
            let width = baseRadius * (0.08 + rng.nextDouble() * 0.12)
            let tipAngle = angle + (rng.nextDouble() - 0.5) * 0.4

            let start = CGPoint(
                x: center.x + CGFloat(cos(angle)) * startR,
                y: center.y + CGFloat(sin(angle)) * startR
            )
            let tip = CGPoint(
                x: center.x + CGFloat(cos(tipAngle)) * (startR + length),
                y: center.y + CGFloat(sin(tipAngle)) * (startR + length)
            )
            let perp = CGPoint(x: -sin(angle), y: cos(angle))
            let left = CGPoint(x: start.x + perp.x * width, y: start.y + perp.y * width)
            let right = CGPoint(x: start.x - perp.x * width, y: start.y - perp.y * width)

            path.move(to: left)
            path.addLine(to: tip)
            path.addLine(to: right)
            path.closeSubpath()

            // Tip droplet
            let dropR = width * (0.9 + CGFloat(rng.nextDouble()) * 0.6)
            path.addEllipse(in: CGRect(
                x: tip.x - dropR,
                y: tip.y - dropR,
                width: dropR * 2,
                height: dropR * 2
            ))
        }

        // Satellite droplets around the splash.
        let dropletCount = 5 + Int(rng.next() % 5)
        for _ in 0..<dropletCount {
            let angle = rng.nextDouble() * .pi * 2
            let dist = baseRadius * (1.05 + rng.nextDouble() * 0.95) * explosiveness
            let dropW = baseRadius * (0.12 + rng.nextDouble() * 0.22)
            let dropH = dropW * (0.7 + CGFloat(rng.nextDouble()) * 0.6)
            let cx = center.x + CGFloat(cos(angle)) * dist
            let cy = center.y + CGFloat(sin(angle)) * dist
            path.addEllipse(in: CGRect(x: cx - dropW / 2, y: cy - dropH / 2, width: dropW, height: dropH))
        }

        return path
    }
}

/// Composite splash with wet highlight and layered fill.
struct LiquidTomatoSplash: View {
    let seed: UInt64
    let color: Color
    var size: CGFloat = 36
    var explosiveness: CGFloat = 0.9
    var showHighlight: Bool = true

    var body: some View {
        ZStack {
            // Soft under-glow (juice stain)
            TomatoSplashShape(seed: seed &+ 3, explosiveness: explosiveness * 0.7)
                .fill(color.opacity(0.28))
                .frame(width: size * 1.25, height: size * 1.25)
                .blur(radius: 1.2)

            TomatoSplashShape(seed: seed, explosiveness: explosiveness)
                .fill(color)
                .frame(width: size, height: size)

            if showHighlight {
                Ellipse()
                    .fill(Color.white.opacity(0.28))
                    .frame(width: size * 0.28, height: size * 0.16)
                    .offset(x: -size * 0.12, y: -size * 0.14)
                    .rotationEffect(.degrees(-18))
            }
        }
        .frame(width: size * 1.35, height: size * 1.35)
        .shadow(color: color.opacity(0.35), radius: 2, y: 1)
    }
}

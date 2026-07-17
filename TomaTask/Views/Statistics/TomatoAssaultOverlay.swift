import SwiftUI
import UIKit

// MARK: - Preference keys

struct DayCellFrame: Equatable {
    let date: Date
    let focusSeconds: TimeInterval
    let frame: CGRect
}

struct DayCellFramesKey: PreferenceKey {
    static var defaultValue: [DayCellFrame] = []

    static func reduce(value: inout [DayCellFrame], nextValue: () -> [DayCellFrame]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - UIKit throw + gravity stage

/// Launches tomatoes at calendar cells, then drops debris with UIKit gravity.
struct TomatoAssaultOverlay: UIViewRepresentable {
    var targets: [DayCellFrame]
    var pileHeight: CGFloat
    var animationToken: Int
    var onImpact: (Date) -> Void
    var onFinished: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> TomatoAssaultView {
        let view = TomatoAssaultView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: TomatoAssaultView, context: Context) {
        uiView.onImpact = onImpact
        uiView.onFinished = onFinished

        let bounds = uiView.bounds
        guard bounds.width > 1, bounds.height > 1 else { return }

        // Only (re)play when the calendar intentionally bumps `animationToken`
        // (appear / month change). Frame and bounds jitter from scrolling must
        // not restart the throw sequence.
        guard animationToken != context.coordinator.lastPlayedToken else { return }

        let validTargets = targets.filter { $0.focusSeconds > 0 && $0.frame.width > 1 }
        guard !validTargets.isEmpty else { return }

        context.coordinator.lastPlayedToken = animationToken

        DispatchQueue.main.async {
            guard uiView.bounds.width > 1 else { return }
            uiView.play(
                targets: validTargets,
                stageBounds: uiView.bounds,
                pileHeight: pileHeight
            )
        }
    }

    final class Coordinator {
        var lastPlayedToken: Int = -1
    }
}

final class TomatoAssaultView: UIView {
    var onImpact: ((Date) -> Void)?
    var onFinished: (() -> Void)?

    private var animator: UIDynamicAnimator?
    private var gravity: UIGravityBehavior?
    private var collision: UICollisionBehavior?
    private var itemBehavior: UIDynamicItemBehavior?
    private var flyingLayers: [CALayer] = []
    private var debrisViews: [UIView] = []
    private var playGeneration = 0

    private let tomatoRed = UIColor(red: 0.86, green: 0.14, blue: 0.14, alpha: 1)
    private let tomatoCoral = UIColor(red: 0.92, green: 0.38, blue: 0.36, alpha: 1)
    private let stemGreen = UIColor(red: 0.35, green: 0.55, blue: 0.28, alpha: 1)

    func play(targets: [DayCellFrame], stageBounds: CGRect, pileHeight: CGFloat) {
        playGeneration += 1
        let generation = playGeneration
        resetPhysics()

        let sorted = targets
            .filter { $0.focusSeconds > 0 && $0.frame.width > 1 }
            .sorted { $0.date < $1.date }
        guard !sorted.isEmpty else {
            onFinished?()
            return
        }

        let launchOrigin = CGPoint(
            x: stageBounds.midX,
            y: min(stageBounds.maxY - 20, stageBounds.maxY - pileHeight * 0.25)
        )

        for (index, target) in sorted.enumerated() {
            let delay = 0.08 + Double(index) * 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self, self.playGeneration == generation else { return }
                self.launchTomato(
                    toward: target,
                    from: launchOrigin,
                    stageBounds: stageBounds,
                    pileHeight: pileHeight,
                    index: index
                )
            }
        }

        let finishDelay = 0.08 + Double(sorted.count) * 0.2 + 1.4
        DispatchQueue.main.asyncAfter(deadline: .now() + finishDelay) { [weak self] in
            guard let self, self.playGeneration == generation else { return }
            self.onFinished?()
        }
    }

    private func launchTomato(
        toward target: DayCellFrame,
        from origin: CGPoint,
        stageBounds: CGRect,
        pileHeight: CGFloat,
        index: Int
    ) {
        let tomatoSize: CGFloat = 30
        let tomato = makeTomatoLayer(size: tomatoSize, seed: index)
        tomato.position = origin
        layer.addSublayer(tomato)
        flyingLayers.append(tomato)

        let end = CGPoint(x: target.frame.midX, y: target.frame.midY)
        let control = CGPoint(
            x: (origin.x + end.x) / 2 + CGFloat((index % 2 == 0) ? -48 : 48),
            y: min(origin.y, end.y) - 100 - CGFloat(index % 3) * 14
        )

        let path = UIBezierPath()
        path.move(to: origin)
        path.addQuadCurve(to: end, controlPoint: control)

        let flight = CAKeyframeAnimation(keyPath: "position")
        flight.path = path.cgPath
        flight.duration = 0.5
        flight.timingFunction = CAMediaTimingFunction(name: .easeIn)
        flight.fillMode = .forwards
        flight.isRemovedOnCompletion = false

        let spin = CABasicAnimation(keyPath: "transform.rotation.z")
        spin.fromValue = 0
        spin.toValue = Double.pi * (index % 2 == 0 ? 2.4 : -2.6)
        spin.duration = flight.duration

        let group = CAAnimationGroup()
        group.animations = [flight, spin]
        group.duration = flight.duration
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self, weak tomato] in
            tomato?.removeFromSuperlayer()
            self?.flyingLayers.removeAll { $0 === tomato }
            self?.impact(
                at: end,
                date: target.date,
                focusSeconds: target.focusSeconds,
                stageBounds: stageBounds,
                pileHeight: pileHeight,
                index: index
            )
        }
        tomato.add(group, forKey: "throw")
        CATransaction.commit()
    }

    private func impact(
        at point: CGPoint,
        date: Date,
        focusSeconds: TimeInterval,
        stageBounds: CGRect,
        pileHeight: CGFloat,
        index: Int
    ) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onImpact?(date)

        spawnDebris(
            from: point,
            stageBounds: stageBounds,
            pileHeight: pileHeight,
            focusSeconds: focusSeconds,
            index: index
        )
    }

    private func spawnDebris(
        from point: CGPoint,
        stageBounds: CGRect,
        pileHeight: CGFloat,
        focusSeconds: TimeInterval,
        index: Int
    ) {
        ensurePhysics(stageBounds: stageBounds, pileHeight: pileHeight)

        let intensity = CGFloat(min(1, max(0.25, focusSeconds / (90 * 60))))
        let count = 2 + (intensity > 0.55 ? 2 : 1)

        for piece in 0..<count {
            let size = CGFloat(18 + (piece * 5) + (index % 3) * 3)
            let debris = makeSplashDebrisView(size: size, seed: index * 17 + piece, intensity: intensity)
            debris.center = CGPoint(
                x: point.x + CGFloat(piece - 1) * 10,
                y: point.y + 6
            )
            addSubview(debris)
            debrisViews.append(debris)

            gravity?.addItem(debris)
            collision?.addItem(debris)
            itemBehavior?.addItem(debris)

            let dx = CGFloat((piece % 2 == 0) ? -1 : 1) * CGFloat(50 + piece * 28)
            let dy = CGFloat(-140 - piece * 35)
            itemBehavior?.addLinearVelocity(CGPoint(x: dx, y: dy), for: debris)
            itemBehavior?.addAngularVelocity(CGFloat((piece % 2 == 0) ? 7 : -8), for: debris)
        }
    }

    private func ensurePhysics(stageBounds: CGRect, pileHeight: CGFloat) {
        if animator == nil {
            animator = UIDynamicAnimator(referenceView: self)
        }
        if gravity == nil {
            let g = UIGravityBehavior()
            g.magnitude = 1.4
            gravity = g
            animator?.addBehavior(g)
        }
        if collision == nil {
            let c = UICollisionBehavior()
            c.translatesReferenceBoundsIntoBoundary = false
            let floorY = max(stageBounds.midY, stageBounds.maxY - max(12, pileHeight * 0.2))
            c.addBoundary(
                withIdentifier: "floor" as NSString,
                from: CGPoint(x: stageBounds.minX + 2, y: floorY),
                to: CGPoint(x: stageBounds.maxX - 2, y: floorY)
            )
            c.addBoundary(
                withIdentifier: "left" as NSString,
                from: CGPoint(x: stageBounds.minX + 4, y: stageBounds.minY),
                to: CGPoint(x: stageBounds.minX + 4, y: floorY)
            )
            c.addBoundary(
                withIdentifier: "right" as NSString,
                from: CGPoint(x: stageBounds.maxX - 4, y: stageBounds.minY),
                to: CGPoint(x: stageBounds.maxX - 4, y: floorY)
            )
            collision = c
            animator?.addBehavior(c)
        }
        if itemBehavior == nil {
            let i = UIDynamicItemBehavior()
            i.elasticity = 0.3
            i.friction = 0.6
            i.resistance = 0.3
            i.allowsRotation = true
            itemBehavior = i
            animator?.addBehavior(i)
        }
    }

    private func resetPhysics() {
        flyingLayers.forEach { $0.removeFromSuperlayer() }
        flyingLayers.removeAll()
        debrisViews.forEach { $0.removeFromSuperview() }
        debrisViews.removeAll()
        animator?.removeAllBehaviors()
        gravity = nil
        collision = nil
        itemBehavior = nil
        animator = nil
    }

    private func makeTomatoLayer(size: CGFloat, seed: Int) -> CALayer {
        let container = CALayer()
        container.bounds = CGRect(x: 0, y: 0, width: size, height: size)

        let body = CAShapeLayer()
        body.path = UIBezierPath(ovalIn: CGRect(x: 2, y: 4, width: size - 4, height: size - 6)).cgPath
        body.fillColor = (seed % 2 == 0 ? tomatoRed : tomatoCoral).cgColor
        body.shadowColor = tomatoRed.cgColor
        body.shadowOpacity = 0.35
        body.shadowRadius = 2
        body.shadowOffset = CGSize(width: 0, height: 1)
        container.addSublayer(body)

        let stem = CAShapeLayer()
        stem.path = UIBezierPath(
            roundedRect: CGRect(x: size * 0.45, y: 0, width: size * 0.12, height: size * 0.28),
            cornerRadius: 2
        ).cgPath
        stem.fillColor = stemGreen.cgColor
        stem.transform = CATransform3DMakeRotation(.pi / 10, 0, 0, 1)
        container.addSublayer(stem)

        let gloss = CAShapeLayer()
        gloss.path = UIBezierPath(
            ovalIn: CGRect(x: size * 0.28, y: size * 0.28, width: size * 0.22, height: size * 0.14)
        ).cgPath
        gloss.fillColor = UIColor.white.withAlphaComponent(0.35).cgColor
        container.addSublayer(gloss)

        return container
    }

    private func makeSplashDebrisView(size: CGFloat, seed: Int, intensity: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size * 0.75))
        view.backgroundColor = .clear

        let shape = CAShapeLayer()
        shape.path = splashPath(in: view.bounds, seed: UInt64(seed + 99))
        let color = intensity > 0.7 ? tomatoRed : tomatoCoral
        shape.fillColor = color.withAlphaComponent(0.92).cgColor
        view.layer.addSublayer(shape)
        return view
    }

    private func splashPath(in rect: CGRect, seed: UInt64) -> CGPath {
        var rng = SeededGenerator(seed: seed)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let base = min(rect.width, rect.height) * 0.32
        let lobes = 8
        let path = UIBezierPath()

        for i in 0..<lobes {
            let angle = (Double(i) / Double(lobes)) * .pi * 2
            let r = base * (0.55 + rng.nextDouble() * 0.9)
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * r,
                y: center.y + CGFloat(sin(angle)) * r
            )
            if i == 0 {
                path.move(to: point)
            } else {
                let prevAngle = (Double(i - 1) / Double(lobes)) * .pi * 2
                let midAngle = (prevAngle + angle) / 2
                let pull = base * (0.25 + rng.nextDouble() * 0.25)
                let control = CGPoint(
                    x: center.x + CGFloat(cos(midAngle)) * pull,
                    y: center.y + CGFloat(sin(midAngle)) * pull
                )
                path.addQuadCurve(to: point, controlPoint: control)
            }
        }
        path.close()

        for _ in 0..<4 {
            let a = rng.nextDouble() * .pi * 2
            let dist = base * (1.1 + rng.nextDouble() * 0.7)
            let drop = base * (0.15 + rng.nextDouble() * 0.2)
            let cx = center.x + CGFloat(cos(a)) * dist
            let cy = center.y + CGFloat(sin(a)) * dist
            path.append(UIBezierPath(ovalIn: CGRect(x: cx - drop, y: cy - drop, width: drop * 2, height: drop * 2)))
        }

        return path.cgPath
    }
}

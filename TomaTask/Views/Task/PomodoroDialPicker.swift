//
//  PomodoroDialPicker.swift
//  TomaTask
//

import SwiftUI

/// Tomato-timer dial: fixed center indicator, scale unwinds toward 0 as time elapses.
/// Drag when idle to wind; dragging fully back resets via `onWind`.
struct PomodoroDialPicker: View {
    /// mm:ss string to display above the ruler (e.g. "25:00"). Shown instead of the minutes-only label.
    var formattedTime: String = ""
    /// Remaining minutes (fractional while running for smooth rotation).
    var remainingMinutes: Double
    /// Max minutes on the dial for this phase.
    var maxMinutes: Int
    var isInteractive: Bool
    var onWind: (Int) -> Void
    
    var itemWidth: CGFloat = 28
    var majorStep: Int = 5
    
    @State private var dragStartMinutes: Double = 0
    @State private var dragTranslation: CGFloat = 0
    @State private var isDragging = false
    
    private var range: ClosedRange<Int> { 0...max(1, maxMinutes) }
    
    private var displayedMinutes: Double {
        if isDragging {
            return snappedMinutes
        }
        return max(0, min(Double(maxMinutes), remainingMinutes))
    }
    
    private var rulerOffset: CGFloat {
        if isDragging {
            let maxShift = CGFloat(dragStartMinutes - Double(range.lowerBound)) * itemWidth
            let minShift = -CGFloat(Double(range.upperBound) - dragStartMinutes) * itemWidth
            return max(minShift, min(maxShift, dragTranslation))
        }
        // Resting: pin current remaining minutes under the center triangle.
        return 0
    }
    
    private var snappedMinutes: Double {
        let shift = -dragTranslation / itemWidth
        let raw = dragStartMinutes + shift
        return max(Double(range.lowerBound), min(Double(range.upperBound), raw))
    }
    
    private var snappedInt: Int {
        Int(snappedMinutes.rounded())
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(formattedTime.isEmpty ? String(format: "%02d:00", Int(displayedMinutes.rounded(.down))) : formattedTime)
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.2), value: remainingMinutes)
                .foregroundStyle(.white)
            
            ZStack(alignment: .top) {
                Canvas { ctx, size in
                    drawRuler(ctx: ctx, size: size)
                }
                .frame(height: 80)
                .animation(isDragging ? nil : .linear(duration: 0.1), value: remainingMinutes)
                
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(y: 0)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
            }
            .frame(height: 80)
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.1),
                        .init(color: .black, location: 0.9),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .contentShape(Rectangle())
            .gesture(isInteractive ? dragGesture : nil)
            .accessibilityLabel("Timer dial")
            .accessibilityValue("\(Int(displayedMinutes.rounded())) minutes remaining")
            .accessibilityHint(isInteractive ? "Drag to wind or reset the timer" : "Running")
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { g in
                if !isDragging {
                    isDragging = true
                    dragStartMinutes = remainingMinutes
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
                dragTranslation = g.translation.width
                let new = snappedInt
                let currentShown = Int(remainingMinutes.rounded())
                if new != currentShown {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { _ in
                let final = snappedInt
                onWind(final)
                dragStartMinutes = Double(final)
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                    dragTranslation = 0
                    isDragging = false
                }
            }
    }
    
    private func drawRuler(ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let valueAtCenter = isDragging ? dragStartMinutes : displayedMinutes
        let anchorX = centerX + rulerOffset
        
        // Extend drawing range beyond the actual bounds so the ruler looks continuous
        let extraTicks = Int(size.width / itemWidth) + 4
        let drawStart = range.lowerBound - extraTicks
        let drawEnd = range.upperBound + extraTicks
        
        for i in drawStart...drawEnd {
            let xPos = anchorX + (CGFloat(i) - CGFloat(valueAtCenter)) * itemWidth
            guard xPos >= -itemWidth * 2, xPos <= size.width + itemWidth * 2 else { continue }
            
            let inRange = i >= range.lowerBound && i <= range.upperBound
            let isMajor = i % majorStep == 0
            let tickTop: CGFloat = 16
            let tickHeight: CGFloat = isMajor ? 34 : 16
            let opacity: Double = inRange
                ? (isMajor ? 0.95 : 0.35)
                : (isMajor ? 0.28 : 0.12)
            
            var path = Path()
            path.move(to: CGPoint(x: xPos, y: tickTop))
            path.addLine(to: CGPoint(x: xPos, y: tickTop + tickHeight))
            ctx.stroke(
                path,
                with: .color(.white.opacity(opacity)),
                lineWidth: isMajor ? 2.5 : 1.2
            )
            
            if isMajor && inRange {
                ctx.draw(
                    Text("\(i)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9)),
                    at: CGPoint(x: xPos, y: tickTop + tickHeight + 4),
                    anchor: .top
                )
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.86, green: 0.15, blue: 0.15).ignoresSafeArea()
        PomodoroDialPicker(
            remainingMinutes: 25,
            maxMinutes: 25,
            isInteractive: true,
            onWind: { _ in }
        )
        .padding()
    }
}

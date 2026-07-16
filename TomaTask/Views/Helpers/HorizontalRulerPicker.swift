//
//  HorizontalRulerPicker.swift
//  TomaTask
//

import SwiftUI

struct HorizontalRulerPicker: View {
    let label: String
    let unit: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var majorStep: Int = 5
    var itemWidth: CGFloat = 20

    @State private var dragStartValue: Int = 0
    @State private var dragTranslation: CGFloat = 0
    @State private var isDragging: Bool = false

    // Ruler position: how far the ruler has shifted from its resting position
    private var rulerOffset: CGFloat {
        let maxShift = CGFloat(dragStartValue - range.lowerBound) * itemWidth
        let minShift = -CGFloat(range.upperBound - dragStartValue) * itemWidth
        return max(minShift, min(maxShift, dragTranslation))
    }

    // The value that sits at the center indicator given the current offset
    private var snappedValue: Int {
        let shift = -rulerOffset / itemWidth
        return max(range.lowerBound, min(range.upperBound, dragStartValue + Int(shift.rounded())))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text("\(value)")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.tint)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.15), value: value)

                Text(unit)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 8)

            ZStack(alignment: .top) {
                Canvas { ctx, size in
                    drawRuler(ctx: ctx, size: size)
                }
                .frame(height: 50)

                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.tint)
                    .offset(y: 2)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 50)
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.12),
                        .init(color: .black, location: 0.88),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .contentShape(Rectangle())
            .gesture(dragGesture)

            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .kerning(0.8)
                .padding(.top, 6)
        }
        .onAppear { dragStartValue = value }
        .onChange(of: value) { _, newVal in
            if !isDragging { dragStartValue = newVal }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { g in
                if !isDragging {
                    isDragging = true
                    dragStartValue = value
                }
                dragTranslation = g.translation.width
                let new = snappedValue
                if new != value {
                    value = new
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { _ in
                let final = snappedValue
                value = final
                dragStartValue = final
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                    dragTranslation = 0
                    isDragging = false
                }
            }
    }

    private func drawRuler(ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let anchorX = centerX + rulerOffset

        for i in range {
            let xPos = anchorX + CGFloat(i - dragStartValue) * itemWidth
            guard xPos >= -itemWidth * 3, xPos <= size.width + itemWidth * 3 else { continue }

            let isMajor = i % majorStep == 0 || i == range.lowerBound || i == range.upperBound
            let tickTop: CGFloat = 10
            let tickHeight: CGFloat = isMajor ? 22 : 10

            var path = Path()
            path.move(to: CGPoint(x: xPos, y: tickTop))
            path.addLine(to: CGPoint(x: xPos, y: tickTop + tickHeight))
            ctx.stroke(
                path,
                with: .color(.primary.opacity(isMajor ? 0.5 : 0.18)),
                lineWidth: isMajor ? 2 : 1
            )

            if isMajor {
                ctx.draw(
                    Text("\(i)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary),
                    at: CGPoint(x: xPos, y: tickTop + tickHeight + 3),
                    anchor: .top
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var focus = 25
    @Previewable @State var pause = 5
    @Previewable @State var reps = 4

    VStack(spacing: 0) {
        HorizontalRulerPicker(label: "Focus", unit: "min", value: $focus, range: 1...120)
            .padding(.vertical, 16)
        Divider()
        HorizontalRulerPicker(label: "Break", unit: "min", value: $pause, range: 1...60)
            .padding(.vertical, 16)
        Divider()
        HorizontalRulerPicker(label: "Repetitions", unit: "×", value: $reps, range: 1...20, majorStep: 2, itemWidth: 28)
            .padding(.vertical, 16)
    }
    .padding(.horizontal)
}

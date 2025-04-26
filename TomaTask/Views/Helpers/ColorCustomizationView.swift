//
//  ColorCustomizationView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 15/04/25.
//

import SwiftUI

struct ColorCustomizationView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var meshColor1: Color
    @Binding var meshColor2: Color
    @Binding var meshColor3: Color

    @Binding var colorMode: ProgressiveTimerView.ColorMode
    
    var isSubscribed: Bool
    var onColorChange: () -> Void
    
    @State private var selectedColorIndex = 0
    @State private var hue: Double = 0
    @State private var saturation: Double = 0
    @State private var brightness: Double = 1
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Picker("Color type", selection: $colorMode) {
                    Text("Solid Color").tag(ProgressiveTimerView.ColorMode.solid)
                    if isSubscribed {
                        Text("Gradient").tag(ProgressiveTimerView.ColorMode.mesh)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .disabled(!isSubscribed)
                .onChange(of: colorMode) { _, _ in
                    onColorChange()
                }
                
                if colorMode == .mesh && isSubscribed {
                    Picker("Select Color", selection: $selectedColorIndex) {
                        Text("Color 1").tag(0)
                        Text("Color 2").tag(1)
                        Text("Color 3").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedColorIndex) { _, _ in
                        initializeValues()
                    }
                }
                
                VStack(spacing: 30) {
                    // Hue Slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                LinearGradient(gradient: Gradient(colors: [
                                    .red, .yellow, .green, .blue, .purple, .red
                                ]), startPoint: .leading, endPoint: .trailing)
                                .frame(height: 24)
                                .clipShape(Capsule())
                                
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .shadow(radius: 2)
                                    .offset(x: (geometry.size.width - 24) * hue)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newValue = value.location.x / geometry.size.width
                                                hue = max(0, min(1, newValue))
                                                updateSelectedColor()
                                            }
                                    )
                            }
                        }
                        .frame(height: 24)
                    }
                    
                    // Saturation Slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Saturation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                LinearGradient(gradient: Gradient(colors: [
                                    .white, Color(hue: hue, saturation: 1, brightness: brightness)
                                ]), startPoint: .leading, endPoint: .trailing)
                                .frame(height: 24)
                                .clipShape(Capsule())
                                
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .shadow(radius: 2)
                                    .offset(x: (geometry.size.width - 24) * saturation)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newValue = value.location.x / geometry.size.width
                                                saturation = max(0, min(1, newValue))
                                                updateSelectedColor()
                                            }
                                    )
                            }
                        }
                        .frame(height: 24)
                    }
                    
                    // Brightness Slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Brightness")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                LinearGradient(gradient: Gradient(colors: [
                                    .black, Color(hue: hue, saturation: saturation, brightness: 1)
                                ]), startPoint: .leading, endPoint: .trailing)
                                .frame(height: 24)
                                .clipShape(Capsule())
                                
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .shadow(radius: 2)
                                    .offset(x: (geometry.size.width - 24) * brightness)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newValue = value.location.x / geometry.size.width
                                                brightness = max(0, min(1, newValue))
                                                updateSelectedColor()
                                            }
                                    )
                            }
                        }
                        .frame(height: 24)
                    }
                }
                .padding()
            }
            .onAppear {
                initializeValues()
            }
        }
    }
    
    private func initializeValues() {
        let color: Color
        if colorMode == .solid || !isSubscribed {
            color = meshColor1
        } else {
            color = selectedColorIndex == 0 ? meshColor1 : (selectedColorIndex == 1 ? meshColor2 : meshColor3)
        }
        if let components = UIColor(color).hsbComponents {
            hue = Double(components.hue)
            saturation = Double(components.saturation)
            brightness = Double(components.brightness)
        }
    }
    
    private func updateSelectedColor() {
        let newColor = Color(hue: hue, saturation: saturation, brightness: brightness)
        if colorMode == .solid || !isSubscribed {
            meshColor1 = newColor
        } else {
            switch selectedColorIndex {
            case 0: meshColor1 = newColor
            case 1: meshColor2 = newColor
            case 2: meshColor3 = newColor
            default: break
            }
        }
        
        // Call the saveColors function to persist the changes
        onColorChange()
    }
}

extension UIColor {
    var hsbComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)? {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return nil }
        return (h, s, b, a)
    }
}

#Preview {
    ColorCustomizationView(
        meshColor1: .constant(.black), 
        meshColor2: .constant(.red), 
        meshColor3: .constant(.orange), 
        colorMode: .constant(.mesh), 
        isSubscribed: true,
        onColorChange: {}
    )
}

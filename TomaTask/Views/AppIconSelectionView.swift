//
//  AppIconSelectionView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 19/04/25.
//

import SwiftUI

struct AppIconSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedIcon: String

    let store: Store

    @State private var iconSwitchError: String?

    let appIconSet: [String] = [
        defaultAppIcon,
        "TomatoMinimalClassic", "LemonClassic", "EggPlantClassic", "CarrotClassic",
        "CarrotAppIcon", "EggPlantAppIcon", "LemonAppIcon"
    ]

    private var isSubscribed: Bool {
        !store.purchasedSubscriptions.isEmpty
    }

    private func displayName(for icon: String) -> String {
        switch icon {
        case defaultAppIcon:          return "Default"
        case "TomatoMinimalClassic":  return "Tomato Classic Minimal"
        case "LemonClassic":          return "Lemon Classic"
        case "EggPlantClassic":       return "Eggplant Classic"
        case "CarrotClassic":         return "Carrot Classic"
        case "CarrotAppIcon":         return "Carrot"
        case "EggPlantAppIcon":       return "Eggplant"
        case "LemonAppIcon":          return "Lemon"
        default:                      return icon
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let error = iconSwitchError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                ForEach(appIconSet, id: \.self) { icon in
                    iconRow(for: icon)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
            .padding(.top, 8)
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func setIcon(_ icon: String) {
        guard UIApplication.shared.supportsAlternateIcons else {
            iconSwitchError = "Alternate icons are not supported in this build."
            return
        }
        let targetName: String? = (icon == defaultAppIcon) ? nil : icon
        Task { @MainActor in
            do {
                try await UIApplication.shared.setAlternateIconName(targetName)
                selectedIcon = icon
                dismiss()
            } catch {
                iconSwitchError = "Could not change icon: \(error.localizedDescription)"
            }
        }
    }

    private func iconRow(for icon: String) -> some View {
        let isUnlocked = isSubscribed || icon == defaultAppIcon
        let isSelected = selectedIcon == icon

        return Button {
            guard isUnlocked else { return }
            setIcon(icon)
        } label: {
            HStack(spacing: 14) {
                iconImage(for: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .opacity(isUnlocked ? 1 : 0.45)
                    .overlay {
                        if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.25), radius: 4, y: 1)
                        }
                    }

                Text(displayName(for: icon))
                    .font(.body.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(OnboardingStyle.tomatoRed)
                }
            }
            .padding(14)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected
                            ? OnboardingStyle.tomatoRed.opacity(0.35)
                            : Color(.separator).opacity(0.5),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }

    static func previewAsset(for icon: String) -> String {
        switch icon {
        case defaultAppIcon:         return "TomatoPreview"
        case "PomoTask":             return "PomoTaskPreview"
        case "TomatoMinimalClassic": return "TomatoClassicMinimalPreview"
        case "LemonClassic":         return "LemonClassicPreview"
        case "EggPlantClassic":      return "EggPlantClassicPreview"
        case "CarrotClassic":        return "CarrotClassicPreview"
        case "CarrotAppIcon":        return "CarrotPreview"
        case "EggPlantAppIcon":      return "EggPlantPreview"
        case "LemonAppIcon":         return "LemonPreview"
        default:                     return icon
        }
    }

    private func iconImage(for name: String) -> Image {
        let assetName = AppIconSelectionView.previewAsset(for: name)
        if let ui = UIImage(named: assetName) {
            return Image(uiImage: ui)
        }
        return Image(assetName)
    }
}

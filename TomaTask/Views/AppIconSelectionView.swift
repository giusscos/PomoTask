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

    let appIconSet: [String] = [defaultAppIcon, "AppIcon 1", "AppIcon 2", "AppIcon 3", "AppIcon 4"]

    private var isSubscribed: Bool {
        !store.purchasedSubscriptions.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
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

    private func iconRow(for icon: String) -> some View {
        let isUnlocked = isSubscribed || icon == defaultAppIcon
        let isSelected = selectedIcon == icon

        return Button {
            guard isUnlocked else { return }
            selectedIcon = icon
            UIApplication.shared.setAlternateIconName(icon == defaultAppIcon ? nil : icon)
            dismiss()
        } label: {
            HStack(spacing: 14) {
                Image(icon)
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

                Text(icon == defaultAppIcon ? "Default" : icon)
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
                    .fill(StatisticsAggregator.stageFloor)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected
                            ? OnboardingStyle.tomatoRed.opacity(0.35)
                            : StatisticsAggregator.splashDeep.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

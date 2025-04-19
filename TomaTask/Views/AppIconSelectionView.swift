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
    
    var body: some View {
        List {
            ForEach(appIconSet, id: \.self) { icon in
                HStack {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(icon == defaultAppIcon ? "Default" : icon)
                        .font(.body)
                    
                    if selectedIcon == icon {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !store.purchasedSubscriptions.isEmpty || icon == defaultAppIcon {
                        selectedIcon = icon
                        UIApplication.shared.setAlternateIconName(icon == defaultAppIcon ? nil : icon)
                        dismiss()
                    }
                }
                .opacity(!store.purchasedSubscriptions.isEmpty || icon == defaultAppIcon ? 1 : 0.5)
                .overlay {
                    if !store.purchasedSubscriptions.isEmpty || icon == defaultAppIcon {
                        EmptyView()
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundStyle(.ultraThinMaterial)
                    }
                }
            }
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
    }
} 

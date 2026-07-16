//
//  ProgressiveLockedView.swift
//  TomaTask
//

import SwiftUI

struct ProgressiveLockedView: View {
    @Environment(Store.self) private var store
    @State private var showingPaywall = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "dial.medium.fill")
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(OnboardingStyle.tomatoRed)
            
            Text("Progressive Timer")
                .font(.title.weight(.bold))
                .fontDesign(.rounded)
            
            Text("Start short, grow with flow, and recover smart. Unlock Progressive with Pro.")
                .font(.body.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            
            Button {
                showingPaywall = true
            } label: {
                Text("Upgrade to Pro")
                    .font(.headline.weight(.bold))
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(OnboardingStyle.tomatoRed)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .navigationTitle("Progressive")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPaywall) {
            SubscriptionStoreContentView()
        }
    }
}

#Preview {
    NavigationStack {
        ProgressiveLockedView()
    }
    .environment(Store())
}

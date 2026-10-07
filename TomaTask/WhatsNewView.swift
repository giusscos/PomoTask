import SwiftUI

/// Bump `version` when the feature list changes so existing users see it once after updating.
enum WhatsNew {
    static let version = "1.1.2"
    static let lastSeenVersionKey = "whatsNewLastSeenVersion"
}

struct WhatsNewFeature: Identifiable {
    let id = UUID()
    let title: LocalizedStringResource
    let icon: String
    let description: LocalizedStringResource
    var hiddenForSubscribers = false
}

let newFeatures: [WhatsNewFeature] = [
    WhatsNewFeature(
        title: "Try Progressive free",
        icon: "dial.medium.fill",
        description: "Your first 3 Progressive focus sessions are on us. Start at 5 minutes and let each block grow with your flow.",
        hiddenForSubscribers: true
    ),
    WhatsNewFeature(
        title: "Drag the dial",
        icon: "hand.draw.fill",
        description: "While paused, drag the dial to wind time up or down, then pick up right where you left off."
    ),
    WhatsNewFeature(
        title: "A better Apple Watch app",
        icon: "applewatch",
        description: "Progressive stays in sync with your iPhone and Live Activity, with struggle check-ins right on your wrist."
    ),
]

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store

    @AppStorage("hasSeenWhatsNew") private var hasSeenWhatsNew: Bool = false
    @AppStorage(WhatsNew.lastSeenVersionKey) private var lastSeenVersion: String = ""

    private var visibleFeatures: [WhatsNewFeature] {
        let isSubscribed = !store.purchasedSubscriptions.isEmpty
        return newFeatures.filter { !(isSubscribed && $0.hiddenForSubscribers) }
    }

    var body: some View {
        NavigationStack {
                VStack {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .symbolRenderingMode(.multicolor)

                    Text("What's New")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    Text("Discover the latest features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack (alignment: .leading, spacing: 32) {
                        ForEach(visibleFeatures) { feature in
                            FeatureRow(title: feature.title, icon: feature.icon, description: feature.description)
                        }
                    }
                    .padding(.vertical, 48)
                    .frame(maxHeight: .infinity, alignment: .top)

                    Button("Continue") {
                        hasSeenWhatsNew = true
                        lastSeenVersion = WhatsNew.version
                        dismiss()
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())

            }
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FeatureRow: View {
    let title: LocalizedStringResource
    let icon: String
    let description: LocalizedStringResource

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    WhatsNewView()
        .environment(Store())
}

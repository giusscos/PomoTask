import SwiftUI

let newFeatures: [(String, String, String)] = [
    ("Apple Watch App", "applewatch", "Take your productivity on the go with our new Apple Watch app. Start and track your timers directly from your wrist."),
    ("Deep Timer Customization", "slider.horizontal.3", "Personalize your timer experience with advanced color settings. Adjust colors to match your preferences."),
    ("Timer Status Notifications", "bell.badge.fill", "Stay focus with real-time notifications about your timer status. Never miss a break or work session again.")
]

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("hasSeenWhatsNew") private var hasSeenWhatsNew: Bool = false
    
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
                        ForEach(newFeatures, id: \.0) { feature in
                            FeatureRow(title: feature.0, icon: feature.1, description: feature.2)
                        }
                    }
                    .padding(.vertical, 48)
                    .frame(maxHeight: .infinity, alignment: .top)
                    
                    Button("Continue") {
                        hasSeenWhatsNew = true
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
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
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
} 

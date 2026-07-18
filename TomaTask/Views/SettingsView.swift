//
//  SettingsView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 01/11/24.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(Store.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Binding var appIcon: String
    @State var showSheet: Bool = false
    @State var showManageSheet: Bool = false
#if DEBUG
    @State private var showSeedConfirmation = false
#endif

    @AppStorage(SessionAlertStorage.alarmEnabled) private var alarmEnabled = true
    @AppStorage(SessionAlertStorage.notificationEnabled) private var notificationEnabled = true

    private var isSubscribed: Bool {
        !store.purchasedSubscriptions.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                promoCard
                appIconCard
                sessionAlertsSection
                supportSection
#if DEBUG
                developerSection
#endif
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .navigationTitle("Settings")
        .tint(OnboardingStyle.tomatoRed)
        .sheet(isPresented: $showSheet) {
            SubscriptionStoreContentView()
        }
        .manageSubscriptionsSheet(isPresented: $showManageSheet)
#if DEBUG
        .alert("Screenshot data seeded", isPresented: $showSeedConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Sample tasks and focus stats were added for App Store screenshots.")
        }
#endif
    }

    // MARK: - Promo

    private var promoCard: some View {
        VStack(spacing: 14) {
            Text(isSubscribed ? "Progressive Pro" : "Unlock Progressive")
                .font(.title.weight(.bold))
                .fontDesign(.rounded)
                .foregroundStyle(.white)

            Text(
                isSubscribed
                    ? "Adaptive focus, check-ins, stats, and themes are yours."
                    : "Adaptive focus, check-ins, stats, and themes"
            )
            .multilineTextAlignment(.center)
            .font(.subheadline.weight(.semibold))
            .fontDesign(.rounded)
            .foregroundStyle(.white.opacity(0.9))

            Button {
                if isSubscribed {
                    showManageSheet.toggle()
                } else {
                    showSheet.toggle()
                }
            } label: {
                Label(
                    isSubscribed ? "Manage subscription" : "Subscribe",
                    systemImage: isSubscribed ? "pencil" : "lock.fill"
                )
                .font(.headline.weight(.bold))
                .fontDesign(.rounded)
                .foregroundStyle(OnboardingStyle.tomatoRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(OnboardingStyle.tomatoRed)
        )
        .padding(.top, 8)
    }

    // MARK: - App Icon

    private var appIconCard: some View {
        NavigationLink {
            AppIconSelectionView(selectedIcon: $appIcon, store: store)
        } label: {
            HStack(spacing: 14) {
                (UIImage(named: AppIconSelectionView.previewAsset(for: appIcon)).map { Image(uiImage: $0) } ?? Image(appIcon))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text("App Icon")
                    .font(.body.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .settingsCardChrome()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Session Alerts

    private var sessionAlertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Alerts")
                .font(.headline.weight(.semibold))
                .fontDesign(.rounded)

            VStack(spacing: 0) {
                Toggle(isOn: $alarmEnabled) {
                    Label("Alarm", systemImage: "bell.and.waves.left.and.right")
                        .font(.body.weight(.medium))
                        .fontDesign(.rounded)
                }
                .padding(16)
                .onChange(of: alarmEnabled) { _, isEnabled in
                    if isEnabled {
                        Task {
                            let authorized = await SessionAlarmScheduler.requestAuthorizationIfNeeded()
                            if !authorized {
                                alarmEnabled = false
                                return
                            }
                            if !SessionAlarmScheduler.usesAlarmKit {
                                AlarmPlayer.shared.play(preview: true)
                            }
                        }
                    } else {
                        AlarmPlayer.shared.stop()
                        SessionAlarmScheduler.cancel()
                    }
                }

                Divider()
                    .padding(.leading, 16)

                Toggle(isOn: $notificationEnabled) {
                    Label("Session notification", systemImage: "app.badge")
                        .font(.body.weight(.medium))
                        .fontDesign(.rounded)
                }
                .padding(16)
                .onChange(of: notificationEnabled) { _, isEnabled in
                    if isEnabled {
                        SessionCompletionAlert.requestNotificationPermissionIfNeeded()
                    } else {
                        SessionCompletionAlert.cancelPending()
                    }
                }
            }
            .settingsCardChrome()

            Text("Alarm uses AlarmKit for a Clock-style alert that breaks through Silent mode and Focus. Turn on Alarm in Settings and allow Alarms & Timers when prompted. Session notifications are optional banners and are skipped while AlarmKit is active.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
        }
    }

    // MARK: - Support

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support")
                .font(.headline.weight(.semibold))
                .fontDesign(.rounded)

            VStack(spacing: 0) {
                if isSubscribed {
                    supportLink(title: "Request a feature", url: URL(string: "mailto:hello@giusscos.com")!)
                    settingsDivider
                }

                supportLink(title: "Terms of use", url: LegalURLs.termsOfUse)
                settingsDivider
                supportLink(title: "Privacy Policy", url: LegalURLs.privacyPolicy)
            }
            .settingsCardChrome()
        }
    }

    private var settingsDivider: some View {
        Divider()
            .padding(.leading, 16)
    }

    private func supportLink(title: String, url: URL) -> some View {
        Link(destination: url) {
            supportRow(title: title)
        }
    }

    private func supportButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            supportRow(title: title)
        }
        .buttonStyle(.plain)
    }

    private func supportRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.body.weight(.semibold))
                .fontDesign(.rounded)
                .foregroundStyle(OnboardingStyle.tomatoRed)

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(OnboardingStyle.tomatoRed.opacity(0.55))
        }
        .padding(16)
        .contentShape(Rectangle())
    }

#if DEBUG
    // MARK: - Developer

    private var developerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Developer")
                .font(.headline.weight(.semibold))
                .fontDesign(.rounded)

            VStack(spacing: 0) {
                Button {
                    do {
                        try ScreenshotDataSeeder.seed(into: modelContext)
                        showSeedConfirmation = true
                    } catch {
                        print("Failed to seed screenshot data: \(error)")
                    }
                } label: {
                    HStack {
                        Label("Add screenshot mock data", systemImage: "photo.on.rectangle.angled")
                            .font(.body.weight(.semibold))
                            .fontDesign(.rounded)
                            .foregroundStyle(OnboardingStyle.tomatoRed)

                        Spacer()
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .settingsCardChrome()

            Text("DEBUG only. Replaces existing tasks and stats with sample data for App Store screenshots.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
        }
    }
#endif
}

private extension View {
    func settingsCardChrome() -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
            )
    }
}

#Preview {
    NavigationStack {
        SettingsView(appIcon: .constant("AppIcon"))
            .environment(Store())
    }
}

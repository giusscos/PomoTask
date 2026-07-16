//
//  SettingsView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 01/11/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(Store.self) private var store
    @Binding var appIcon: String
    @State var showSheet: Bool = false
    @State var showManageSheet: Bool = false

    @AppStorage(SessionAlertStorage.alarmEnabled) private var alarmEnabled = true
    @AppStorage(SessionAlertStorage.notificationEnabled) private var notificationEnabled = true
    
    var body: some View {
        List {
            Section() {
                RoundedRectangle(cornerRadius: 48)
                    .foregroundStyle(OnboardingStyle.tomatoRed)
                    .frame(maxWidth: .infinity, maxHeight: 200, alignment: .top)
                    .aspectRatio(16/9, contentMode: .fill)
                    .overlay {
                        VStack {
                            Text("Unlock Progressive")
                                .foregroundStyle(.white)
                                .font(.largeTitle.weight(.bold))
                                .fontDesign(.rounded)
                            
                            Text("Adaptive focus, check-ins, stats, and themes")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.9))
                                .font(.subheadline.weight(.semibold))
                                .fontDesign(.rounded)
                            
                            Button {
                                if store.purchasedSubscriptions.isEmpty {
                                    UIApplication.shared.setAlternateIconName(defaultAppIcon)
                                    showSheet.toggle()
                                } else {
                                    showManageSheet.toggle()
                                }
                            } label: {
                                Label(!store.purchasedSubscriptions.isEmpty ? "Manage subscription" : "Subscribe", systemImage: !store.purchasedSubscriptions.isEmpty ? "pencil" : "lock.fill")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(OnboardingStyle.tomatoRed)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(radius: 10, x: 0, y: 4)
                            }
                            .padding(.vertical)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section {
                NavigationLink {
                    AppIconSelectionView(selectedIcon: $appIcon, store: store)
                } label: {
                    HStack {
                        Text("App Icon")

                        Image(appIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }

            Section {
                Toggle(isOn: $alarmEnabled) {
                    Label("Alarm", systemImage: "bell.and.waves.left.and.right")
                }
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

                Toggle(isOn: $notificationEnabled) {
                    Label("Session notification", systemImage: "app.badge")
                }
                .onChange(of: notificationEnabled) { _, isEnabled in
                    if isEnabled {
                        SessionCompletionAlert.requestNotificationPermissionIfNeeded()
                    } else {
                        SessionCompletionAlert.cancelPending()
                    }
                }
            } header: {
                Text("Session Alerts")
            } footer: {
                Text("Alarm uses AlarmKit for a Clock-style alert that breaks through Silent mode and Focus. Turn on Alarm in Settings and allow Alarms & Timers when prompted. Session notifications are optional banners and are skipped while AlarmKit is active.")
            }
            
            Section {
                if !store.purchasedSubscriptions.isEmpty {
                    Link("Request a feature", destination: URL(string: "mailto:hello@giusscos.com")!)
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Button {
                        showSheet.toggle()
                    } label: {
                        Text("Request a refund")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                
                Link("Terms of use", destination: LegalURLs.termsOfUse)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Link("Privacy Policy", destination: LegalURLs.privacyPolicy)
                    .font(.headline)
                    .foregroundColor(.blue)
            } header: {
                Text("Support")
            }
        }
        .sheet(isPresented: $showSheet, content: {
            SubscriptionStoreContentView()
        })
        .manageSubscriptionsSheet(isPresented: $showManageSheet)
    }
}

#Preview {
    SettingsView(appIcon: .constant("AppIcon"))
        .environment(Store())
}

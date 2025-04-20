//
//  SettingsView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 01/11/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var appIcon: String
    @State var showSheet: Bool = false
    @State var showManageSheet: Bool = false
    @State var store = Store()
    
    var body: some View {
        List {
            Section() {
                RoundedRectangle(cornerRadius: 48)
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity, maxHeight: 200, alignment: .top)
                    .aspectRatio(16/9, contentMode: .fill)
                    .overlay {
                        VStack {
                            Text("Pro access")
                                .foregroundStyle(.white)
                                .font(.largeTitle)
                                .bold()
                            
                            Text("Unlock fantastic and handcrafted themes and app icons for your cool Pomorodo and Progressive timer")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
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
                                    .foregroundStyle(Color.accentColor)
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
                
                Link("Terms of use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Link("Privacy Policy", destination: URL(string: "https://giusscos.it/privacy")!)
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
    SettingsView(appIcon: .constant("AppIcon"), store: Store())
}

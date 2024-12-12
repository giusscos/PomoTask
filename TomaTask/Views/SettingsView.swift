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
    
    let appIconSet: [String] = [defaultAppIcon, "AppIcon 1", "AppIcon 2", "AppIcon 3", "AppIcon 4"]
    
    var body: some View {
        List {
            Section() {
                RoundedRectangle(cornerRadius: 48)
                    .foregroundStyle(.red)
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
                                    .foregroundStyle(.red)
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
                LazyVGrid (columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(appIconSet, id: \.self) { index in
                        if !store.purchasedSubscriptions.isEmpty || index == defaultAppIcon {
                            Image(index)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
                                .onTapGesture {
                                    appIcon = index
                                    UIApplication.shared.setAlternateIconName(index == defaultAppIcon ? nil : index)
                                }
                        } else {
                            Image(index)
                                .resizable()
                                .grayscale(1)
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    Image(systemName: "lock.fill")
                                        .font(.largeTitle)
                                        .shadow(radius: 10, x: 0, y: 4)
                                        .padding()
                                        .foregroundStyle(.ultraThinMaterial)
                                }
                                .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
                                .onTapGesture {
                                    showSheet.toggle()
                                }
                        }
                    }
                }
            } header: {
                Text("App Icon")
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
//            PayWallView(colorSets: colorSets, products: store.products)
//                .presentationDragIndicator(.visible)
            SubscriptionStoreContentView()
        })
        .manageSubscriptionsSheet(isPresented: $showManageSheet)
    }
}

#Preview {
    SettingsView(appIcon: .constant("AppIcon"), store: Store())
}

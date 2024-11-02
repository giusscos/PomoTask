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
    @State var showRefundSheet: Bool = false
    @State var showManageSheet: Bool = false
    
    var store = Store()
    
    let appIconSet: [String] = [defaultAppIcon, "AppIcon 1", "AppIcon 2", "AppIcon 3", "AppIcon 4"]
    
    var body: some View {
        List {
            Section() {
                RoundedRectangle(cornerRadius: 48)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4, alignment: .top)
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
                                if !store.unlockAccess {
                                    UIApplication.shared.setAlternateIconName(defaultAppIcon)
                                    showSheet.toggle()
                                } else {
                                    showManageSheet.toggle()
                                }
                            } label: {
                                Label(store.unlockAccess ? "Manage subscription" : "Subscribe", systemImage: store.unlockAccess ? "pencil" : "lock.fill")
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
                        if store.unlockAccess || index == defaultAppIcon {
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
                if store.unlockAccess {
                    Link("Request a feature", destination: URL(string: "mailto:giusscos@icloud.com")!)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Link("Privacy Policy", destination: URL(string: "https://giusscos.it/privacy")!)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Button {
                    showRefundSheet.toggle()
                } label: {
                    Text("Request a refund")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            } header: {
                Text("Support")
            }
        }
        .onAppear() {
            Task {
                try await store.fetchAvailableProducts()
            }
        }
        .sheet(isPresented: $showSheet, content: {
            PayWallView(colorSets: colorSets, products: store.products)
                .presentationDragIndicator(.visible)
        })
        .manageSubscriptionsSheet(isPresented: $showManageSheet)
        .refundRequestSheet(for: store.transactionId, isPresented: $showRefundSheet)
    }
    
    func openMailApp() {
        let email = "giusscos@icloud.com"
        let subject = "Request a feature"
        let body = "Hi team,"
        
        // Encode the subject and body text
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        print("Failed to open Mail app.")
                    }
                }
            } else {
                print("Mail app is not available or not configured.")
            }
        }
    }
}

#Preview {
    SettingsView(appIcon: .constant("AppIcon"), store: Store())
}

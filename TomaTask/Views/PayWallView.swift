//
//  PayWallView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 31/10/24.
//

import SwiftUI
import StoreKit

struct PayWallView: View {
    @Environment(\.purchase) private var purchase: PurchaseAction
    @Environment(\.dismiss) var dismiss
    
    @State var productId: String = ""
    
    var selectedPrice: String {
        products.filter({$0.id == productId}).first?.displayPrice ?? ""
    }
    
    var selectedFrequency: String {
        products.filter({$0.id == productId}).first!.subscription?.subscriptionPeriod.debugDescription ?? ""
    }
    
    var product: Product {
        products.filter({$0.id == productId}).first!
    }
    
    var colorSets: [(Color, Color, Color)]
    
    var products: [Product]
    
    var body: some View {
        List {
            VStack (spacing: 32) {
                HStack (spacing: -80.0) {
                    ForEach(0..<colorSets.count, id: \.self) { index in
                        let colors = colorSets[index]
                        
                        MeshGradientTimer(time: Double(index), meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                            .clipShape(Circle())
                            .shadow(radius: 10, x: 0, y: 4)
                    }
                }.frame(height: 100)
                .frame(maxWidth: 400, alignment: .center)
                
                VStack {
                    Text("Pro access".capitalized)
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Unlock fantastic and handcrafted themes and app icons for your cool Pomorodo and Progressive timer")
                        .multilineTextAlignment(.center)
                }
            }
            .listRowInsets(.init(top: 48, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            
            if !products.isEmpty {
                Picker(selection: $productId, label: Text("Select Plan")) {
                    ForEach(0..<products.count, id: \.self) { index in
                        HStack (alignment: .center) {
                            VStack (alignment: .leading) {
                                Text(products[index].displayName.capitalized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(products[index].description)
                                    .font(.subheadline)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(products[index].displayPrice.capitalized)
                                .font(.subheadline)
                        }.tag(products[index].id)
                    }
                }.pickerStyle(.inline)
                    .listRowSeparator(.hidden)
            }
                
            Section() {
                ForEach(0..<featureSets.count, id: \.self) { index in
                    let feature = featureSets[index]
                    let colors = colorSets[index]
                    
                    HStack (spacing: 16) {
                        Image(systemName: feature.1)
                            .frame(width: 32, height: 32)
                            .padding(4)
                            .foregroundStyle(.white)
                            .background(index % 2 == 0 ? colors.1 : colors.2)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack (alignment: .leading){
                            Text(feature.0)
                                .bold()
                                .font(.headline)
                                .tint(.accentColor)
                            
                            Text(feature.2)
                                .font(.subheadline)
                        }
                    }
                }
            } header: {
                Text("What's included")
            }
            .listRowSeparator(.visible)
            
            Section {
                Link("Terms of use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Link("Privacy Policy", destination: URL(string: "https://giusscos.it/privacy")!)
                    .font(.headline)
                    .foregroundColor(.blue)
            } header: {
                Text("Support")
            }
        }.onAppear() {
            productId = products.first?.id ?? ""
        }
        
        if selectedPrice != "" {
            VStack {
                Text("Plan automatically renews after \(selectedFrequency) if you don't cancel.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Button {
//                    Store().handlePurchase(purchase: purchase, product: product)
                    
                    dismiss()
                } label: {
                    Text("Subscribe for \(selectedPrice)/\(selectedFrequency.lowercased().split(separator: " ")[1])")
                        .bold()
                        .padding()
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    
                }
            }
        } else {
            Button {
                dismiss()
            } label: {
                Text("Something wrong. Try later")
                    .bold()
                    .padding()
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
            }
            .disabled(true)
        }
    }
}

#Preview {
    PayWallView(colorSets: [
        (.black, .red, .orange),
        (.black, .green, .blue),
        (.black, .yellow, .purple),
        (.black, .indigo, .pink)
    ], products: [])
}

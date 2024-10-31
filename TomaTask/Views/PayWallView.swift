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
    
    @Binding var productId: String
    
    var selectedPrice: String {
        products.filter({$0.id == productId}).first?.displayPrice ?? ""
    }
    
    var product: Product {
        products.filter({$0.id == productId}).first!
    }
    
    var colorSets: [(Color, Color, Color)]
    
    var products: [Product]
    
    var featureSets: [(String, String, String)] = [
        ("iCloud Sync", "cloud.fill", "Stay focus and productive on all your devices"),
        ("Crafted New Themes", "swatchpalette.fill", "Discover new visual and artistic themes every month"),
        ("Crafted New App Icons", "app.gift.fill", "Customize the app icon with multiple and fantastic designs"),
        ("Feature suggestions", "questionmark.app.fill", "Take the chance to request a feature for your PomoTask app"),
    ]
    
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
            
            Picker(selection: $productId, label: Text("Select Plan")) {
                ForEach(0..<products.count, id: \.self) { index in
                    HStack {
                        VStack {
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
                
            Section(header: Text("What's included")) {
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
            }
            .listRowSeparator(.visible)
        }.onAppear() {
            productId = products.first?.id ?? ""
        }
        
        if selectedPrice != "" {
            Button {
                Store().handlePurchase(purchase: purchase, product: product)
                
                dismiss()
            } label: {
                Text("Subscribe for \(selectedPrice)")
                    .bold()
                    .padding()
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                
            }
        } else {
            Button {
                dismiss()
            } label: {
                Text("This product can't be purchased")
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
    PayWallView(productId: .constant(""), colorSets: [
        (.black, .red, .orange),
        (.black, .green, .blue),
        (.black, .yellow, .purple),
        (.black, .indigo, .pink)
    ], products: [])
}

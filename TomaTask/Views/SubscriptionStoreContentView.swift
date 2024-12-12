//
//  SubscriptionStoreContentView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 12/12/24.
//

import SwiftUI
import StoreKit

struct SubscriptionStoreContentView: View {
    @State var store = Store()
    
    var body: some View {
        SubscriptionStoreView(groupID: Store().groupId) {
            List {
                VStack (spacing: 32) {
                    HStack (spacing: -80.0) {
                        ForEach(0..<4, id: \.self) { index in
                            let colors = colorSets[index]
                            
                            MeshGradientTimer(time: Double(index), meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                                .clipShape(Circle())
                                .shadow(radius: 10, x: 0, y: 4)
                        }
                    }
                    .frame(height: 100)
                    .frame(maxWidth: 400, alignment: .center)
                    
                    VStack {
                        Text("Pro access".capitalized)
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Unlock fantastic and handcrafted themes and app icons for your cool Pomorodo and Progressive timer")
                            .multilineTextAlignment(.center)
                    }
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
            }.padding(.top)
        }
        .subscriptionStoreControlStyle(.compactPicker, placement: .bottomBar)
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
    }
}

#Preview {
    SubscriptionStoreContentView()
}

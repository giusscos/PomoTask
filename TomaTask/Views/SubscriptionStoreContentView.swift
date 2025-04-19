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
                Section {
                    VStack (spacing: 32) {
                        VStack {
                            Text("Pro access".capitalized)
                                .font(.largeTitle)
                                .bold()
                            
                            Text("Unlock fantastic and handcrafted themes and app icons for your cool Pomorodo and Progressive timer")
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                Section() {
                    ForEach(0..<featureSets.count, id: \.self) { index in
                        let feature = featureSets[index]
                        
                        HStack (spacing: 16) {
                            Image(systemName: feature.1)
                                .frame(width: 32, height: 32)
                                .padding(4)
                                .foregroundStyle(.white)
                                .background(Color.blue)
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

//
//  ProgressiveTimerList.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 29/10/24.
//

import SwiftUI
import StoreKit

struct ProgressiveTimerList: View {
    @Namespace private var namespace
    
    @State var products: [Product] = []
        
    @State private var colorSets: [(Color, Color, Color)] = [
        (.black, .red, .orange),
        (.black, .green, .blue),
        (.black, .yellow, .purple),
        (.black, .indigo, .pink)
    ]
    
    @State var selectedProduct: Product?
    @State var productId: String = ""
    @State var showSheet: Bool = false
    
    var body: some View {
        ScrollView {
            ForEach(0..<colorSets.count, id: \.self) { index in
                let colors = colorSets[index]
                
                if index == 0 {
                    NavigationLink {
                        ProgressiveTimerView(meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                            .navigationTransition(.zoom(sourceID: index, in: namespace))
                    } label: {
                        ProgressiveTimerRow(isLocked: index != 0, meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                            .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.3)
                    }
                    .matchedTransitionSource(id: index, in: namespace)
                }
                
                if index != 0 && !products.isEmpty {
                    ProgressiveTimerRow(isLocked: index != 0, meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.3)
                        .onTapGesture {
                            showSheet.toggle()
                        }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showSheet, content: {
            PayWallView(productId: $productId, colorSets: colorSets, products: products)
                .presentationDragIndicator(.visible)
        })
        .onAppear() {
            Task {
                products = try await Store().fetchAvailableProducts()
            }
        }
    }
}

#Preview {
    ProgressiveTimerList()
}

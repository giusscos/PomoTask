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
    
    @AppStorage("tapToHideInterface") var tapToHideInterface: Bool = true
    
    @State var selectedProduct: Product?
    @State var showSheet: Bool = false
    
    var store = Store()
    
    var body: some View {
        ScrollView {
            NavigationLink {
                ProgressiveTimerView(type: 0)
                    .navigationTransition(.zoom(sourceID: -1, in: namespace))
            } label: {
                SolidTimer(heigth: screenSize)
                    .overlay(content: {
                        Text("Solid Color")
                            .font(.title)
                            .fontWeight(.semibold)
                            .tint(.primary)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 48))
                    .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.3)
            }
            .matchedTransitionSource(id: -1, in: namespace)
            
            ForEach(0..<colorSets.count, id: \.self) { index in
                let colors = colorSets[index]
                
                if !store.products.isEmpty {
                    if !store.unlockAccess {
                        ProgressiveTimerRow(isLocked: !store.unlockAccess, meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                            .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.3)
                            .onTapGesture {
                                showSheet.toggle()
                            }
                    } else {
                        NavigationLink {
                            ProgressiveTimerView(meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                                .navigationTransition(.zoom(sourceID: index, in: namespace))
                        } label: {
                            ProgressiveTimerRow(isLocked: !store.unlockAccess, meshColor1: colors.0, meshColor2: colors.1, meshColor3: colors.2)
                                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.3)
                        }
                        .matchedTransitionSource(id: index, in: namespace)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showSheet, content: {
            PayWallView(colorSets: colorSets, products: store.products)
                .presentationDragIndicator(.visible)
        })
        .fullScreenCover(isPresented: $tapToHideInterface, content: {
            RelaxModePopover(tapToHideInterface: $tapToHideInterface)
        })
    }
    
    struct RelaxModePopover: View {
        @Environment(\.dismiss) var dismiss
        
        @Binding var tapToHideInterface: Bool
        
        var body: some View {
            VStack (spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 48))
                    .transition(.symbolEffect(.appear))
                    .foregroundStyle(Color.accentColor)
                    .symbolEffect(.wiggle.up)
                
                Text("Relax Mode")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Tap the screen to focus and relax by hiding the interface. Simply tap anywhere on the screen to toggle visibility, reducing distractions and helping you enjoy a more peaceful experience and the fantastic design.")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Button {
                    dismiss()
                    tapToHideInterface = false
                } label: {
                    Text("Got it")
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }.padding(.vertical)
            }.padding()
            .frame(maxWidth: 600)
        }
    }
}

#Preview {
    ProgressiveTimerList(store: Store())
}

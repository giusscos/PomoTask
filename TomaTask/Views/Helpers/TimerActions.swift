//
//  TimerActions.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 30/10/24.
//

import SwiftUI

struct TimerActions: View {
    @Environment(\.dismiss) var dismiss

    @AppStorage(SessionAlertStorage.alarmEnabled) private var alarmEnabled = true
    @Binding var dimDisplay: Bool
    @Binding var showingColorCustomization: Bool
    var backButton: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                if backButton {
                    Button (role: .cancel) {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .labelStyle(.iconOnly)
                            .padding(8)
                            .foregroundColor(.white)
                            .bold()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 10, x: 0, y: 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    alarmEnabled.toggle()
                    if !alarmEnabled {
                        AlarmPlayer.shared.stop()
                        SessionAlarmScheduler.cancel()
                    }
                } label: {
                    Label("Toggle alarm", systemImage: alarmEnabled ? "bell.and.waves.left.and.right.fill" : "bell.slash.fill")
                        .labelStyle(.iconOnly)
                        .contentTransition(.symbolEffect(.replace))
                        .padding(8)
                        .foregroundColor(.white)
                        .bold()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 10, x: 0, y: 4)
                        .animation(.none, value: alarmEnabled)
                }
                
                Button {
                    showingColorCustomization = true
                } label: {
                    Label("Customize Colors", systemImage: "paintpalette.fill")
                        .labelStyle(.iconOnly)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
//            Button {
//                dimDisplay.toggle()
//                
//                UIApplication.shared.isIdleTimerDisabled = dimDisplay
//            } label: {
//                Label("Auto-lock", systemImage: dimDisplay ? "lock" : "lock.open")
//                    .contentTransition(.symbolEffect(.replace))
//                    .padding(8)
//                    .foregroundColor(.white)
//                    .bold()
//                    .background(.ultraThinMaterial)
//                    .clipShape(Capsule())
//                    .shadow(radius: 10, x: 0, y: 4)
//                    .animation(.none, value: dimDisplay)
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .onAppear() {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}

#Preview {
    TimerActions(dimDisplay: .constant(true), showingColorCustomization: .constant(false))
}

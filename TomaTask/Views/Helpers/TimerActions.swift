//
//  TimerActions.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 30/10/24.
//

import SwiftUI

struct TimerActions: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var alarmSound: Bool
    @Binding var dimDisplay: Bool
    
    var body: some View {
        HStack {
            Button (role: .destructive) {
                dismiss()
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(8)
                    .foregroundColor(.white)
                    .bold()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 10, x: 0, y: 4)
            }
            
            Button {
                alarmSound.toggle()
            } label: {
                Label("Toggle sound", systemImage: alarmSound ? "speaker.fill" : "speaker.slash.fill")
                    .labelStyle(.iconOnly)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(8)
                    .foregroundColor(.white)
                    .bold()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 10, x: 0, y: 4)
                    .animation(.none, value: alarmSound)
            }
            
            Button {
                dimDisplay.toggle()
                
                UIApplication.shared.isIdleTimerDisabled = dimDisplay
            } label: {
                Label("Auto-lock", systemImage: dimDisplay ? "lock" : "lock.open")
                    .contentTransition(.symbolEffect(.replace))
                    .padding(8)
                    .foregroundColor(.white)
                    .bold()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(radius: 10, x: 0, y: 4)
                    .animation(.none, value: dimDisplay)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

#Preview {
    TimerActions(alarmSound: .constant(true), dimDisplay: .constant(true))
}

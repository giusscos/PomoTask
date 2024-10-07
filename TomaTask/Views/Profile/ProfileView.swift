//
//  ProfileView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    @Environment(\.modelContext) var modelContext
    
    @Query private var profile: [Profile] = [Profile()]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button("Back", systemImage: "chevron.left") {
                    dismiss()
                }
                    
                Spacer()
            }
            
            Form {
                TextField("Name", text: Binding(
                    get: { profile[0].userName },
                    set: { newValue in
                        profile[0].userName = newValue
                        saveChanges()
                    }
                ))
                
                Toggle(isOn: Binding(
                    get: { profile[0].prefersNotifications },
                    set: { newValue in
                        profile[0].prefersNotifications = newValue
                        saveChanges()
                    }
                )) {
                    Text("Enable Notifications")
                }
                
                Toggle(isOn: Binding(
                    get: { profile[0].lockApp },
                    set: { newValue in
                        profile[0].lockApp = newValue
                        saveChanges()
                    }
                )) {
                    Text("Enable Lock app")
                }
            }
        }
        .padding()
        
        Spacer()
    }
    
    private func saveChanges() {
        try? modelContext.save()
    }
}

#Preview {
    ProfileView()
}

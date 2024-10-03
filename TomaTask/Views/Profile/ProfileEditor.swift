//
//  ProfileEditor.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct ProfileEditor: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack {
            Toggle(isOn: $profile.prefersNotifications) {
                Text("Enable Notifications")
            }
            
            Toggle(isOn: $profile.lockApp) {
                Text("Enable Lock app")
            }
        }
    }
}

#Preview {
    ProfileEditor(profile: .constant(Profile()))
}

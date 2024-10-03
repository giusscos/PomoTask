//
//  ProfileView.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 27/09/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.editMode) var editMode
    @Environment(ModelData.self) var modelData
    
    @State private var draftProfile = Profile()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button("Back", systemImage: "chevron.left") {
                    presentationMode.wrappedValue.dismiss()
                }
                    
                Spacer()
            }
            
            ProfileEditor(profile: $draftProfile)
                .onAppear {
                    draftProfile = Profile()
                }
                .onDisappear {
                    modelData.profile = draftProfile
                }
            }
        .padding()
        
        Spacer()
    }
}

#Preview {
    ProfileView()
        .environment(ModelData())
}

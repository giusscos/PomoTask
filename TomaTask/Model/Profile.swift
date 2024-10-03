//
//  Profile.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import Foundation
import SwiftData

@Model
class Profile {
    var prefersNotifications = true
    var lockApp = false
    
    init(prefersNotifications: Bool = true, lockApp: Bool = false) {
        self.prefersNotifications = prefersNotifications
        self.lockApp = lockApp
    }
}

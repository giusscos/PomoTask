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
    var userName: String = "user"
    var prefersNotifications = true
    var lockApp = false
    
    init(userName: String = "user", prefersNotifications: Bool = true, lockApp: Bool = false) {
        self.userName = userName
        self.prefersNotifications = prefersNotifications
        self.lockApp = lockApp
    }
}

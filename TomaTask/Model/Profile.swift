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
    var username: String
    var prefersNotifications = true
    
    init(username: String = "user", prefersNotifications: Bool = true) {
        self.username = username
        self.prefersNotifications = prefersNotifications
    }
    
    static var `default` = Profile(username: "user")
}

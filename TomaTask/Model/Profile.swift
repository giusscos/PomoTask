//
//  Profile.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import Foundation

struct Profile {
    var username: String
    var prefersNotifications = true
    
    static let `default` = Profile(username: "user")
}

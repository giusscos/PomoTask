//
//  TomaTask.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 19/04/25.
//

import Foundation
import SwiftData

@Model
class TomaTask  {
    var title: String = ""
    var maxDuration: Int = 25
    var pauseDuration: Int = 5
    var repetition: Int = 4
    
    var category: Category = Category.work
    
    enum Category: String, CaseIterable, Codable, Identifiable {
        case work
        case study
        case home
        case wealth
        
        var id: String { rawValue }
        
        var emoji: String {
            switch self {
            case .work: "💼"
            case .study: "🧠"
            case .home: "🏠"
            case .wealth: "🫀"
            }
        }
        
        var localizedName: String {
            switch self {
            case .work: String(localized: "Work")
            case .study: String(localized: "Study")
            case .home: String(localized: "Home")
            case .wealth: String(localized: "Wealth")
            }
        }
        
        var displayName: String {
            "\(emoji) \(localizedName)"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            switch raw {
            case "work", "💼 Work":
                self = .work
            case "study", "🧠 Study":
                self = .study
            case "home", "🏠 Home":
                self = .home
            case "wealth", "🫀 Wealth":
                self = .wealth
            default:
                self = .work
            }
        }
    }
    
    init(
        title: String = "",
        maxDuration: Int = 25,
        pauseDuration: Int = 5,
        repetition: Int = 4,
        category: Category = Category.work
    ) {
        self.title = title
        self.maxDuration = maxDuration
        self.pauseDuration = pauseDuration
        self.repetition = repetition
        self.category = category
    }
}

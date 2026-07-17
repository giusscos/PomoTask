//
//  WidgetDeepLink.swift
//  TomaTask
//

import Foundation

/// Bridges Home Screen widget taps into the Progressive timer.
enum WidgetDeepLink {
    static let pendingPlayKey = "widgetPendingPlay"

    static var pendingPlay: Bool {
        get { UserDefaults.standard.bool(forKey: pendingPlayKey) }
        set { UserDefaults.standard.set(newValue, forKey: pendingPlayKey) }
    }

    /// Widget play button — open Progressive and start.
    static func shouldStartTimer(path: String) -> Bool {
        path == "start"
    }

    /// Open Progressive without forcing a start (e.g. medium/large background tap).
    static func shouldOpenTimer(path: String) -> Bool {
        path == "start" || path == "timer"
    }

    static func consumePendingPlay() -> Bool {
        guard pendingPlay else { return false }
        pendingPlay = false
        return true
    }
}

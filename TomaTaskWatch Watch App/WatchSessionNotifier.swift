//
//  WatchSessionNotifier.swift
//  TomaTaskWatch Watch App
//

import Foundation
import UserNotifications

/// Local completion alerts for Watch-owned Progressive sessions.
enum WatchSessionNotifier {
    private static let notificationID = "watchTimerCompletion"

    static func requestPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    static func schedule(after timeInterval: TimeInterval, isBreak: Bool) {
        cancel()

        let content = UNMutableNotificationContent()
        content.title = isBreak ? "Break complete" : "Focus complete"
        content.body = isBreak
            ? "Break is over — ready when you are."
            : "Focus block finished. How did it feel?"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(timeInterval, 1),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: notificationID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
}

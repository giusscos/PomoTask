//
//  SessionCompletionAlert.swift
//  TomaTask
//

import Foundation
import UserNotifications

enum SessionAlertStorage {
    static let alarmEnabled = "sessionAlarmEnabled"
    static let notificationEnabled = "sessionNotificationEnabled"
}

@MainActor
enum SessionCompletionAlert {
    private static let notificationID = "timerCompletion"

    static var isAlarmEnabled: Bool {
        if UserDefaults.standard.object(forKey: SessionAlertStorage.alarmEnabled) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: SessionAlertStorage.alarmEnabled)
    }

    static var isNotificationEnabled: Bool {
        if UserDefaults.standard.object(forKey: SessionAlertStorage.notificationEnabled) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: SessionAlertStorage.notificationEnabled)
    }

    static func handleSessionFinished(isBreak: Bool) {
        // AlarmKit plays the system alarm itself when the countdown ends.
        // Do not cancel it here — that was killing the Clock-style alert.
        if isAlarmEnabled && !SessionAlarmScheduler.usesAlarmKit {
            AlarmPlayer.shared.play()
        }

        // Skip local banners when AlarmKit is presenting the system alarm.
        if isNotificationEnabled && !(SessionAlarmScheduler.usesAlarmKit && isAlarmEnabled) {
            deliverImmediateNotification(isBreak: isBreak)
        }

        SessionAlarmScheduler.clearTrackingOnly()
    }

    static func scheduleBackgroundNotification(after timeInterval: TimeInterval, isBreak: Bool) {
        cancelPending()

        // When AlarmKit owns the alarm, skip local notifications entirely —
        // otherwise you only get a quiet banner instead of the system alarm.
        if SessionAlarmScheduler.usesAlarmKit && isAlarmEnabled {
            return
        }

        guard isNotificationEnabled || isAlarmEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = isBreak ? "Break Time Complete" : "Focus Time Complete"
        content.body = "Your \(isBreak ? "break" : "focus") session has ended."
        content.sound = isAlarmEnabled ? .default : nil

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(timeInterval, 1), repeats: false)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelPending() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }

    static func requestNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    private static func deliverImmediateNotification(isBreak: Bool) {
        let content = UNMutableNotificationContent()
        content.title = isBreak ? "Break Time Complete" : "Focus Time Complete"
        content.body = "Your \(isBreak ? "break" : "focus") session has ended."
        let shouldPlaySound = isAlarmEnabled && !SessionAlarmScheduler.usesAlarmKit
        content.sound = shouldPlaySound ? .default : nil

        let request = UNNotificationRequest(
            identifier: "\(notificationID).immediate.\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}

//
//  OpenAlarmAppIntent.swift
//  TomaTask
//

import AppIntents
import Foundation

/// Opens PomoTask when the user taps Open (or Stop, if wired) on an AlarmKit alert.
@available(iOS 26.0, *)
struct OpenAlarmAppIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Open PomoTask"
    static var description = IntentDescription("Opens PomoTask after a focus or break alarm.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Alarm ID")
    var alarmID: String

    init() {
        self.alarmID = ""
    }

    init(alarmID: String) {
        self.alarmID = alarmID
    }

    func perform() async throws -> some IntentResult {
        .result()
    }
}

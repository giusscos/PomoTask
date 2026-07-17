//
//  ToggleFocusTimerIntent.swift
//  TomaTask
//

import AppIntents
import Foundation

/// Play / pause the focus session from a Home Screen widget without opening the app.
struct ToggleFocusTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Play or Pause Focus Timer"
    static var description = IntentDescription("Starts, pauses, or resumes the Progressive focus timer.")
    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        await FocusSessionRemote.toggle()
        return .result()
    }
}

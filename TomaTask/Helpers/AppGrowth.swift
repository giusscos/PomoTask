//
//  AppGrowth.swift
//  TomaTask
//

import Foundation

/// Free Progressive focus blocks granted before the Pro paywall.
enum ProgressiveTrial {
    static let freeSessionsUsedKey = "progressiveFreeSessionsUsed"
    static let freeSessionLimit = 3

    static func hasRemaining(used: Int) -> Bool {
        used < freeSessionLimit
    }
}

/// Decides when to ask for an App Store rating: after a positive moment,
/// once enough focus blocks are done, at most once per app version.
enum ReviewPrompt {
    static let completedFocusBlocksKey = "reviewCompletedFocusBlocks"
    static let lastRequestedVersionKey = "reviewLastRequestedVersion"
    static let minimumCompletedFocusBlocks = 3

    private static var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    static func recordCompletedFocusBlock() {
        let defaults = UserDefaults.standard
        defaults.set(defaults.integer(forKey: completedFocusBlocksKey) + 1, forKey: completedFocusBlocksKey)
    }

    /// Returns true (and marks this version as asked) when a review request should be shown now.
    static func shouldRequestAfterPositiveMoment() -> Bool {
        let defaults = UserDefaults.standard
        guard defaults.integer(forKey: completedFocusBlocksKey) >= minimumCompletedFocusBlocks,
              defaults.string(forKey: lastRequestedVersionKey) != currentVersion else {
            return false
        }
        defaults.set(currentVersion, forKey: lastRequestedVersionKey)
        return true
    }
}

//
//  WatchTimerRuntime.swift
//  TomaTaskWatch Watch App
//

import WatchKit

/// Keeps a Progressive session alive while the Watch screen sleeps.
@MainActor
final class WatchTimerRuntime: NSObject, WKExtendedRuntimeSessionDelegate {
    static let shared = WatchTimerRuntime()

    private var session: WKExtendedRuntimeSession?

    func start() {
        stop()
        let next = WKExtendedRuntimeSession()
        next.delegate = self
        next.start()
        session = next
    }

    func stop() {
        session?.invalidate()
        session = nil
    }

    nonisolated func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    nonisolated func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    nonisolated func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        Task { @MainActor in
            if self.session === extendedRuntimeSession {
                self.session = nil
            }
        }
    }
}

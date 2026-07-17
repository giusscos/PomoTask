//
//  WatchSessionManager.swift
//  TomaTask
//

import Foundation
import WatchConnectivity

extension Notification.Name {
    /// Posted after a companion snapshot is written to `SharedTimerStore`.
    static let watchCompanionSnapshotDidUpdate = Notification.Name("watchCompanionSnapshotDidUpdate")
}

/// Bridges Progressive session snapshots between iPhone and Apple Watch.
@MainActor
@Observable
final class WatchSessionManager: NSObject {
    static let shared = WatchSessionManager()

    private(set) var latestSnapshot: SharedTimerStore.Snapshot = .idle
    private var isApplyingRemote = false
    private let snapshotKey = "snapshot"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        latestSnapshot = SharedTimerStore.load()
    }

    /// Push local Progressive state to the companion. No-ops while applying remote state.
    func broadcast(_ snapshot: SharedTimerStore.Snapshot) {
        guard !isApplyingRemote else { return }
        latestSnapshot = snapshot

        guard WCSession.default.activationState == .activated else { return }
        guard let data = try? encoder.encode(snapshot) else { return }
        let payload: [String: Any] = [snapshotKey: data]

        try? WCSession.default.updateApplicationContext(payload)

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil) { _ in }
        }
    }

    private func applyRemoteSnapshotData(_ data: Data) {
        guard let snapshot = try? decoder.decode(SharedTimerStore.Snapshot.self, from: data) else { return }
        applyRemote(snapshot)
    }

    private func applyRemote(_ snapshot: SharedTimerStore.Snapshot) {
        isApplyingRemote = true
        latestSnapshot = snapshot
        SharedTimerStore.save(snapshot)
#if os(iOS)
        SharedTimerStore.reloadWidgets()
#endif
        isApplyingRemote = false
        NotificationCenter.default.post(name: .watchCompanionSnapshotDidUpdate, object: nil)
    }
}

extension WatchSessionManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        // Intentionally empty — context arrives via didReceive*.
    }

#if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext[snapshotKey] as? Data else { return }
        Task { @MainActor in
            self.applyRemoteSnapshotData(data)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let data = message[snapshotKey] as? Data else { return }
        Task { @MainActor in
            self.applyRemoteSnapshotData(data)
        }
    }
}

//
//  TomaTaskAlarmMetadata.swift
//  TomaTask
//

import AlarmKit
import Foundation

@available(iOS 26.0, *)
nonisolated struct TomaTaskAlarmMetadata: AlarmMetadata {
    var isBreak: Bool
}

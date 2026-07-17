//
//  TomaTaskWidgetsBundle.swift
//  TomaTaskWidgets
//

import WidgetKit
import SwiftUI

@main
struct TomaTaskWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TomaTaskTimerWidget()
        TomaTaskStatsWidget()
        TomaTaskLiveActivity()
        TomaTaskAlarmLiveActivity()
    }
}

//
//  TomaTaskAlarmLiveActivity.swift
//  TomaTaskWidgets
//

import AlarmKit
import SwiftUI
import WidgetKit

@available(iOS 26.0, *)
struct TomaTaskAlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<TomaTaskAlarmMetadata>.self) { context in
            AlarmLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.metadata?.isBreak == true
                          ? "cup.and.saucer.fill"
                          : "alarm.fill")
                        .font(.title2)
                        .foregroundStyle(context.attributes.tintColor)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    AlarmCountdownText(state: context.state)
                        .font(.title3.monospacedDigit())
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.metadata?.isBreak == true ? "Break" : "Focus")
                        .font(.headline)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Text("PomoTask")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(context.attributes.tintColor)
            } compactTrailing: {
                AlarmCountdownText(state: context.state)
                    .frame(width: 50)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(context.attributes.tintColor)
            }
            .keylineTint(context.attributes.tintColor)
        }
    }
}

@available(iOS 26.0, *)
private struct AlarmLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<TomaTaskAlarmMetadata>>

    var body: some View {
        HStack {
            Image(systemName: context.attributes.metadata?.isBreak == true
                  ? "cup.and.saucer.fill"
                  : "alarm.fill")
                .foregroundStyle(context.attributes.tintColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.metadata?.isBreak == true ? "Break" : "Focus")
                    .font(.headline)

                switch context.state.mode {
                case .countdown:
                    Text("In progress")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                case .paused:
                    Text("Paused")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                case .alert:
                    Text("Time's up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }

            Spacer()

            AlarmCountdownText(state: context.state)
                .font(.title2.monospacedDigit().bold())
        }
        .padding()
    }
}

@available(iOS 26.0, *)
private struct AlarmCountdownText: View {
    let state: AlarmPresentationState

    var body: some View {
        switch state.mode {
        case .countdown(let info):
            Text(timerInterval: Date.now...info.fireDate, countsDown: true)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        case .paused(let info):
            let remaining = max(0, info.totalCountdownDuration - info.previouslyElapsedDuration)
            Text(formattedTime(remaining))
                .monospacedDigit()
        case .alert:
            Image(systemName: "alarm.waves.left.and.right")
        @unknown default:
            Text("--:--")
        }
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

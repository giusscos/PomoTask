//
//  TomaTaskLiveActivity.swift
//  TomaTaskWidgets
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TomaTaskLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TomaTaskActivityAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(
                        context.state.isBreak ? "Break" : "Focus",
                        systemImage: context.state.isBreak ? "cup.and.saucer.fill" : "brain.head.profile"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isPaused {
                        Text(formattedTime(context.state.timeRemainingWhenPaused))
                            .font(.title2.monospacedDigit().bold())
                    } else {
                        Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                            .font(.title2.monospacedDigit().bold())
                            .multilineTextAlignment(.trailing)
                            .frame(width: 70)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.taskTitle)
                        .font(.headline)
                        .lineLimit(1)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.isPaused ? "Paused" : (context.state.isBreak ? "Break in progress" : "Focus in progress"))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Link(destination: URL(string: "tomatask://pause")!) {
                            Label("Pause", systemImage: "pause.fill")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .opacity(context.state.isPaused ? 0.4 : 1)
                        .disabled(context.state.isPaused)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.isBreak ? "cup.and.saucer.fill" : "timer")
                    .foregroundStyle(context.state.isBreak ? .orange : .accentColor)
            } compactTrailing: {
                if context.state.isPaused {
                    Text(formattedTime(context.state.timeRemainingWhenPaused))
                        .font(.caption.monospacedDigit())
                } else {
                    Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        .font(.caption.monospacedDigit())
                        .frame(width: 50)
                        .multilineTextAlignment(.trailing)
                }
            } minimal: {
                Image(systemName: context.state.isBreak ? "cup.and.saucer.fill" : "timer")
            }
            .widgetURL(URL(string: "tomatask://timer"))
            .keylineTint(context.state.isBreak ? .orange : .accentColor)
        }
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TomaTaskActivityAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.taskTitle)
                    .font(.headline)
                    .lineLimit(1)

                Text(context.state.isBreak ? "Break" : "Focus")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                if context.state.isPaused {
                    Text(formattedTime(context.state.timeRemainingWhenPaused))
                        .font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
                    Text("Paused")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        .font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 100, alignment: .trailing)
                }

                Link(destination: URL(string: "tomatask://pause")!) {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .opacity(context.state.isPaused ? 0.4 : 1)
                .disabled(context.state.isPaused)
            }
        }
        .padding()
        .activityBackgroundTint(Color.black.opacity(0.2))
        .activitySystemActionForegroundColor(.primary)
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

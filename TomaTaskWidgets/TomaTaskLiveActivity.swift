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
            let tint = TimerLiveActivityStyle.phaseColor(isBreak: context.state.isBreak)

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🍅")
                            .font(.title2)

                        Spacer(minLength: 4)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.taskTitle)
                                .font(.headline.weight(.bold))
                                .fontDesign(.rounded)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)

                            Text(expandedStatus(for: context.state))
                                .font(.caption.weight(.semibold))
                                .fontWidth(.condensed)
                                .textCase(.uppercase)
                                .tracking(1.0)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: 140, maxHeight: .infinity, alignment: .leading)
                    .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 6) {
                        Link(destination: URL(string: context.state.isPaused ? "tomatask://play" : "tomatask://pause")!) {
                            Image(systemName: context.state.isPaused ? "play.circle.fill" : "pause.circle.fill")
                                .font(.system(size: 36))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .accessibilityLabel(context.state.isPaused ? "Play" : "Pause")

                        Spacer(minLength: 4)

                        Group {
                            if context.state.isPaused {
                                Text(formattedTime(context.state.timeRemainingWhenPaused))
                            } else {
                                Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                            }
                        }
                        .font(.system(size: 34, weight: .heavy, design: .rounded).monospacedDigit())
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(minWidth: 110, alignment: .trailing)
                    }
                    .frame(minWidth: 110, maxHeight: .infinity, alignment: .trailing)
                    .padding(.trailing, 4)
                }
            } compactLeading: {
                Text("🍅")
                    .font(.body)
            } compactTrailing: {
                if context.state.isPaused {
                    Text(formattedTime(context.state.timeRemainingWhenPaused))
                        .font(.caption.weight(.bold).monospacedDigit())
                        .fontDesign(.rounded)
                        .foregroundStyle(tint)
                } else {
                    Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        .font(.caption.weight(.bold).monospacedDigit())
                        .fontDesign(.rounded)
                        .foregroundStyle(tint)
                        .frame(width: 50)
                        .multilineTextAlignment(.trailing)
                }
            } minimal: {
                Text("🍅")
                    .font(.body)
            }
            .widgetURL(URL(string: "tomatask://timer"))
            .keylineTint(tint)
        }
    }

    private func expandedStatus(for state: TomaTaskActivityAttributes.ContentState) -> String {
        if state.isPaused {
            return state.isBreak ? "Break · Paused" : "Focus · Paused"
        }
        return state.isBreak ? "Break" : "Focus"
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Lock Screen

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TomaTaskActivityAttributes>

    private var phaseColor: Color {
        TimerLiveActivityStyle.phaseColor(isBreak: context.state.isBreak)
    }

    private var phaseLabel: String {
        if context.state.isPaused {
            return context.state.isBreak ? "Break · Paused" : "Focus · Paused"
        }
        return context.state.isBreak ? "Break" : "Focus"
    }

    var body: some View {
        ZStack(alignment: .top) {
            phaseColor

            Image("tomato_stem")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .offset(y: -46)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
//                    Text("🍅")
//                        .font(.title2)

                    Spacer(minLength: 8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.taskTitle)
                            .font(.title3.weight(.bold))
                            .fontDesign(.rounded)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(phaseLabel)
                            .font(.subheadline.weight(.semibold))
                            .fontWidth(.condensed)
                            .opacity(0.75)
                            .textCase(.uppercase)
                            .tracking(1.2)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 6) {
                    Link(destination: URL(string: context.state.isPaused ? "tomatask://play" : "tomatask://pause")!) {
                        Image(systemName: context.state.isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                    }
                    .accessibilityLabel(context.state.isPaused ? "Play" : "Pause")

                    Spacer(minLength: 8)

                    Group {
                        if context.state.isPaused {
                            Text(formattedTime(context.state.timeRemainingWhenPaused))
                        } else {
                            Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        }
                    }
                    .font(.system(size: 36, weight: .heavy, design: .rounded).monospacedDigit())
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(minWidth: 100, alignment: .trailing)
                }
            }
            .frame(minHeight: 88)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
        }
        .activityBackgroundTint(phaseColor)
        .activitySystemActionForegroundColor(.white)
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

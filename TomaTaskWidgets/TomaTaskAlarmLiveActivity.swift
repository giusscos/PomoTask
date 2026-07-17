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
            let isBreak = context.attributes.metadata?.isBreak == true
            let tint = TimerLiveActivityStyle.phaseColor(isBreak: isBreak)

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🍅")
                            .font(.title2)

                        Spacer(minLength: 4)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(isBreak ? "Break" : "Focus")
                                .font(.headline.weight(.bold))
                                .fontDesign(.rounded)
                                .lineLimit(1)

                            Text(alarmStatusLabel(for: context.state.mode))
                                .font(.caption.weight(.semibold))
                                .fontWidth(.condensed)
                                .textCase(.uppercase)
                                .tracking(1.0)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: 140, maxHeight: .infinity, alignment: .leading)
                    .padding(.leading, 6)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 6) {
                        alarmPlayPauseLink(for: context.state.mode)

                        Spacer(minLength: 4)

                        AlarmCountdownText(state: context.state)
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
                AlarmCountdownText(state: context.state)
                    .font(.caption.weight(.bold).monospacedDigit())
                    .fontDesign(.rounded)
                    .foregroundStyle(tint)
                    .frame(width: 50)
            } minimal: {
                Text("🍅")
                    .font(.body)
            }
            .keylineTint(tint)
        }
    }

    private func alarmStatusLabel(for mode: AlarmPresentationState.Mode) -> String {
        switch mode {
        case .countdown:
            return "In progress"
        case .paused:
            return "Paused"
        case .alert:
            return "Time's up"
        @unknown default:
            return "In progress"
        }
    }

    @ViewBuilder
    private func alarmPlayPauseLink(for mode: AlarmPresentationState.Mode) -> some View {
        switch mode {
        case .paused:
            Link(destination: URL(string: "tomatask://play")!) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .accessibilityLabel("Play")
        case .countdown:
            Link(destination: URL(string: "tomatask://pause")!) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 36))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .accessibilityLabel("Pause")
        default:
            Image(systemName: "play.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.35))
                .accessibilityHidden(true)
        }
    }
}

@available(iOS 26.0, *)
private struct AlarmLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<TomaTaskAlarmMetadata>>

    private var isBreak: Bool {
        context.attributes.metadata?.isBreak == true
    }

    private var phaseColor: Color {
        TimerLiveActivityStyle.phaseColor(isBreak: isBreak)
    }

    private var statusLabel: String {
        switch context.state.mode {
        case .paused:
            return "Paused"
        case .alert:
            return "Time's up"
        case .countdown:
            return "In progress"
        @unknown default:
            return "In progress"
        }
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
                    Text("🍅")
                        .font(.title2)

                    Spacer(minLength: 8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(isBreak ? "Break" : "Focus")
                            .font(.title3.weight(.bold))
                            .fontDesign(.rounded)
                            .lineLimit(1)

                        Text(statusLabel)
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
                    alarmLockScreenPlayPause(for: context.state.mode)

                    Spacer(minLength: 8)

                    AlarmCountdownText(state: context.state)
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

    @ViewBuilder
    private func alarmLockScreenPlayPause(for mode: AlarmPresentationState.Mode) -> some View {
        switch mode {
        case .paused:
            Link(destination: URL(string: "tomatask://play")!) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
            }
            .accessibilityLabel("Play")
        case .countdown:
            Link(destination: URL(string: "tomatask://pause")!) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
            }
            .accessibilityLabel("Pause")
        default:
            EmptyView()
        }
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

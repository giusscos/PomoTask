//
//  TomaTaskTimerWidget.swift
//  TomaTaskWidgets
//

import AppIntents
import SwiftUI
import WidgetKit

/// Home Screen control for starting / pausing a focus session without opening the app.
struct TomaTaskTimerWidget: Widget {
    let kind = SharedTimerStore.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerWidgetProvider()) { entry in
            TimerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Focus Timer")
        .description("Start or pause a Progressive focus session from your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Timeline

struct TimerWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedTimerStore.Snapshot
}

struct TimerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimerWidgetEntry {
        TimerWidgetEntry(date: .now, snapshot: .idle)
    }

    func getSnapshot(in context: Context, completion: @escaping (TimerWidgetEntry) -> Void) {
        completion(TimerWidgetEntry(date: .now, snapshot: SharedTimerStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerWidgetEntry>) -> Void) {
        let snapshot = SharedTimerStore.load()
        let entry = TimerWidgetEntry(date: .now, snapshot: snapshot)

        if snapshot.isActive, snapshot.isRunning {
            completion(Timeline(entries: [entry], policy: .after(snapshot.endDate)))
        } else {
            completion(Timeline(entries: [entry], policy: .never))
        }
    }
}

// MARK: - Views

struct TimerWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: TimerWidgetEntry

    private var phaseColor: Color {
        TimerLiveActivityStyle.phaseColor(isBreak: entry.snapshot.isBreak)
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallTimerWidgetView(entry: entry)
            default:
                MediumTimerWidgetView(entry: entry)
            }
        }
        .containerBackground(for: .widget) {
            phaseColor
        }
    }
}

// MARK: - Shared chrome

private struct WidgetPlayPauseButton: View {
    let isRunning: Bool
    var size: CGFloat = 36

    var body: some View {
        Button(intent: ToggleFocusTimerIntent()) {
            Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: size))
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRunning ? "Pause" : "Play")
    }
}

private struct WidgetCountdownText: View {
    let snapshot: SharedTimerStore.Snapshot
    var fontSize: CGFloat
    var alignment: Alignment = .center

    var body: some View {
        Group {
            if snapshot.isActive, snapshot.isRunning {
                Text(timerInterval: Date.now...snapshot.endDate, countsDown: true)
            } else {
                Text(SharedTimerStore.formatted(snapshot.displayedRemaining))
            }
        }
        .font(.system(size: fontSize, weight: .heavy, design: .rounded).monospacedDigit())
        .multilineTextAlignment(textAlignment)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, alignment: alignment)
    }

    private var textAlignment: TextAlignment {
        switch alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }
}

// MARK: - Small

private struct SmallTimerWidgetView: View {
    let entry: TimerWidgetEntry

    private var phaseColor: Color {
        TimerLiveActivityStyle.phaseColor(isBreak: entry.snapshot.isBreak)
    }

    var body: some View {
        ZStack(alignment: .top) {
            phaseColor

            Image("tomato_stem")
                .resizable()
                .scaledToFit()
                .frame(width: 88)
                .offset(y: -30)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            VStack(spacing: 6) {
                Spacer(minLength: 18)

                WidgetCountdownText(snapshot: entry.snapshot, fontSize: 28)

                Text(entry.snapshot.subtitle)
                    .font(.caption2.weight(.semibold))
                    .fontWidth(.condensed)
                    .opacity(0.75)
                    .textCase(.uppercase)
                    .tracking(1.0)

                Spacer(minLength: 2)

                WidgetPlayPauseButton(isRunning: entry.snapshot.isRunning, size: 36)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
            .foregroundStyle(.white)
        }
    }
}

// MARK: - Medium

private struct MediumTimerWidgetView: View {
    let entry: TimerWidgetEntry

    private var phaseColor: Color {
        TimerLiveActivityStyle.phaseColor(isBreak: entry.snapshot.isBreak)
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
                VStack(alignment: .leading, spacing: 4) {
                    Spacer(minLength: 8)

                    Text(entry.snapshot.title)
                        .font(.title3.weight(.bold))
                        .fontDesign(.rounded)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(entry.snapshot.subtitle)
                        .font(.subheadline.weight(.semibold))
                        .fontWidth(.condensed)
                        .opacity(0.75)
                        .textCase(.uppercase)
                        .tracking(1.2)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 6) {
                    WidgetPlayPauseButton(isRunning: entry.snapshot.isRunning, size: 36)

                    Spacer(minLength: 8)

                    WidgetCountdownText(
                        snapshot: entry.snapshot,
                        fontSize: 36,
                        alignment: .trailing
                    )
                    .frame(minWidth: 100)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
        }
        .widgetURL(URL(string: "tomatask://timer"))
    }
}

#Preview("Small", as: .systemSmall) {
    TomaTaskTimerWidget()
} timeline: {
    TimerWidgetEntry(date: .now, snapshot: .idle)
}

#Preview("Medium", as: .systemMedium) {
    TomaTaskTimerWidget()
} timeline: {
    TimerWidgetEntry(date: .now, snapshot: .idle)
}

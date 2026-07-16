//
//  TaskView.swift
//  TomaTask
//

import SwiftUI
import TipKit

struct StartTimerTip: Tip {
    var title: Text { Text("Start your session") }
    var message: Text? { Text("Tap the button to start or pause. The dial scrolls automatically as time passes.") }
    var image: Image? { Image(systemName: "timer") }
}

/// Minimal tomato-timer session: fixed red field, centered dial, dedicated play/pause button.
struct TaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Store.self) private var store
    
    @State var task: TomaTask
    @State private var engine = SessionTimerEngine()
    
    @AppStorage(SessionAlertStorage.alarmEnabled) private var alarmEnabled = true
    @AppStorage("preventScreenLock") private var preventScreenLock = true
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private let tomatoRed = Color(red: 0.86, green: 0.14, blue: 0.14)
    private let breakRed = Color(red: 0.72, green: 0.22, blue: 0.28)
    private let startTimerTip = StartTimerTip()
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = verticalSizeClass == .compact
            let stemWidth = min(geo.size.width, geo.size.height)
            
            ZStack(alignment: .top) {
                (engine.isBreak ? breakRed : tomatoRed)
                    .ignoresSafeArea()
                
                PomodoroStemView()
                    .frame(width: stemWidth)
                    .offset(y: -stemWidth * 0.32)
                    .allowsHitTesting(false)
                    .ignoresSafeArea(edges: .top)
                    .zIndex(2)
                
                VStack(spacing: 0) {
                    if isLandscape {
                        Spacer(minLength: 0)
                            .frame(maxHeight: 4)
                    } else {
                        Spacer(minLength: 0)
                    }
                    
                    dialSection
                        .padding(.horizontal, 8)
                    
                    Spacer(minLength: isLandscape ? 4 : 8)
                        .frame(maxHeight: isLandscape ? 4 : 20)
                    
                    playPauseButton
                        .popoverTip(startTimerTip, arrowEdge: .bottom)
                    
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .foregroundStyle(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    if engine.isComplete {
                        Text("Done")
                            .font(.headline.weight(.bold))
                            .fontDesign(.rounded)
                    } else {
                        Text(task.title.isEmpty ? "Pomodoro" : task.title)
                            .font(.title3.weight(.bold))
                            .fontDesign(.rounded)
                            .lineLimit(1)

                        HStack (spacing: 8) {
                            Text(engine.isBreak ? "Break" : "Focus")
                            
                            Text("\(engine.repetition)/\(task.repetition)")
                        }
                        .font(.subheadline.weight(.semibold))
                        .fontWidth(.condensed)
                        .opacity(0.75)
                        .textCase(.uppercase)
                        .tracking(1.2)
                    }
                }
                .foregroundStyle(.white)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        alarmEnabled.toggle()
                        if !alarmEnabled {
                            AlarmPlayer.shared.stop()
                            SessionAlarmScheduler.cancel()
                        }
                    } label: {
                        Label(
                            alarmEnabled ? "Alarm Sound: On" : "Alarm Sound: Off",
                            systemImage: alarmEnabled
                                ? "bell.and.waves.left.and.right.fill"
                                : "bell.slash.fill"
                        )
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.default, value: alarmEnabled)
                    }
                    
                    Button {
                        preventScreenLock.toggle()
                        UIApplication.shared.isIdleTimerDisabled = preventScreenLock
                    } label: {
                        Label(
                            preventScreenLock ? "Screen Always On" : "Screen Auto-Lock",
                            systemImage: preventScreenLock ? "sun.max.fill" : "moon.zzz.fill"
                        )
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.default, value: preventScreenLock)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .onAppear {
            engine.configure(
                task: task,
                modelContext: modelContext,
                useSolidFill: false
            )
            UIApplication.shared.isIdleTimerDisabled = preventScreenLock
        }
        .onDisappear {
            engine.tearDown()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            engine.handleResignActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            engine.handleBecomeActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: .tomaTaskDeepLink)) { notification in
            guard let path = notification.userInfo?["path"] as? String, path == "pause" else { return }
            engine.handleDeepLinkPause()
        }
        .statusBarHidden(false)
    }
    
    // MARK: - Dial
    
    private var dialSection: some View {
        PomodoroDialPicker(
            formattedTime: engine.formattedTime,
            remainingMinutes: engine.remainingMinutes,
            maxMinutes: engine.phaseDurationMinutes,
            isInteractive: false,
            onWind: { _ in }
        )
    }
    
    // MARK: - Play / Pause
    
    private var playPauseButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            engine.togglePlayPause()
            startTimerTip.invalidate(reason: .actionPerformed)
        } label: {
            Image(systemName: engine.isRunning ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: verticalSizeClass == .compact ? 48 : 64))
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(engine.isRunning ? "Pause" : "Start")
    }
}

#Preview {
    TabView {
        Tab("Classic", systemImage: "timer") {
            NavigationStack {
                TaskView(task: TomaTask(title: "Deep Work", maxDuration: 25, pauseDuration: 5, repetition: 4))
            }
        }
        
        Tab("Progressive", systemImage: "dial.medium") {
            NavigationStack {
                ProgressiveTimerView()
            }
        }
    }
    .environment(Store())
    .task { try? Tips.configure([.displayFrequency(.immediate)]) }
}

# TomaTask — Improvements & Feature Roadmap Prompt

> Hand this document to an AI assistant (or use it as a personal backlog) to guide the next phase of TomaTask development. Every section contains concrete, actionable tasks grounded in the current codebase state.

---

## 1. Codebase Context

**Stack:** SwiftUI · SwiftData · StoreKit 2 · WatchKit · UserNotifications  
**Targets:** iOS (iPhone + iPad) · watchOS  
**Models:** `TomaTask`, `SubTask`, `Statistics`  
**Tabs:** Statistics → Progressive Timer → Classic Timers → Settings  
**Subscription:** Monthly (`pt_499_1m_7d0`) / Yearly (`pt_4999_1y_7d0`) via group `21571698`

---

## 2. Code Quality & Bug Fixes

### 2.1 Architecture

- **`Store` is instantiated as `@State var store = Store()` in five different views** (`ProgressiveTimerView`, `TaskView`, `StatisticsView`, `WatchStatisticsView`, `SettingsView`). Each creates an independent StoreKit listener and subscription checker. Fix: inject a single `Store` instance from `TomaTaskApp` via `.environment()`.

- **`screenSize` uses `UIScreen.main.bounds.height`**, which is deprecated since iOS 16. Replace with `UIScreen.main.bounds.height` → `@Environment(\.mainWindowSize)` or use `GeometryReader` inside the relevant views.

- **`defaultTimeStart`, `defaultMinSeconds`, `defaultMaxSeconds` are declared as global `let` constants in both `ProgressiveTimerView.swift` (iOS) and `WatchProgressiveTimerView.swift` (watchOS)**, causing a name collision if they ever share a module. Move them to a shared `TimerConstants` enum.

- **Color hex conversion** (`colorToHexString` / `hexStringToColor`) is copy-pasted identically in both `ProgressiveTimerView` and `TaskView`. Extract to a `Color+Hex.swift` extension.

- **`selectedCategory` in `TomaTasksList`** is initialized to `.study` and passed to `EditTask.onAppear` but never used for filtering the list. Either implement the filter or remove the dead state variable.

### 2.2 Timer Bugs

- **`TaskView` defines `startBackgroundTimer()` / `stopBackgroundTimer()` / `updateTimerFromBackground()` but never calls them.** The `.onReceive(NotificationCenter…willResignActiveNotification)` observers present in `ProgressiveTimerView` are missing from `TaskView`. This means the Classic timer does not survive backgrounding. Add the same `onReceive` hooks to `TaskView`.

- **`Statistics.getDailyStats` is called inside the timer closure every second** for `totalFocusTime += 1`. The fetch + potential insert runs 60 times per minute. Fetch the stats object once before the timer starts, hold it in a local variable, and save at the end of each session instead of every tick.

- **`FeedbackSheet.useTheSameTime()`** decreases `selectedTime` by `defaultMinSeconds` when the user chooses "I need less time", but there is no lower-bound check aligning with the minimum displayed time. Verify the boundary matches `defaultMinSeconds`.

- **`WatchTaskView` has no notification scheduling.** When the watch app backgrounds the timer, it silently stops. Add `WKExtendedRuntimeSession` for workout-style background execution and schedule a local notification on the watch.

### 2.3 UI / UX Polish

- **`dimDisplay` / auto-lock** is wired up, the binding exists, the `UIApplication.shared.isIdleTimerDisabled = true` call is in `TimerActions.onAppear`, but the toggle button is commented out. Decide: either expose it as a user-facing toggle or remove the dead binding and `@State` variable entirely.

- **`TaskRow` shows no category indicator.** `TomaTask` has a `category` property with emoji labels but it is never displayed in the list. Show it as a badge or subtitle.

- **`EditTask` uses `WheelPickerStyle` for both duration pickers side-by-side**, which is unusable on smaller iPhones because the wheels overflow. Replace with a single inline stepper or use a `.menu` picker style.

- **`EditTask` has no `navigationTitle` and no dismiss button** when presented as a sheet on iPad (where sheets are not full-screen). Add a toolbar "Done" button.

- **The `TomaTasksList` empty state** shows "No tasks in this category yet!" even though there is no category filter active. Fix the copy to "No timers yet".

---

## 3. New Features

### 3.1 Live Activities (Dynamic Island + Lock Screen)

Implement `ActivityKit` so a running timer appears on the Dynamic Island and the Lock Screen widget.

**Steps:**
1. Add an `ActivityAttributes` struct (`TomaTaskActivityAttributes`) with `ContentState` carrying `timeRemaining: TimeInterval`, `isBreak: Bool`, `taskTitle: String`.
2. Create a Widget Extension target (if not present) and add `ActivityConfiguration` views for compact, minimal, and expanded presentations.
3. In `startTimer()` (both `ProgressiveTimerView` and `TaskView`), call `Activity<TomaTaskActivityAttributes>.request(...)`.
4. Update the activity state each minute (not every second — ActivityKit throttles updates).
5. Call `activity.end(...)` in `resetTimer()` / `pauseTimer()` when the session completes.
6. The expanded Lock Screen widget should show: timer name, time remaining (large), focus/break label, and a "Pause" deep-link button.

### 3.2 Home Screen Widgets

Add a WidgetKit extension with three widget sizes:

| Widget | Size | Content |
|---|---|---|
| **Today's Focus** | Small | Total focus minutes today (ring chart) |
| **Active Timer** | Medium | Timer name + time remaining + start/pause button |
| **Weekly Progress** | Large | Bar chart of focus time per day this week |

The Today's Focus and Weekly Progress widgets read from SwiftData directly via App Group container. The Active Timer widget requires a shared `UserDefaults` (App Group) to know if a timer is running (SwiftData cannot be read from a widget process without an App Group).

### 3.3 Apple Watch — Deep Integration

Currently the Watch app is an independent companion that shares SwiftData storage but has no live state sync with the iPhone.

**Improvements:**

- **WatchConnectivity bridge:** Create a `WatchSessionManager` (`@Observable`) that uses `WCSession` to:
  - Mirror timer start/pause/stop from iPhone → Watch and vice versa.
  - Push the current timer state (time remaining, task name, is-break) to the Watch every 30 seconds while a timer runs.
  - Let the Watch control an iPhone-running timer when the phone is in pocket.
- **Complications:** Add a ClockKit/WidgetKit complication showing today's focus minutes. Sizes: corner, modular, circular.
- **Always-On Display:** Add an `TimelineProvider` entry for the watch face that updates the timer every minute.
- **Digital Crown scrubbing:** On the Watch's progressive timer, use `focusable` + `.digitalCrownRotation` to let the user scrub the initial timer duration.
- **Haptic patterns:** Replace the single `.notification` haptic with context-appropriate haptics: `.start` when the timer begins, `.stop` when it ends, `.retry` when break ends.

### 3.4 Enhanced Notifications

Current notifications fire once at timer completion with generic copy.

**Improvements:**
- **Actionable notifications:** Add `UNNotificationCategory` with actions: "Take a Break" and "Keep Going" so the user can respond without opening the app.
- **Notification handler:** In `UNUserNotificationCenterDelegate.didReceive(_:withCompletionHandler:)`, handle these actions by updating timer state.
- **Break reminder:** After a 5-minute break, send a "Ready to focus again?" notification.
- **Daily summary:** At 9 PM, send a digest notification: "You focused X minutes today across Y sessions" (opt-in, configurable time).
- **Motivational copy:** Rotate through a list of contextual messages based on time-of-day and session length.

### 3.5 Per-Task Color Themes

Currently all timers share a single global color stored in `AppStorage`. Each `TomaTask` should carry its own `colorHex: String` and `colorMode: String` properties so each task has its own visual identity.

**Model change:**
```swift
// In TomaTask.swift
var colorHex: String = "#000000"
var colorMode: String = "solid" // "solid" | "mesh"
// For mesh: add meshColor2Hex and meshColor3Hex
```

**UI change:** In `TaskView`, load colors from `task.colorHex` instead of `AppStorage`. The global `AppStorage` colors become the default for new tasks.

### 3.6 Streak & Goal Tracking

Add to `Statistics` (or a new `UserGoal` model):

- **Daily focus goal:** User sets a target (e.g. 90 minutes). Progress ring shown on the Statistics tab.
- **Streak:** Count consecutive days the user met their goal. Display as a flame badge on the Statistics tab icon.
- **Longest streak:** Stored in `AppStorage` or a `UserGoal` SwiftData model.
- **Weekly goal:** Set a total focus-minutes-per-week target with a ring chart.

### 3.7 Focus Modes & Shortcuts

- **App Intents / Siri Shortcuts:** Expose `StartTimerIntent` (start a named timer), `PauseTimerIntent`, and `GetTodaysFocusIntent` (returns total focus minutes). Decorate with `@AssistantSchemas` for natural-language Siri.
- **Focus Filter:** Implement `FocusFilterIntent` so TomaTask can be associated with a Focus mode. When "Work Focus" is enabled, automatically start the user's default work timer.

### 3.8 Sound & Ambient Audio

- **Multiple alarm sounds:** Offer a picker (bell, chime, bowl, digital) stored in `AppStorage("alarmSoundID")`. Use `AVAudioPlayer` to preview and play.
- **Ambient sound during focus:** Optional background loops (rain, cafe, white noise). Plays at low volume through `AVAudioSession` with `.mixWithOthers` so music apps keep playing. Gated behind the Pro subscription.

### 3.9 iCloud Sync

- The `ModelContainer` in `TomaTaskApp` is initialized without `isStoredInMemoryOnly` or a CloudKit identifier. To enable iCloud sync, change to `ModelConfiguration(cloudKitDatabase: .automatic)`. Requires:
  1. Enable CloudKit capability in the entitlements.
  2. Add `CKContainer` identifier in `Info.plist`.
  3. Handle the `NSPersistentCloudKitContainer` merge policy.
  4. Test sync conflicts (both devices editing the same task simultaneously).

---

## 4. Design & Customization

### 4.1 Liquid Glass (iOS 26)

iOS 26 introduces Liquid Glass — a new material that merges refraction with translucency. Adopt it:

- The floating control overlay (`TimerActions`) is a perfect candidate. Replace `.ultraThinMaterial` capsule backgrounds with a `GlassEffect` modifier.
- The sheet drag indicator area can use Liquid Glass tinting that matches the current timer color.
- Research `GlassEffect` in WidgetKit for the Active Timer widget.

### 4.2 Animated Timer Visualizations

Currently: solid fill rising/falling or mesh gradient. Add more modes (Pro-gated):

- **Ring timer:** Classic circular countdown ring using `Canvas` + `Path`. Animates arc from 2π to 0.
- **Particle burst:** On timer completion, a `TimelineView`-driven particle explosion using `Canvas`.
- **Breathing circle:** A pulsing circle that expands/contracts at the user's intended breathing rate (4-7-8 pattern or box breathing) during breaks.
- **Wave timer:** An animated sine wave that rises as time passes, using `Canvas` + `TimelineView`.

Each mode is a separate view conforming to a `TimerBackground` protocol, making it easy to add new ones.

### 4.3 Themes System

Replace the per-color `AppStorage` keys with a `Theme` struct:

```swift
struct TimerTheme: Codable, Identifiable {
    var id: UUID
    var name: String
    var colorMode: String       // "solid" | "mesh" | "ring" | "wave"
    var primaryHex: String
    var secondaryHex: String
    var tertiaryHex: String
    var backgroundStyle: String // "fill" | "glass" | "blur"
}
```

Ship 6 built-in themes (free: Midnight, Forest; Pro: Sunset, Ocean, Neon, Pastel). Allow users to create and save custom themes. Store custom themes in SwiftData.

### 4.4 Dynamic Category Colors

Each `TomaTask.Category` maps to a system color:

| Category | Color |
|---|---|
| Work | `.blue` |
| Study | `.purple` |
| Home | `.green` |
| Wealth | `.orange` |

Use the category color as the default timer accent, the task row indicator, and the Live Activity tint.

### 4.5 Haptic Design

Define a `HapticEngine` helper that maps timer events to haptic patterns:
- Timer start → `.impactOccurred(intensity: 0.6)`
- Timer end → 3× `.impactOccurred(intensity: 1.0)` with 100ms gaps
- Break start → `.notificationOccurred(.success)`
- Subtask checked → `.selectionChanged()`
- Color picker drag → `.impactOccurred(intensity: 0.3)` on hue change

### 4.6 Onboarding Flow

The first launch shows `WhatsNewView` which is generic. Replace with a proper onboarding:

1. **Screen 1:** Animated timer demo (the mesh gradient plays automatically)
2. **Screen 2:** "Set your first timer" — inline `EditTask` pre-filled with sensible defaults
3. **Screen 3:** Notification permission request with context ("We'll remind you when your break ends")
4. **Screen 4:** Watch pairing prompt if an Apple Watch is paired

---

## 5. Apple Watch — Specific Improvements

### 5.1 Missing Background Execution

`WatchTaskView` and `WatchProgressiveTimerView` use a plain `Timer` which stops when the watch face returns to the clock. Use `WKExtendedRuntimeSession` with `.workout` or `.smartAlarm` behavior so timers keep running with the display off.

### 5.2 Complications

Add a WidgetKit-based complication family:
- **Circular:** Filled ring representing today's focus progress toward goal
- **Corner:** Time remaining if a timer is active, otherwise today's minutes
- **Rectangular:** Task name + timer countdown

Complications read from App Group `UserDefaults` written by the watch app.

### 5.3 Mirror iPhone Timer on Watch

When the user starts a timer on the iPhone, the Watch should show a "Running on iPhone" view with a live countdown. Implement via `WCSession.sendMessage` and a shared `TimerState` Codable.

### 5.4 Watch Task Creation UX

`WatchEditTask` exists but the form UX is cumbersome on a small screen. Improve:
- Replace the wheel pickers with Digital Crown-driven steppers.
- Add voice dictation via `WKTextInputMode.plain` for the task title.
- Add a "Quick Start" button: jumps directly to a 25/5 Pomodoro without naming.

---

## 6. Statistics Improvements

- **Yearly view:** Add `.year` case to `TimeRange` with a month-bucketed bar chart.
- **Best day / best week:** Compute and display personal records.
- **Focus score:** A single normalized score (0–100) combining sessions completed, goal hit, and streak maintained. Displayed as a large number with a trend arrow.
- **Category breakdown:** Pie/donut chart showing focus time per `TomaTask.Category`.
- **Export:** Share button that exports statistics as a CSV or generates a shareable image card.
- **Confetti / celebration:** When the user hits their daily goal, trigger a `confetti` particle effect using Canvas.

---

## 7. Subscription & Monetization

- **Free tier is unclear.** Define explicitly what is free: the Classic timer (all features), the Progressive timer (basic), and one default theme. Gate: gradient themes, custom colors per-task, additional timer visualizations, statistics, ambient sounds, complications.
- **Family sharing:** The current `SubscriptionStoreView` does not enable family sharing. Add `.storeButton(.visible, for: .redeemCode)` and ensure the entitlement is checked server-side or via `Transaction.currentEntitlements` (already done).
- **Paywall placement:** The Statistics tab shows a paywall immediately. Consider showing a 7-day free preview of statistics before gating it, to demonstrate value.
- **Refund flow:** `SettingsView` shows a "Request a refund" button that opens `SubscriptionStoreView` — this should open `StoreKit.beginRefundRequest` instead.

---

## 8. Technical Debt Checklist

| Issue | File | Severity |
|---|---|---|
| `Store` instantiated 5× | Multiple views | High |
| Background timer missing in `TaskView` | `TaskView.swift:335` | High |
| Stats fetched every second in timer loop | `TaskView.swift:267`, `ProgressiveTimerView.swift:233` | High |
| Color hex logic duplicated | `TaskView.swift:225`, `ProgressiveTimerView.swift:192` | Medium |
| `screenSize` uses deprecated `UIScreen.main` | `TabBarViewController.swift:19` | Medium |
| `selectedCategory` unused | `TomaTasksList.swift:17` | Low |
| `dimDisplay` binding dead code | `TimerActions.swift:67` | Low |
| Global var naming collision | `ProgressiveTimerView.swift:12`, Watch counterpart | Low |
| `EditTask` missing dismiss button on iPad | `EditTask.swift` | Medium |
| `TaskRow` ignores `.category` | `TaskRow.swift` | Low |

---

## 9. Implementation Order (Suggested)

1. Fix `Store` singleton injection (unblocks subscription gating everywhere)
2. Fix `TaskView` background timer (critical bug)
3. Fix stats performance (timer loop)
4. Extract `Color+Hex` extension
5. Live Activities (highest visual impact, strong App Store differentiator)
6. Apple Watch `WKExtendedRuntimeSession` + complications
7. Per-task color themes (model + UI)
8. Themes system
9. Streak + Goals
10. WidgetKit home screen widgets
11. WatchConnectivity timer sync
12. Animated timer visualizations
13. Ambient audio
14. Shortcuts / App Intents
15. iCloud Sync
16. Yearly statistics + export

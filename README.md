# Counter_app

**MISBAH — Goal Counter** is a Flutter tally counter with a dark design. The count sits inside a progress ring that fills towards a goal you set. Tap the fingerprint button to count up. Your count, goal, undo history and vibration setting are saved on the device, so they are still there when you reopen the app.

---

## Features

- **Progress ring:** the count is shown in the middle of a blue ring that fills towards your goal. Under the count it says how many are left ("6 to go"), "goal reached". With no goal the ring stays full, and "no goal set" shows only until counting starts. Long numbers shrink to fit inside the ring.
- **Goal:** there is no goal until you set one. The target button opens a dialog where you enter a goal from 1 to 99,999 or remove the current goal, and the goal is saved.
- **Goal reached:** counting stops at the goal and a dialog asks what comes next. Set a new goal or continue without one; either way the count starts again from 0.
- **Fingerprint count button:** a round button with a fingerprint icon is the only way to count. It uses a `GestureDetector` with a ripple that spreads from where you touch, and presses down slightly. The ring only displays the count, and tapping anywhere else on the screen does nothing. Keyboard (Tab, then Enter) and screen readers also work through the button.
- **Reset:** set the count back to 0. There is no undo button at the moment; the undo logic remains in the BLoC.
- **Vibration toggle:** a light tick on each count and a firmer pulse on reset. You can turn it on or off, and the setting is saved.
- **Persistence:** the count, goal, undo history and vibration setting are stored with `shared_preferences`. The saved count is loaded before the first frame, so the screen never shows a placeholder value.
- **No lost taps:** events are processed one at a time in order, so rapid tapping never drops a count.
- **Error handling:** if saving or loading fails, a SnackBar tells you. Corrupt stored values are cleaned up instead of crashing the app.
- **Accessibility:** semantic labels for the counter and every control, keyboard support, the ring and ripple animations are skipped when the system asks for reduced motion, and the layout scales down on small screens with large text.
- **Portrait only**, with a dark theme and the Switzer font.

---

## Tech stack

| Purpose | Package |
|---|---|
| State management | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc), [`bloc`](https://pub.dev/packages/bloc) |
| Ordered event processing | [`bloc_concurrency`](https://pub.dev/packages/bloc_concurrency) (`sequential()`) |
| Value equality | [`equatable`](https://pub.dev/packages/equatable) |
| Dependency injection | [`get_it`](https://pub.dev/packages/get_it) |
| Local storage | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |
| Testing | `flutter_test`, [`bloc_test`](https://pub.dev/packages/bloc_test), [`mocktail`](https://pub.dev/packages/mocktail) |
| Linting | [`flutter_lints`](https://pub.dev/packages/flutter_lints) |

- Dart SDK `^3.12.2`
- Built and tested with Flutter 3.44 (stable)

---

## Architecture

The app follows **Clean Architecture** with the **BLoC** pattern. Each layer depends only on the layer inside it.

```
Presentation (UI, BLoC, view models)
        │
        ▼
Domain (entities, repository contract)
        ▲
        │ implements
Data (models, local data source, repository implementation)
```

### Data flow

1. The user taps the fingerprint button, and `CounterPage` adds a `CounterIncremented` event to `CounterBloc`.
2. `CounterBloc` computes the new `CounterEntity`, triggers haptic feedback and emits the new state immediately.
3. The BLoC then saves the change through `CounterRepository`, which uses `SharedPreferencesCounterDataSource`.
4. `BlocSelector` widgets map the state to `CounterViewModel` and `CounterControlsViewModel`, so only the part of the screen that changed is rebuilt.

### BLoC events

| Event | What it does |
|---|---|
| `CounterInitialized` | Loads the saved counter at startup |
| `CounterIncremented` | Adds 1 and records the previous value for undo; ignored once the goal is reached |
| `CounterUndoRequested` | Restores the most recent previous value |
| `CounterResetRequested` | Sets the count to 0 (can be undone) |
| `CounterVibrationToggled` | Turns haptic feedback on or off |
| `CounterGoalChanged` | Sets the goal (clamped to 1–99,999), or removes it when null |

### Stored keys

| Key | Type | Contents |
|---|---|---|
| `counter.count` | `int` | Current count |
| `counter.undo_history` | `List<String>` | Previous values, most recent last (max 100) |
| `counter.vibration_enabled` | `bool` | Vibration preference |
| `counter.goal` | `int` | Goal the ring fills towards (absent when no goal is set) |

---

## Project structure

```
lib/
├── main.dart                          # Entry point: orientation, system UI, DI, preloads the count
├── app/
│   ├── app.dart                       # MisbahApp (MaterialApp + BlocProvider)
│   ├── routes.dart                    # Route table
│   └── theme/                         # Colors, dimensions, typography, theme
├── core/
│   ├── constants/app_constants.dart   # App strings, undo limit, goal limits, storage keys
│   ├── errors/                        # Exceptions and failures
│   └── services/haptics_service.dart  # Vibration abstraction
├── data/
│   ├── datasources/                   # SharedPreferences data source
│   ├── models/                        # CounterModel (storage mapping and cleanup)
│   └── repositories/                  # CounterRepositoryImpl
├── domain/
│   ├── entities/counter_entity.dart   # Count, undo history, vibration preference, goal
│   └── repositories/                  # CounterRepository contract
├── injection/
│   └── dependency_injection.dart      # get_it registrations
└── presentation/counter/
    ├── bloc/                          # CounterBloc, events, state
    ├── viewmodels/                    # UI-ready projections of the state
    ├── views/counter_page.dart        # The single screen
    └── widgets/                       # Goal ring, goal dialog, header, fingerprint count button, controls, icons

test/
├── data/counter_repository_test.dart
├── helpers/fakes.dart
└── presentation/counter/
    ├── counter_bloc_test.dart
    └── counter_page_test.dart

assets/fonts/                          # Switzer, with its license
```

---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, with Dart 3.12.2 or later)
- An emulator, a physical device, or a desktop or web target

### Install and run

```bash
git clone https://github.com/Abdulsathar27/Counter_app.git
cd Counter_app
flutter pub get
flutter run
```

### Build a release

```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS (requires macOS and Xcode)
flutter build web                # Web
flutter build windows            # Windows
```

---

## Testing

```bash
flutter test
```

The test suite covers:

- **Repository:** loading defaults, restoring saved data (including the goal) in a new instance, and cleaning up corrupt values.
- **BLoC:** increment, undo, reset, the undo history limit, the vibration toggle, setting and clamping the goal, ring progress, haptic feedback, and persistence failures.
- **Widgets:** the saved count and progress showing on the first frame, the ring filling and "goal reached", only the fingerprint button counting (taps on the ring or elsewhere are ignored), rapid taps, undo and reset controls, setting and cancelling a goal, accessibility labels, keyboard activation, small screens with large text, and reduced motion.

Static analysis:

```bash
flutter analyze
```

---

## Platforms

Android, iOS, Web, Windows, macOS and Linux.

---

## Font and license

- **Switzer**, licensed under the Fontshare Free Font License (`assets/fonts/FFL.txt`)

---

## Changelog

All changes since the first version, oldest first. Later steps sometimes replace earlier ones; the last entry describes the app as it is now.

### 1. First version
- Flutter tally counter with a split-flap (flip-card) display, built with Clean Architecture and BLoC.
- Undo (up to 100 steps), reset, vibration toggle, and saving with `shared_preferences`.
- README describing the features, architecture, project structure, setup and tests.

### 2. Larger tap area
- Tapping the frame, the "Tap to count" text or the space around the counter also counted, not just the black card.

### 3. Black card made display-only
- Tapping the black card no longer counted; it only showed the number.
- Keyboard and screen-reader support moved from the card to the surrounding area.

### 4. Fingerprint count button
- The "Tap to count" text was replaced by a round button with a fingerprint icon.
- The button uses a `GestureDetector` with a ripple that spreads from the touch point and fades out, plus a slight press-down.
- The button became the only way to count; taps anywhere else on the screen are ignored.
- Keyboard (Tab, then Enter) and screen readers work through the button, and the ripple is skipped when the system asks for reduced motion.

### 5. Flip animation fix
- Only the digits that changed flip (10 → 11 flips just the last digit), so the card no longer shows a mixed number such as top "11" over bottom "10".
- Each half of the flip got its own easing and the flip was shortened from 0.55s to 0.42s.

### 6. Full number in each half
- Each half of the flip card showed the whole number ("14" on top and "14" below) instead of one tall number cut in half.
- The digits switched to bold Roboto Slab to match a reference design.

### 7. New dark design with a goal ring (current)
- The flip card, its frame, and the Roboto Slab and Pinyon Script fonts were removed.
- Dark theme (`#171B20` background) with the count inside a blue (`#125CA1`) progress ring.
- The ring fills towards a goal and shows "N to go" or "goal reached"; it stays full past the goal.
- A new target button opens a dialog to set the goal (1 to 99,999, default 10). The goal is saved with the count.
- New `CounterGoalChanged` BLoC event and `counter.goal` storage key.
- Tests were updated and added for the ring, the goal, and goal storage (33 tests in total).

---

## Author

**Abdulsathar27** · [GitHub @Abdulsathar27](https://github.com/Abdulsathar27)

# **Strategy System**

**Strategy** is the basic organizational unit for business logic. Each strategy encapsulates an independent business concern (such as first-frame timing, stutter detection, resume playback, etc.) and fulfills its responsibility by observing player state and processing relevant data. All strategies are managed by the StrategyManager, which starts them when the player is created and stops them when it is destroyed.

The AliPlayerWidget strategy system allows developers to flexibly extend the player's business logic. With this system, you can encapsulate playback quality monitoring, event tracking, user behavior analysis, and other concerns as independent strategies — composing them freely like plugins to meet different business requirements.

---

## **1. Built-in Strategies**

The following recommended strategies are registered by default and work **out of the box**:

| Strategy | Class Name | Description | Optional Callback |
|----------|-----------|-------------|-------------------|
| **First Frame Timing** | `FirstFrameStrategy` | Measures prepare→prepared and prepare→rendered durations | `onPrepared`, `onFirstFrame` |
| **Stutter Detection** | `StutterDetectStrategy` | Coordinates play/loading state listeners to track stutter count, duration, and rate | `onStutterDetected` |

> **Note**: Built-in strategies require no configuration and take effect automatically after the player is created. To retrieve strategy data, pass in the corresponding callback parameters.

## **2. Usage**

### **2.1 Using Default Strategies**

No configuration needed — built-in strategies run automatically:

```dart
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
controller.configure(data);
```

### **2.2 Replacing Built-in Strategies**

Use `register()` to replace the default callback-free versions with callback-enabled instances to retrieve strategy runtime data:

```dart
controller.strategyManager
  ..register(FirstFrameStrategy(
    onPrepared: (cost) {
      print('Prepare cost: ${cost.inMilliseconds}ms');
    },
    onFirstFrame: (cost) {
      print('First frame cost: ${cost.inMilliseconds}ms');
    },
  ))
  ..register(StutterDetectStrategy(
    onStutterDetected: (info) {
      print('Stutter ${info.stutterCount} times, rate ${(info.stutterRate * 100).toStringAsFixed(1)}%');
    },
  ));
```

> **Note**: Registering a strategy with the same name automatically replaces the existing instance — no manual removal needed.

### **2.3 Registering Custom Strategies**

Use `register()` to add new strategies that extend player behavior:

```dart
controller.strategyManager.register(ResumePlayStrategy(
  onPositionSaved: (position) {
    print('Saved position: ${position.inSeconds}s');
  },
));
```

> For custom strategy development, see the "Custom Strategy Development" section below.

### **2.4 Managing Strategies**

Use `strategyManager` to remove strategies at runtime:

```dart
// Remove a strategy by name
controller.strategyManager.unregister('MyCustomStrategy');

// Remove all strategies
controller.strategyManager.clear();
```

## **3. Custom Strategy Development**

### **3.1 Extending BasePlayerStrategy**

Extend `BasePlayerStrategy` to create a custom strategy. The framework automatically manages listener lifecycle:

```dart
class MyCustomStrategy extends BasePlayerStrategy {
  @override
  String get name => 'MyCustomStrategy';

  @override
  void onStart(AliPlayerWidgetController controller) {
    // Subscribe to notifiers via listen(). The framework auto-cleans up on onStop.
    listen<int>(controller.playStateNotifier, (state) {
      // Handle play state changes
    });

    listen<Duration>(controller.currentPositionNotifier, (position) {
      // Handle playback position changes
    });
  }

  @override
  void onReset() {
    // Reset internal state on video switch (strategy remains active)
  }
}
```

### **3.2 Lifecycle Methods**

| Method | Triggered When | Responsibility |
|--------|---------------|----------------|
| `onStart` | Strategy starts | Subscribe to state signals, initialize internal state |
| `onStop` | Strategy stops (Controller destroyed) | Release resources (BasePlayerStrategy auto-cleans listeners) |
| `onReset` | Video source switches | Reset internal counters/timestamps, keep strategy active |

### **3.3 Callback Safety**

Strategies typically report data to the outside via callbacks (e.g., notifying UI updates). When a strategy stops, the UI may already be destroyed, so the framework provides two layers of protection:

| Mechanism | Scope | Description |
|-----------|-------|-------------|
| `listen()` built-in guard | Notifier-driven callbacks | After strategy stops, listeners no longer fire `onChanged` |
| `notify()` helper | Active callbacks in `onStop()` | Safely invokes external callbacks; auto-skipped after stop |

```dart
class ResumePlayStrategy extends BasePlayerStrategy {
  final void Function(Duration)? onPositionSaved;

  @override
  void onStop() {
    super.onStop();
    _savePosition();
  }

  void _savePosition() {
    // Persistence always executes (data safety)
    storage.save(position);

    // Safely invoke external callback via notify() (auto-skipped after stop)
    notify(onPositionSaved, position);
  }
}
```

> **Design Principle**: Persistence (data safety) and notification (UI updates) are separate concerns. `onStop()` may perform persistence, but external notifications must go through `notify()`.

## **4. Data Sources and State Signals**

Strategies are essentially the basic organizational units for business logic. Since business logic inevitably involves data acquisition and processing, strategies need to access data from multiple sources. In `onStart`, strategies receive the full `controller` reference, providing access to various data channels.

### **4.1 Observable State Signals**

Strategies subscribe to ValueNotifiers on the Controller via the `listen()` method:

| Notifier | Type | Description |
|----------|------|-------------|
| `prepareNotifier` | `int` | prepare() call event |
| `isPreparedNotifier` | `bool` | Data source preparation complete |
| `isRenderedNotifier` | `bool` | First frame rendered |
| `playStateNotifier` | `int` | Play state changes |
| `currentPositionNotifier` | `Duration` | Current playback position |
| `totalDurationNotifier` | `Duration` | Total video duration |
| `isLoadingStateNotifier` | `bool` | Loading state |
| `isDraggingNotifier` | `bool` | Whether the user is dragging the seek bar |
| `currentSeekTimeNotifier` | `Duration` | Current seek time during drag operation |
| `contentViewTypeNotifier` | `ContentViewType` | Center display content type (volume/brightness/speed indicator) |
| `settingPanelRequestNotifier` | `int` | Settings panel open request counter |

> **Design Principle**: Strategies only observe player state and do not directly control playback behavior.

### **4.2 Other Data Sources**

Data sources are not limited to ValueNotifiers — any public API on the Controller is a valid data access path:

| Source | Description | Example |
|--------|-------------|--------|
| **ValueNotifier listening** | Reactive, push-based; ideal for state-change-driven logic | `listen(controller.playStateNotifier, ...)` |
| **Configuration access** | Read video source, scene type, and other config data | `controller.widgetData?.videoSource` |
| **Active query** | Call Controller async methods for real-time data | `await controller.getCurrentPosition()` |
| **Constructor injection** | Pass external dependencies via strategy constructor | `MyStrategy(apiClient: dio)` |

**When the data you need has no corresponding Notifier**, you can:

```dart
class MyCustomStrategy extends BasePlayerStrategy {
  late AliPlayerWidgetController _controller;

  @override
  String get name => 'MyCustomStrategy';

  @override
  void onStart(AliPlayerWidgetController controller) {
    _controller = controller;

    // Approach 1: Combine existing Notifier with active query in callback
    listen<int>(controller.playStateNotifier, (state) {
      // On play state change, actively query current position
      controller.getCurrentPosition().then((pos) {
        // ...handle business logic
      });
    });

    // Approach 2: Directly read configuration
    final videoSource = controller.widgetData?.videoSource;
    // ...execute different logic based on video source type
  }
}
```

> **Tip**: Notifiers are the preferred data source (reactive, auto-cleanup), but strategies are not limited to them — any public API on the Controller is a valid data access path.

## **5. How It Works**

The strategy system operates through the following mechanisms:

1. **Auto Registration**: StrategyManager registers built-in recommended strategies by default upon creation
2. **Lifecycle Binding**: Strategies start with `configure()` and stop with `destroy()`
3. **Exception Isolation**: An exception in one strategy does not affect other strategies
4. **Callback Safety**: The framework guarantees no external callbacks fire after strategy stops via `isActive`

## **6. Examples**

See `example/lib/pages/strategy/strategy_demo_page.dart` for a complete strategy system usage example, including a full implementation of a custom strategy (resume playback).

---

With the strategy system, you can encapsulate various business concerns as independent strategies and compose them flexibly to meet different requirements.

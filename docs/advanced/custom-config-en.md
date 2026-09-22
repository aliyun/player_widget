# **Custom Configuration**

AliPlayerWidget comes with built-in best-practice configurations that deliver an excellent experience for most scenarios without any additional setup. When the player capabilities you need are not directly provided by AliPlayerWidget's interfaces, you can use the following custom configuration mechanisms to call `flutter_aliplayer` APIs directly.

## **1. Prerequisites**

Custom configuration requires calling native APIs from the `flutter_aliplayer` library directly. Although `aliplayer_widget` already depends on it internally, it is recommended to explicitly declare this dependency in your project to ensure proper import and usage:

```yaml
# pubspec.yaml
dependencies:
  aliplayer_widget: <latest_version>

  # Required for custom configuration
  flutter_aliplayer: <latest_version>
```

## **2. Configuration Levels Overview**

AliPlayerWidget provides two levels of custom configuration entry points to meet different granularity requirements:

| Level | API | Timing | Typical Scenarios |
|-------|-----|--------|-------------------|
| **Global** | `AliPlayerWidgetGlobalSetting.setOnGlobalInit` | After global initialization (once only) | setOption, mediaLoader, and other global behaviors |
| **Instance** | `AliPlayerWidgetData.onPlayerConfig` | Before each player instance's prepare() | setPlayConfig (buffering, Referer), setOption, and other instance behaviors |

> **Note**: The player SDK itself has two configuration types: global and instance. AliPlayerWidget comes with built-in best-practice settings, but for native APIs not directly exposed, it provides the two callback entry points above for developers to obtain the player instance and call these APIs directly.

## **3. Global Configuration: setOnGlobalInit**

### **3.1 Use Cases**

- Set global Options (e.g., global log level)
- Configure mediaLoader (custom media loading logic)
- Other global behaviors that need to take effect before any player instance is created

### **3.2 Usage**

Register the callback in `main()` **before** calling `AliPlayerWidgetGlobalSetting.setupConfig()`:

```dart
import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register global custom configuration callback (call before setupConfig)
  AliPlayerWidgetGlobalSetting.setOnGlobalInit(() {
    // Example: Set global Option
    FlutterAliPlayerGlobalSettings.setOption(
      AliPlayerGlobalSettings.ENABLE_H2_MULTIPLEX, 1,
    );
  });

  // Initialize global configuration (triggers the registered callback after initialization)
  AliPlayerWidgetGlobalSetting.setupConfig();

  runApp(const MyApp());
}
```

### **3.3 Trigger Timing**

The callback is triggered after global initialization completes inside `setupConfig()`, and executes only once. At this point, the underlying SDK is ready for global API calls.

### **3.4 Notes**

- `setOnGlobalInit` should be called **before** `setupConfig()`, otherwise the callback may not be triggered.
- Global configuration executes only once; subsequent calls to `setupConfig()` will not trigger it again.

## **4. Instance Configuration: onPlayerConfig**

### **4.1 Use Cases**

- Custom buffering strategies (`maxBufferDuration`, `highBufferDuration`, etc.)
- Set Referer for anti-hotlinking
- Configure HTTP Headers
- Set instance-level Options
- Other player APIs not directly exposed by AliPlayerWidget

### **4.2 Usage**

Pass the callback via the `onPlayerConfig` parameter when constructing `AliPlayerWidgetData`:

```dart
final data = AliPlayerWidgetData(
  videoSource: videoSource,
  onPlayerConfig: (player) async {
    // Example 1: Custom buffering strategy and Referer
    var config = await player.getPlayConfig();
    config.maxBufferDuration = 50000;        // Max buffer duration 50s
    config.highBufferDuration = 3000;        // High watermark buffer 3s
    config.startBufferDuration = 500;        // Start buffer 500ms
    config.referer = "https://your-domain.com";  // Set Referer for anti-hotlinking
    await player.setPlayConfig(config);

    // Example 2: Set instance-level Option
    player.setOption(FlutterAvpdef.ALLOW_PRE_RENDER, 1);
  },
);

// Configure and play
controller.configure(data);
```

### **4.3 Trigger Timing**

The callback is triggered **before** the player executes `prepare()`. At this point, the player instance has been created but loading and playback have not yet started, making it the ideal time for custom configuration. It is triggered each time `controller.configure(data)` is called.

### **4.4 Notes**

- The callback supports async operations (`async/await`). The Widget will await callback completion before calling `prepare()`.
- The callback parameter `player` is the native `FlutterAliplayer` instance, allowing access to all native SDK interfaces.
- The callback is triggered each time `controller.configure(data)` is called, making it suitable for dynamic configuration scenarios.

## **5. FAQ**

### Q: What is the execution order of global and instance configurations?

Global configuration (`setOnGlobalInit`) executes once at application startup; instance configuration (`onPlayerConfig`) executes before each player instance's `prepare()`. They do not interfere with each other.

### Q: What happens if I don't set any custom configuration?

AliPlayerWidget has built-in best-practice configurations and works out of the box for most scenarios without any custom settings.

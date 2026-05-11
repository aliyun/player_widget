# **AliPlayerWidget Core Components**

AliPlayerWidget adopts an MVC-inspired layered design, separating the view (View), control logic (Controller), and data model (Data) into three core components that work together to deliver complete video playback functionality.

## **1. AliPlayerWidget (View)**

`AliPlayerWidget` is the core player component (View) used to embed and play videos within Flutter applications.

### **1.1 Constructor**

```dart
AliPlayerWidget(
  AliPlayerWidgetController controller, {
  Key? key,
  Map<SlotType, SlotWidgetBuilder?> slotBuilders = const {},
  OnBackPressedCallback? onBackPressed,
});
```

- **`controller`**: The player controller used to manage playback logic.
- **`slotBuilders`**: Optional slot builder map, allowing customization of how each slot is built. See [Slot System](slot-system-en.md) for details.
- **`onBackPressed`**: Optional back button press callback. Called when the user presses the back button. Returns `true` to indicate the event was handled and no default action is needed; returns `false` or `null` to execute the default behavior (`Navigator.pop`).

### **1.2 Back Event Handling (Optional)**

By default, when the user presses the back button:
1. If currently in fullscreen mode, it will exit fullscreen first
2. If `onBackPressed` callback is provided, it will be called
3. If the callback returns `false` or `null`, the default `Navigator.pop()` will be executed

With the `onBackPressed` callback, you can fully customize the back behavior:

```dart
AliPlayerWidget(
  _controller,
  onBackPressed: () {
    // Custom back logic
    Navigator.of(context).pop();
    return true; // Return true to indicate handled, no default action needed
  },
);
```

## **2. AliPlayerWidgetController (Controller)**

`AliPlayerWidgetController` is the controller component (Controller) that manages initialization, playback, destruction, and other logic of the player component.

### **2.1 Primary Methods**

- **`configure(AliPlayerWidgetData data)`**: Configures the data source.
- **`play()`**: Starts video playback.
- **`pause()`**: Pauses playback.
- **`seek(Duration position)`**: Jumps to the specified playback position.
- **`destroy()`**: Destroys the player instance to release resources.

## **3. AliPlayerWidgetData (Data)**

`AliPlayerWidgetData` is the data model (Data) of the player component, containing video URL, cover image, title, and other information.

### **3.1 Attributes**

- **`videoSource`**: Video playback source (required).
- **`coverUrl`**: Cover image URL (optional).
- **`videoTitle`**: Video title (optional).
- **`thumbnailUrl`**: Thumbnail URL (optional).
- **`sceneType`**: Playback scenario type, defaulting to VOD (`SceneType.vod`).
- **`onPlayerConfig`**: Player custom configuration callback (optional). See [Custom Configuration](./advanced/custom-config-en.md) for details.

## **4. Global Configuration (Optional)**

In addition to the three core components mentioned above, AliPlayerWidget also provides an optional global configuration class `AliPlayerWidgetGlobalSetting` for configuring global player behavior, such as cache settings and storage paths.

### **4.1 Main Functions**

- **Global Configuration Initialization**: Initialize global configuration through the [setupConfig] method
- **Storage Path Setting**: Set cache and file storage paths through the [setStoragePaths] method
- **Cache Management**: Clear all caches through the [clearCaches] method
- **Custom Configuration**: Supports global-level and instance-level custom configuration. See [Custom Configuration](./advanced/custom-config-en.md) for details.

### **4.2 Usage Notes**

The component already includes recommended optimal global settings by default; usually no extra setup is needed. If customization is required, refer to the [Custom Configuration](./advanced/custom-config-en.md) documentation.

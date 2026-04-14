# **Slot System**

**Slot** is the basic building block of the player UI. Each slot is responsible for a specific part of the interface, such as the top control bar or bottom progress bar. All slots are stacked in layers to form the complete player interface.

The AliPlayerWidget slot system allows developers to flexibly customize various parts of the player UI. With this system, you can easily implement different UI styles to meet various product and user requirements. Like building blocks, you can freely combine interface components to create a player interface that matches your brand identity.

---

## **1. Slot Types and Functions**

The system provides the following slot types, **arranged from bottom to top by layer**:

| Slot Type | Description | Default Visible |
|---------|---------|---------|
| **playerSurface** | Player view slot for displaying video content (customization not recommended) | Yes |
| **subtitle** | Subtitle slot for displaying video subtitles | Yes (conditional) |
| **coverImage** | Cover image slot, displays a cover image before video loads | Yes (conditional) |
| **playControl** | Play control slot, handles gesture controls for the player | Yes |
| **topBar** | Top bar slot, typically contains back button, title, and settings button | Yes |
| **bottomBar** | Bottom bar slot, typically contains play controls, progress bar, and fullscreen button | Yes |
| **seekThumbnail** | Seek thumbnail slot, displays preview thumbnails when dragging the progress bar | Yes (conditional) |
| **centerDisplay** | Center display slot, shows volume, brightness, and other info during gesture operations | Yes (conditional) |
| **playState** | Play state slot, displays status information like playback errors | Yes (conditional) |
| **settingMenu** | Settings menu slot, contains player settings options | Yes (except in minimal mode) |
| **overlays** | Overlay slot, positioned at the topmost layer for custom overlay content like likes, comments, and share buttons | No |

> **Note**: The `playerSurface` slot is responsible for rendering video content. Modifying this slot may cause the player to malfunction, so customization is not recommended.

## **2. Usage**

### **2.1 Using Default Interface**

Without any configuration, the player will use the built-in default interface:

```dart
AliPlayerWidget(controller)
```

### **2.2 Customizing Slots**

Use the `slotBuilders` parameter to customize any slot. Unspecified slots will continue to use the default interface.

#### **Partial Customization**

Replace only the slots you want to customize, while keeping others at default:

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.topBar: (context, controller) => MyCustomTopBar(controller),
  },
)
```

#### **Full Customization**

Customize all slots for a completely personalized interface:

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    // Note: Customizing playerSurface is not recommended
    SlotType.topBar: (context, controller) => MyCustomTopBar(controller),
    SlotType.bottomBar: (context, controller) => MyCustomBottomBar(controller),
    SlotType.playControl: (context, controller) => MyPlayControl(controller),
    SlotType.coverImage: (context, controller) => MyCoverImage(controller),
    SlotType.playState: (context, controller) => MyPlayState(controller),
    SlotType.centerDisplay: (context, controller) => MyCenterDisplay(controller),
    SlotType.seekThumbnail: (context, controller) => MySeekThumbnail(controller),
    SlotType.subtitle: (context, controller) => MySubtitle(controller),
    SlotType.settingMenu: (context, controller) => MySettingMenu(controller),
    SlotType.overlays: (context, controller) => MyOverlays(controller),
  },
)
```

#### **SlotWidgetBuilder Types**

The slot system supports two builder signatures for backward compatibility:

```dart
// New signature (recommended) - ensures fullscreen mode support
typedef SlotWidgetBuilderWithController = Widget Function(
  BuildContext context,
  AliPlayerWidgetController controller,
);

// Old signature (deprecated) - may not work correctly in fullscreen mode
@Deprecated('Use SlotWidgetBuilderWithController instead')
typedef SlotWidgetBuilder = Widget Function(BuildContext context);
```

> **Important**: The `controller` parameter in the new signature ensures that slotBuilders work correctly in fullscreen mode. When entering fullscreen, a new controller instance is created. By receiving the controller as a parameter, your slotBuilder will always control the correct player instance.

### **2.3 Hiding Slots**

Set a slot to `null` to hide it:

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.topBar: null,
    SlotType.bottomBar: null,
  },
)
```

### **2.4 Fine-grained Control**

When you want to hide only certain elements (like buttons) within a default slot without customizing the entire slot, use `hiddenSlotElements`:

```dart
AliPlayerWidget(
  controller,
  hiddenSlotElements: const {
    // Hide download and snapshot buttons in the top bar
    SlotType.topBar: {
      TopBarElements.download,
      TopBarElements.snapshot,
    },
    // Disable double-tap and vertical swipe gestures in play control
    SlotType.playControl: {
      PlayControlElements.doubleTap,
      PlayControlElements.leftVerticalDrag,
      PlayControlElements.rightVerticalDrag,
    },
  },
)
```

> **Note**: `hiddenSlotElements` only applies to default slots. If a slot is customized via `slotBuilders`, the `hiddenSlotElements` configuration for that slot will be ignored.

### **2.5 Backward Compatibility**

The legacy `overlays` parameter is deprecated. Please migrate to the new slot system:

```dart
// Legacy (deprecated)
AliPlayerWidget(
  controller,
  overlays: [MyOverlayWidget()],
)

// New approach (recommended)
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.overlays: (context, controller) => MyOverlayWidget(controller),
  },
)
```

> **Important**: The `controller` parameter ensures that slotBuilders work correctly in fullscreen mode. When entering fullscreen, a new controller instance is created. By receiving the controller as a parameter, your slotBuilder will always control the correct player instance.

## **3. How It Works**

The slot system uses a three-tier rendering strategy:

1. **Custom First**: If a custom builder is provided for a slot, use the custom builder
2. **Default Fallback**: If no custom builder is provided, use the system default builder
3. **Explicit Hide**: If the slot value is null, hide the slot

## **4. Scene Adaptation**

Certain slots automatically adapt their behavior based on the playback scene (SceneType):

- **vod** (Video on Demand): All slot features are supported
- **live** (Live Streaming): Progress dragging related slot features are disabled
- **listPlayer** (List Player): Vertical gesture related slot features are disabled
- **restricted** (Restricted Playback): Timeline operation related slot features are disabled
- **minimal** (Minimal Mode): Only the playerSurface slot is displayed

## **5. Examples**

See `example/lib/pages/slot/slot_demo_page.dart` for a complete slot usage example.

---

With the slot system, you can easily create player interfaces that meet various requirements.

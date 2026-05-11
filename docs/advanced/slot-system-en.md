# **Slot System**

**Slot** is the basic building block of the player UI. Each slot is responsible for a specific part of the interface, such as the top control bar or bottom progress bar. All slots are stacked in layers to form the complete player interface.

The AliPlayerWidget slot system allows developers to flexibly customize various parts of the player UI. With this system, you can easily implement different UI styles to meet various product and user requirements. Like building blocks, you can freely combine interface components to create a player interface that matches your brand identity.

---

## **1. Slot Types and Functions**

The system provides the following slot types, **arranged from bottom to top by layer**:

| Slot Type | Default Order | Description | Default Visible |
|---------|:-------:|---------|:-------:|
| **playerSurface** | 10 | Player view slot for displaying video content (customization not recommended) | Yes |
| **subtitle** | 20 | Subtitle slot for displaying video subtitles | Yes (conditional) |
| **coverImage** | 30 | Cover image slot, displays a cover image before video loads | Yes (conditional) |
| **playControl** | 40 | Play control slot, handles gesture controls for the player | Yes |
| **topBar** | 50 | Top bar slot, typically contains back button, title, and settings button | Yes |
| **bottomBar** | 60 | Bottom bar slot, typically contains play controls, progress bar, and fullscreen button | Yes |
| **seekThumbnail** | 70 | Seek thumbnail slot, displays preview thumbnails when dragging the progress bar | Yes (conditional) |
| **centerDisplay** | 80 | Center display slot, shows volume, brightness, and other info during gesture operations | Yes (conditional) |
| **playState** | 90 | Play state slot, displays status information like playback errors | Yes (conditional) |
| **settingMenu** | 100 | Settings menu slot, contains player settings options | Yes (except in minimal mode) |
| **overlays** | 110 | Overlay slot, positioned at the topmost layer for custom overlay content like likes, comments, and share buttons | No |

> **Default Order**: Lower values are closer to the bottom layer. Built-in slots are spaced by 10, leaving ample room for custom slot insertion.

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
    SlotType.topBar: (context) => MyCustomTopBar(),
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
    SlotType.topBar: (context) => MyCustomTopBar(),
    SlotType.bottomBar: (context) => MyCustomBottomBar(),
    SlotType.playControl: (context) => MyPlayControl(),
    SlotType.coverImage: (context) => MyCoverImage(),
    SlotType.playState: (context) => MyPlayState(),
    SlotType.centerDisplay: (context) => MyCenterDisplay(),
    SlotType.seekThumbnail: (context) => MySeekThumbnail(),
    SlotType.subtitle: (context) => MySubtitle(),
    SlotType.settingMenu: (context) => MySettingMenu(),
    SlotType.overlays: (context) => MyOverlays(),
  },
)
```

#### **SlotWidgetBuilder Types**

The slot system currently uses a concise builder signature:

```dart
// Current signature (recommended)
typedef SlotWidgetBuilder = Widget Function(BuildContext context);

// Legacy signature (deprecated)
@Deprecated('Use SlotWidgetBuilder instead')
typedef SlotWidgetBuilderWithController = Widget Function(
  BuildContext context,
  AliPlayerWidgetController controller,
);
```

**Notes:**

* The current architecture uses a single shared Controller mode. Both fullscreen and normal modes share the same Controller instance, so there is no need to pass it via builder parameters.
* If you need to access the Controller in a custom slot, you can obtain it directly through an external reference.

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

### **2.5 Custom UI Insertion and Layer Control**

Unlike traditional overlay approaches that only stack elements on top, the slot system allows you to insert custom UI components at **any layer** of the player. Use `defaultOrder` to precisely control the rendering order, enabling accurate layer placement for components like watermarks, bullet comments, ads, and more:

`SlotType` is an extensible class. You can create custom slot types and control their layer position via `defaultOrder`:

```dart
// Create a custom slot type, layered between coverImage(30) and playControl(40)
const myWatermark = SlotType('watermark', defaultOrder: 35);

AliPlayerWidget(
  controller,
  slotBuilders: {
    myWatermark: (context) => MyWatermarkWidget(),
  },
  // All slots are automatically sorted by defaultOrder
)
```

> **Tip**: The system automatically sorts all built-in and custom slots by `defaultOrder`. Custom slots are seamlessly merged into the rendering order based on their `defaultOrder` value.

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

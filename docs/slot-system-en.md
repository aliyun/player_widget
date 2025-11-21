# **Slot System Usage Guide**

## **Overview**

The AliPlayerWidget slot system allows developers to flexibly customize various parts of the player interface. Through the slot system, you can easily implement multiple UI styles to meet different product and user requirements. Like building with blocks, you can freely combine various interface components to create a player interface that matches your brand characteristics.

## **Slot Types and Functions**

The system provides the following slot types, covering all aspects of the player interface:

| Slot Type | Function Description | Default Display |
|-----------|---------------------|-----------------|
| **playerSurface** | Player view slot for displaying video content (customization not recommended) | Yes |
| **topBar** | Top bar slot, typically containing back button, title and settings button | Yes |
| **bottomBar** | Bottom bar slot, typically containing play controls, progress bar and fullscreen button | Yes |
| **playControl** | Play control slot, handling player gesture controls | Yes |
| **coverImage** | Cover image slot, displaying cover image before video loads | Yes (conditionally) |
| **playState** | Play state slot, displaying play errors and other status information | Yes (conditionally) |
| **centerDisplay** | Center display slot, showing volume, brightness and other information during gesture operations | Yes (conditionally) |
| **seekThumbnail** | Seek thumbnail slot, displaying preview thumbnails when dragging the progress bar | Yes (conditionally) |
| **subtitle** | Subtitle slot, for displaying video subtitles | Yes (conditionally) |
| **settingMenu** | Settings menu slot, containing player settings options | Yes (except minimal scene) |
| **overlays** | Overlay slot, for adding custom overlay layers | No |

> **Note**: The `playerSurface` slot is responsible for rendering and displaying video content. Modifying this slot may cause the player to malfunction, so customizing this slot is not recommended.

## **Usage Methods**

### **1. Using Default Interface**

The simplest way to use it is without providing the slotBuilders parameter, and the player will use the default interface:

```dart
AliPlayerWidget(controller)
```

### **2. Customizing Partial Slots**

Customize only specific slots, with others using the default interface. For example, customizing only the top bar:

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.topBar: (context) => MyCustomTopBar(),
  },
)
```

### **3. Fully Customized Interface**

You can customize all slots to create a completely personalized player interface:

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

### **4. Hiding Specific Slots**

By setting the slot value to null, you can hide specific slots:

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.topBar: null, // Hide top bar
    SlotType.bottomBar: null, // Hide bottom bar
    SlotType.centerDisplay: null, // Hide center display
  },
)
```

### **5. Customizing Overlays**

Use the overlay slot to add custom overlay layers:

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.overlays: (context) => MyCustomOverlays(),
  },
)
```

### **6. Backward Compatibility**

To ensure backward compatibility, the overlays parameter used in older versions still works, but has been marked as deprecated. Please use the new slot system instead:

```dart
// Old version method (deprecated)
AliPlayerWidget(
  controller,
  overlays: [MyOverlayWidget()],
)

// New version method (recommended)
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.overlays: (context) => MyOverlayWidget(),
  },
)
```

## **How the Slot System Works**

The slot system works through the following three-level rendering strategy:

1. **Custom Priority**: If a custom builder for the slot is provided, the custom builder is used
2. **Default Fallback**: If no custom builder is provided, the system default builder is used
3. **Explicitly Hidden**: If the slot value is null, the slot is hidden

## **Scene Adaptation**

Based on different playback scenes (SceneType), certain slot behaviors will automatically adapt:

- **vod** (Video on Demand scene): Supports all slot functions
- **live** (Live streaming scene): Disables progress dragging related slot functions
- **listPlayer** (List player scene): Disables vertical gesture related slot functions
- **restricted** (Restricted playback scene): Disables timeline operation related slot functions
- **minimal** (Minimal playback scene): Only displays the playerSurface slot

## **Practical Examples**

Please refer to `example/lib/pages/slot/slot_demo_page.dart` to see complete slot usage examples, including:

- Implementation of modern, classic, and minimalist UI styles
- How to customize top bar, bottom bar and play control slots
- How to control the player externally through Notifier from outside the Widget

Through the slot system, you can easily create player interfaces that meet various requirements.
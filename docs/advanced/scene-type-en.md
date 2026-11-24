# **SceneType Guide**

## **Overview**

`sceneType` tells AliPlayerWidget which UI elements, slots, and gestures should be enabled under a specific business scenario. It is defined on `AliPlayerWidgetData.sceneType` and defaults to `SceneType.vod`. Choosing the right scene gives you preconfigured UI trimming, gesture blocks, and security constraints without writing conditional logic everywhere.

## **Configuration**

```dart
final controller = AliPlayerWidgetController();

controller.configure(
  AliPlayerWidgetData(
    videoSource: videoSource,
    sceneType: SceneType.live, // Switch scenes based on your use case
  ),
);
```

> **Tip**: Use `isSceneType` / `isNotSceneType` (see `lib/utils/scene_util.dart`) to branch runtime logic quickly.

## **Capability Matrix**

| Scene | Typical use cases | UI / gesture capability | Slot policy | Recommendation |
|-------|------------------|--------------------------|-------------|----------------|
| `SceneType.vod` | Standard VOD, courses, media libraries | Full controls (playback, seek, speed, gestures) | All slots available | Default choice |
| `SceneType.live` | Live streaming, sports | No timeline actions; keep refresh, gestures, settings | `coverImage`, `seekThumbnail` hidden | Real-time streams |
| `SceneType.listPlayer` | Feed players, short-video lists | Disable vertical gestures to avoid scroll conflicts; basic controls stay | Same as VOD | Use inside scrolling lists |
| `SceneType.restricted` | Exams, training, anti-skip playback | Disable seek / fast-forward / speed while keeping other controls | `coverImage`, `seekThumbnail` hidden | Enable when timeline must be locked |
| `SceneType.minimal` | Background video, custom UI shells, decorative video | Only video surface; no controls, no captions, gestures off | Only `playerSurface` / `overlays` visible | Treat as canvas for external UI |
| `SceneType.aiVod` | AI education, knowledge videos, content analysis | Inherits all VOD controls plus chapter segmentation, chapter navigation and chapter info on seek | Same as VOD | Enable for AI content analysis |

## **Seek Gating**

Since 7.19.0, `controller.seek()` is the command-level entry that resolves the scene for every seek request, while chapter seek entries stay read-only in the interaction layer. Both layers constrain jumping per scene.

| Scene | `seek()` command layer | Chapter UI | Chapter seeking |
|-------|------------------------|------------|-----------------|
| `SceneType.vod` | Allowed | Shown when chapter data is non-empty | Allowed |
| `SceneType.live` | Blocked (logged and dropped) | Not shown | Blocked (silent) |
| `SceneType.listPlayer` | Allowed | Shown when chapter data is non-empty | Allowed |
| `SceneType.restricted` | Blocked (logged and dropped) | Shown (read-only) | Blocked (silent) |
| `SceneType.minimal` | Allowed (no UI entry) | Not shown | Blocked (no entry) |
| `SceneType.aiVod` | Allowed | Shown when chapter data is non-empty | Allowed |

> **Note**: The `startTime` passed at startup goes through the prepare path instead of `seek()`, so it is not affected by the gating above.

## **Scene Details**

### **SceneType.vod**
- **Features**: Full control set, all gestures, every slot enabled.
- **Use cases**: VOD courses, media playback, training videos.
- **Notes**: Works out of the box as the default scene; no extra config required.

### **SceneType.live**
- **Features**: Timeline-related UI (seek bar, thumbnails, speed) disabled; play/pause, refresh, volume/brightness gestures, fullscreen, and settings remain.
- **Use cases**: Live channels, events, monitoring feeds.
- **Notes**: `SlotType.coverImage` and `SlotType.seekThumbnail` are removed automatically.

### **SceneType.listPlayer**
- **Features**: Same as VOD but removes vertical gestures (volume/brightness) to avoid conflicts with parent scroll containers.
- **Use cases**: Feed players, card players, short-video waterfalls.
- **Notes**: Consider switching to `SceneType.vod` when entering fullscreen if gestures are needed there.

### **SceneType.restricted**
- **Features**: Blocks all timeline interactions (seek, fast-forward, speed) to enforce linear viewing; other controls stay.
- **Use cases**: Exams, classroom supervision, demos with anti-skip requirements.
- **Notes**: `SlotType.coverImage` and `SlotType.seekThumbnail` stay hidden; combine with custom slots to show countdowns or notices.

### **SceneType.minimal**
- **Features**: Renders only the video surface; no UI slots (captions, controls, states) and all gestures disabled.
- **Use cases**: Background loops, decorative elements, picture-in-picture cores, fully custom shells.
- **Notes**: Use `SlotType.overlays` or external widgets if you still need custom overlays.

### **SceneType.aiVod**
- **Features**: Inherits the full VOD control set plus chapter-based progress bar segmentation, chapter navigation, and chapter info while seeking.
- **Use cases**: AI education courses, knowledge videos, content analysis.
- **Notes**: Since 7.19.0 chapters are a general capability and no longer require the `aiVod` scene.

## **Slot & Scene Mapping**

| Slot type | Scenes hidden automatically |
|-----------|-----------------------------|
| `SlotType.coverImage` | `live`, `restricted`, `minimal` |
| `SlotType.playControl` / `topBar` / `bottomBar` / `centerDisplay` / `settingMenu` / `subtitle` | `minimal` |
| `SlotType.seekThumbnail` | `live`, `restricted`, `minimal` |
| `SlotType.playerSurface` / `playState` / `overlays` | Always available |

If you need a slot in a restricted scene, override it via `slotBuilders`, or switch builders according to `sceneType`.

## **Best Practices**

- **Runtime switching**: Reconfigure the controller with a new `AliPlayerWidgetData.sceneType` to reuse one widget across multiple pages.
- **State sync**: Store the current scene in your state management (Provider, Riverpod, etc.) if outer UI must react to scene changes.
- **Testing**: Focus on special scenes (`restricted`, `minimal`) to ensure slots hide correctly, and verify gesture conflicts disappear in `listPlayer`.

Leveraging `sceneType` lets you push different business behaviors without sprinkling conditional logic across your codebase.


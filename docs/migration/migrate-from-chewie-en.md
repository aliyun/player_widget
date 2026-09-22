# **Migrating from chewie to aliplayer_widget**

This document helps you migrate the playback UI of an existing Flutter project from chewie to aliplayer_widget with as few changes as possible.

---

## **1. Migration Instructions**

chewie and aliplayer_widget are both Flutter components that include a playback UI, so this migration is a **same-layer component replacement**. Only the UI component layer needs to change:

| Layer             | Before Migration | After Migration       | Direct Integration Required     |
| ----------------- | ---------------- | --------------------- | ------------------------------- |
| Player UI widget  | `chewie`         | `aliplayer_widget`    | Yes, the main path of this guide |
| Player SDK        | `video_player`   | `flutter_aliplayer`   | Usually not required            |

---

## **2. Migration Benefits**

* **Direct benefits of a same-layer replacement**
  - **A more powerful underlying engine** — flutter_aliplayer replaces video_player and supports more protocols and formats
  - **A simpler API design** — from dual controllers (VideoPlayerController + ChewieController) to a single controller
  - **More flexible architectural extension** — a multi-level slot system replaces the single `customControls` parameter, and a strategy system supports business-logic extension
  
* **Incremental capabilities from device–cloud collaboration**
  * **Out-of-the-Box Media Asset Management** — the playback entry point is upgraded from a URL to a VID; the cover, title, multiple quality options, and Seek thumbnails are delivered directly by the cloud, so the business side no longer needs to maintain a metadata pass-through pipeline
  * **Playback Method and Security Authentication** — playback based on PlayAuth / STS credentials natively supports hotlink protection and time-based access control, without exposing the source address

---

## **3. Core API Mapping**

The migration mainly involves the following three classes:

- `AliPlayerWidget` — **Playback UI widget**, which takes a Controller and renders the playback interface.
- `AliPlayerWidgetController` — **Playback controller**, which manages play, pause, Seek, full screen, and other operations in a unified way.
- `AliPlayerWidgetData` — **Playback configuration data**, which encapsulates the video source, title, cover, and other settings.

The correspondence is as follows:

| Migration Item  | chewie                                       | aliplayer_widget                          |
| --------------- | -------------------------------------------- | ----------------------------------------- |
| Player UI       | `Chewie`                                     | `AliPlayerWidget`                         |
| Playback control | `VideoPlayerController` + `ChewieController` | `AliPlayerWidgetController`               |
| Playback config | `ChewieController(...)`                      | `AliPlayerWidgetData(...)`                |
| Video source    | `VideoPlayerController.networkUrl(...)`      | `VideoSourceFactory.createUrlSource(...)` |

---

## **4. Migration Steps**

Migration principle: **coexist first, replace later**. Keep chewie during the migration; first pick a low-risk playback page to validate, then gradually replace the other pages.

### **Step 1: Add and Configure aliplayer_widget**

Add the `aliplayer_widget` dependency; do not remove the old dependencies yet:

```bash
flutter pub add aliplayer_widget
```

The corresponding `pubspec.yaml` change is as follows:

```diff
 dependencies:
   chewie: <your current version>
   video_player: <your current version>
+  aliplayer_widget: ^x.y.z
```

> We recommend using the latest version of aliplayer_widget; you can find all versions here: [Stable versions of aliplayer_widget](https://pub.dev/packages/aliplayer_widget/versions).

`flutter pub add` fetches the dependency automatically; if you modify `pubspec.yaml` manually, run:

```bash
flutter pub get
```

> `aliplayer_widget` already depends on `flutter_aliplayer`. You only need to add `flutter_aliplayer` explicitly when your application code imports and calls it directly.

Then follow [Obtain an ApsaraVideo Player SDK license](https://www.alibabacloud.com/help/en/vod/developer-reference/obtain-the-player-sdk-license) to complete the License configuration on Android and iOS. These are one-time integration steps and are not covered in detail in this document.

> For more integration and configuration details, see the aliplayer_widget [Integration Guide](../integration-guide-en.md).

### **Step 2: Replace One Player Page**

**This is the core step of migration, but the changes are not significant. **The two sets of APIs are highly aligned conceptually, with changes focused on Controller declaration, initialization, and destruction.

```diff
  import 'package:flutter/material.dart';
- import 'package:video_player/video_player.dart';
- import 'package:chewie/chewie.dart';
+ import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

  class VideoPage extends StatefulWidget {
    @override
    _VideoPageState createState() => _VideoPageState();
  }

  class _VideoPageState extends State<VideoPage> {
-   late VideoPlayerController _videoController;
-   late ChewieController _chewieController;
+   late AliPlayerWidgetController _controller;

    @override
    void initState() {
      super.initState();
-     _videoController = VideoPlayerController.networkUrl(
-       Uri.parse('https://example.com/video.mp4'),
-     );
-     _videoController.initialize().then((_) {
-       _chewieController = ChewieController(
-         videoPlayerController: _videoController,
-         autoPlay: true,
-       );
-       setState(() {});
-     });
+     _controller = AliPlayerWidgetController();
+     _controller.configure(AliPlayerWidgetData(
+       videoSource: VideoSourceFactory.createUrlSource(
+         'https://example.com/video.mp4',
+       ),
+       autoPlay: true,
+       // chewie allows screen sleep by default; set this explicitly to keep the pre-migration behavior.
+       allowedScreenSleep: true,
+     ));
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
-       body: Chewie(controller: _chewieController),
+       body: AliPlayerWidget(_controller),
      );
    }

    @override
    void dispose() {
-     _videoController.dispose();
-     _chewieController.dispose();
+     _controller.destroy();
      super.dispose();
    }
  }
```

At this stage, do not also modify quality switching, caching, downloads, or custom UI — first confirm that the original playback flow works normally. Once basic playback passes, migrate the differing items in the appendices according to your actual usage.

> For more complete examples, see the aliplayer_widget [Quick Start Guide](../quick-start-en.md).

### **Step 3: Compatibility Verification**

The underlying playback engine has changed, so you cannot verify only that "playback starts". Cover at least the following scenarios:

| Category            | Verification Items                                                  | Pass Criteria                                        |
| ------------------- | ------------------------------------------------------------------- | ---------------------------------------------------- |
| Basic playback      | First frame, play, pause, Seek, end                                 | Behavior consistent with pre-migration               |
| Video sources       | Protocols, formats, and authenticated URLs actually used in production | All can start and resume playback normally        |
| UI                  | Landscape/portrait, full screen, back key, notch/safe area          | No orientation glitches, occlusion, or inability to exit |
| Lifecycle           | Foreground/background switching, lock-screen recovery, page navigation | States meet business expectations, no unexpected audio |
| Weak network        | Loading, stalling, network loss, network recovery                   | Status prompts are correct; recovery or retry is possible |
| Multiple instances  | Lists, page switching, repeated creation and destruction            | No audio crosstalk, black screens, or resource leaks |
| Business features   | Analytics tracking, subtitles, playback speed, custom control bar   | No loss of existing capabilities                     |

### **Step 4: Gradual Rollout and Rollback**

If the impact scope is large, it is recommended to keep a unified player entry point at the business layer:

```dart
Widget buildPlayer({required bool useAliPlayer}) {
  return useAliPlayer ? buildAliPlayerWidget() : buildChewiePlayer();
}
```

This code only illustrates the selection relationship: **each page should create only the currently selected player and its Controller — never initialize both players at the same time**.

During the rollout, use the concurrent chewie group as the control baseline and monitor the metrics in the table below; if any core metric degrades significantly, simply turn off the switch to roll back — no emergency release needed.

| Dimension          | Core Metrics                                                              | Measurement Basis                                              |
| ------------------ | ------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Stability          | Crash rate, ANR rate                                                      | Share of sessions with a crash / no response on the player page |
| Playback startup   | Startup success rate, first-frame latency (P50, P95), instant-play rate   | Successful startups / playback requests; first-frame rendering latency; share of first frames rendered in under 1s |
| During playback    | Playback error rate and error-code distribution, stall rate, stall time share | Errors / successful startups; share of playbacks with stalls; stall duration / total playback duration |
| Playback consumption | Completion rate, playback duration per user, playback count per user    | Completed playbacks / successful startups; daily average playback duration and count per user |

### **Step 5: Clean Up Old Dependencies**

After all pages have been migrated and observations remain stable, remove chewie:

```bash
flutter pub remove chewie
```

```diff
 dependencies:
-  chewie: <your current version>
   video_player: <your current version>
   aliplayer_widget: ^x.y.z
```

Only after confirming that nothing in the project directly references `video_player`, remove it as well:

```bash
flutter pub remove video_player
```

```diff
 dependencies:
-  video_player: <your current version>
   aliplayer_widget: ^x.y.z
```

At this point, the migration has been completed. The following appendix is only used to handle the configuration and customization capabilities actually used in the original project.

---

## **Appendix A: Common Call Migration Table**

### **Playback Lifecycle**

| Function         | chewie                                  | aliplayer_widget                          |
| ---------------- | --------------------------------------- | ----------------------------------------- |
| URL data source  | `VideoPlayerController.networkUrl(uri)` | `VideoSourceFactory.createUrlSource(url)` |
| Playback config  | `ChewieController(...)`                 | `AliPlayerWidgetData(...)`                |
| Initialization   | `videoController.initialize()`          | `controller.configure(data)`              |
| Widget           | `Chewie(controller: controller)`        | `AliPlayerWidget(controller)`             |
| Destruction      | `dispose()` each of the two Controllers separately | `controller.destroy()`         |

### **Playback Control**

| Function                | chewie                                          | aliplayer_widget         |
| ----------------------- | ----------------------------------------------- | ------------------------ |
| Play                    | `await play()`                                  | `play()`                 |
| Pause                   | `await pause()`                                 | `pause()`                |
| Toggle playback state   | `togglePause()`                                 | `togglePlayState()`      |
| Seek                    | `await seekTo(Duration)`                        | `seek(Duration)`         |
| Playback speed          | `await videoController.setPlaybackSpeed(value)` | `setSpeed(speed: value)` |
| Volume                  | `await setVolume(value)`                        | `setVolume(value)`       |
| Mute                    | `await videoController.setVolume(0)`            | `await setMute(true)`    |
| Loop                    | `await setLooping(true)`                        | `await setLoop(true)`    |

### **Playback State and Full Screen**

| Function            | chewie                                   | aliplayer_widget                                   |
| ------------------- | ---------------------------------------- | -------------------------------------------------- |
| Current position    | `videoController.value.position`         | `currentPositionNotifier.value`                    |
| Total duration      | `videoController.value.duration`         | `totalDurationNotifier.value`                      |
| Buffered position   | `videoController.value.buffered`         | `bufferedPositionNotifier.value`                   |
| Playback state      | `videoController.value.isPlaying`        | `playStateNotifier.value == FlutterAvpdef.started` |
| Error state         | `videoController.value.hasError`         | `playStateNotifier.value == FlutterAvpdef.error`   |
| Error details       | `videoController.value.errorDescription` | `playErrorNotifier.value`                          |
| Full-screen state   | `chewieController.isFullScreen`          | `isFullScreenNotifier.value`                       |
| Enter full screen   | `enterFullScreen()`                      | `enterFullScreen()`                                |
| Exit full screen    | `exitFullScreen()`                       | `exitFullScreen()`                                 |
| Toggle full screen  | `toggleFullScreen()`                     | `toggleFullscreen()`                               |

For custom progress UI, you can directly replace the listened object with the corresponding `ValueNotifier`:

```diff
-ValueListenableBuilder<VideoPlayerValue>(
-  valueListenable: _videoController,
-  builder: (context, value, _) {
-    return Text('${value.position} / ${value.duration}');
+ListenableBuilder(
+  listenable: Listenable.merge([
+    _controller.currentPositionNotifier,
+    _controller.totalDurationNotifier,
+  ]),
+  builder: (context, _) {
+    final position = _controller.currentPositionNotifier.value;
+    final duration = _controller.totalDurationNotifier.value;
+    return Text('$position / $duration');
   },
 );
```

---

## Appendix B: Common Configuration Migration Table

Configurations that affect user experience should be set explicitly — do not rely on the respective default values of the two components.

### **Playback Behavior Configuration**

| chewie Configuration    | aliplayer_widget Equivalent                                        | Notes on Differences                                             |
| ----------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------------- |
| `autoInitialize: false` | Defer the call to `controller.configure(data)` until the business needs to prepare the player | No switch of the same name; `configure()` enters the preparation flow immediately |
| `autoPlay`              | `AliPlayerWidgetData(autoPlay: value)`                             | Direct correspondence; chewie defaults to `false`, this component defaults to `true` |
| `startAt: duration`     | `AliPlayerWidgetData(startTime: duration.inMilliseconds)`          | Direct correspondence; `startTime` is in milliseconds            |
| `looping`               | Call `await controller.setLoop(value)` after configuration is complete | Changes from a constructor parameter to a method call        |
| `isLive: true`          | `AliPlayerWidgetData(sceneType: SceneType.live)`                   | Direct correspondence                                            |
| `allowedScreenSleep`    | `AliPlayerWidgetData(allowedScreenSleep: value)`                   | Partial correspondence; chewie defaults to `true`, this component defaults to `false`, and the effective scope differs |
| `fullScreenByDefault`   | After the Widget is mounted, call `controller.enterFullScreen()` when playback first starts | No configuration item of the same name; control the trigger timing yourself |
| `playbackSpeeds`        | `AliPlayerWidgetData(playbackSpeeds: [...])`                 | Direct correspondence; configure custom playback speed options |
| `hideControlsTimer`     | `AliPlayerWidgetData(autoHideControlsDuration: ...)`         | Direct correspondence; configure the auto-hide duration for playback controls |
| `chapters`              | `AliPlayerWidgetData(sceneType: SceneType.aiVod, chapters: [...])`  | chewie uses `ChewieChapter(title, start)`; aliplayer_widget uses `ChapterInfo(startMs, endMs, title)` — the end time must be specified explicitly, and `sceneType` must be `aiVod` |

### **UI and Customization Configuration**

UI customization in `aliplayer_widget` is divided into three tiers by ascending cost. **Try them from top to bottom in order — do not jump straight to slot customization**:

| Priority | Customization Approach                  | Applicable Situation                                          |
| -------- | --------------------------------------- | ------------------------------------------------------------- |
| 1        | `AliPlayerWidgetData(sceneType: ...)`   | The default UI already covers your needs; you only need to switch scene forms |
| 2        | `hiddenSlotElements`                    | Keep the default UI; only hide some entry points (corresponds to chewie's various `allowXxx: false`) |
| 3        | `slotBuilders`                          | The default UI cannot satisfy your needs; you must draw a certain area yourself (corresponds to chewie's `customControls` and other builders) |

Therefore, if the original project uses the chewie default UI, **no slot customization is needed** — just use `AliPlayerWidget(_controller)` and declare `sceneType` according to your business; the component will automatically present the default UI for that scene:

| sceneType              | Applicable Scenario     | Relationship to chewie                                       |
| ---------------------- | ----------------------- | ------------------------------------------------------------ |
| `SceneType.vod`        | Video on demand         | Corresponds to chewie's default form                         |
| `SceneType.live`       | Live streaming          | Corresponds to `isLive: true`                                |
| `SceneType.listPlayer` | List / feed playback    | No corresponding chewie configuration                        |
| `SceneType.restricted` | Restricted playback scenarios | No corresponding chewie configuration                  |
| `SceneType.minimal`    | Minimal UI              | Close to `showControls: false`, but also hides the cover, subtitles, and gestures |
| `SceneType.aiVod`      | AI-enhanced VOD          | Inherits VOD capabilities with chapter navigation support; a scene-level upgrade for chewie's `chapters` configuration |

The table below shows where each chewie UI configuration item lands in the three-tier customization system:

| chewie Configuration                   | aliplayer_widget Equivalent                                    | Notes on Differences                                           |
| -------------------------------------- | -------------------------------------------------------------- | -------------------------------------------------------------- |
| `placeholder` (network image)          | `AliPlayerWidgetData(coverUrl: url)`                           | Cover-image configuration replaces the static placeholder; only applies to URL images |
| `placeholder` (arbitrary Widget)       | Custom `SlotType.coverImage`                                   | You must hide it yourself after the first frame is rendered    |
| `overlay`                              | Custom `SlotType.overlays`                                     | The original overlay must be rewritten as a slot builder       |
| `customControls`                       | Replace by slot via `slotBuilders` (`topBar`, `bottomBar`, `playState`, etc.) | Not a one-to-one replacement; changes from "replace the entire control layer" to "fine-grained replacement by area" — unspecified areas keep the default UI |
| `showControls: false`                  | `sceneType: SceneType.minimal`, or turn off control-bar-related slots | Partial correspondence; `minimal` also hides the cover, subtitles, and gestures |
| `showOptions: false`                   | Hide `TopBarElements.settings`, `BottomBarElements.speed`, and `BottomBarElements.quality` | The landscape bottom-bar entry point must be handled as well |
| `optionsBuilder` / `additionalOptions` | Custom `SlotType.settingMenu`                                  | The original options UI and tap logic must be rebuilt          |
| `errorBuilder`                         | Listen to `playStateNotifier` + `playErrorNotifier`, or customize `SlotType.playState` | Supports both reactive listening and slot replacement; check the error state first, then read the error details |
| `bufferingBuilder`                     | Use the built-in loading animation, or customize `SlotType.playState` and listen to `isLoadingStateNotifier` | A loading-state UI is provided by default; customize only when needed |
| `subtitle` / `subtitleBuilder`         | `externalSubtitleUrl` + `SubtitleConfig` + custom `SubtitleBuilder` | Supports automatic loading of external subtitle URLs        |

### **Hiding Entry Points Already Disabled in the Original Project**

UI-disabling needs are often not a few buttons, but **a whole set of business rules**. Before making changes, first attribute the requirement to a scenario, then decide whether to hide elements one by one or simply switch scenes.

| Disabling Source        | Characteristics                          | Handling Order                                                |
| ----------------------- | ---------------------------------------- | ------------------------------------------------------------- |
| **Scenario-based disabling** | A batch of entry points is uniformly turned off by the same business rule | First choose the matching `sceneType`, then use `hiddenSlotElements` to fill remaining gaps after real-device testing |
| **One-off disabling**   | Only individual entry points are turned off due to product preference, unrelated to the scenario | Use `hiddenSlotElements` directly                   |

Common attribution examples:

| Original chewie Configuration                          | Scenario Attribution             | Recommendation                                              |
| ------------------------------------------------------ | -------------------------------- | ----------------------------------------------------------- |
| `allowPlaybackSpeedChanging: false` + progress bar dragging disabled | Education/exam courses that require full viewing | First evaluate whether `SceneType.restricted` already covers this; "progress bar shown but not draggable" is a to-be-confirmed item |
| `isLive: true` + progress bar hidden                   | Live streaming                   | `SceneType.live`                                            |
| Muted auto-play in a list, no control bar shown        | Feed / list playback             | `SceneType.listPlayer` or `SceneType.minimal`               |
| Only the full-screen button turned off (the page itself does not support landscape) | One-off product preference | Hide `BottomBarElements.fullscreen` directly          |

After confirming one-off disabling (or filling scenario gaps), hide the corresponding elements as in the following example:

```diff
+import 'package:aliplayer_widget/slot/slot_elements.dart';

-final chewieController = ChewieController(
-  videoPlayerController: videoController,
-  allowFullScreen: false,
-  allowMuting: false,
-  allowPlaybackSpeedChanging: false,
-);
+final player = AliPlayerWidget(
+  _controller,
+  hiddenSlotElements: const {
+    SlotType.bottomBar: {
+      BottomBarElements.fullscreen,
+      BottomBarElements.speed,
+    },
+    SlotType.settingMenu: {
+      SettingMenuElements.mute,
+      SettingMenuElements.volume,
+      SettingMenuElements.speed,
+    },
+    SlotType.playControl: {
+      PlayControlElements.rightVerticalDrag,
+      PlayControlElements.longPress,
+    },
+  },
+);
```

`hiddenSlotElements` only hides entry points in the default UI; it does not prevent business code from calling the corresponding Controller methods. When you need to restrict playback behavior, also restrict the calling entry points on the business side.

### **Replacing Partial Control UI**

If the original project uses `customControls`, replace only the areas that differ:

```diff
-ChewieController(
-  videoPlayerController: _videoController,
-  customControls: MyControls(_videoController),
-)
+AliPlayerWidget(
+  _controller,
+  slotBuilders: {
+    SlotType.topBar: (context) => const MyTopBar(),
+    SlotType.bottomBar: (context) => MyBottomBar(_controller),
+  },
+)
```

`MyTopBar` and `MyBottomBar` in this example represent the application's existing custom components; they are not part of the `aliplayer_widget` public API.

---

## **Appendix C: Capabilities Requiring Separate Confirmation**

The following chewie capabilities have no one-to-one configuration in the verified public interfaces of `aliplayer_widget`. Before migrating pages that use these capabilities, complete dedicated verification or confirm an alternative.

| chewie Capability                                              | Status  | Current Recommendation                                       |
| -------------------------------------------------------------- | ------- | ------------------------------------------------------------ |
| `draggableProgressBar: false` while still showing the progress bar | **TBD** | You can hide the progress bar or customize the bottom bar; no direct "shown but not draggable" configuration was found |
| `showPlayButton`                                               | **TBD** | No one-to-one switch for the large play button was found     |
| `aspectRatio`                                                  | **TBD** | The component computes the display area from the video size; there is no need to force an aspect ratio |
| `materialProgressColors`, `cupertinoProgressColors`            | **TBD** | No one-to-one parameters for progress bar colors were found; to keep brand styling, use a custom bottom bar and verify it separately |
| `zoomAndPan`, `maxScale`, `transformationController`           | **TBD** | No corresponding zoom and pan configuration was found        |
| `pauseOnBackgroundTap`                                         | **TBD** | No public configuration of the same name or equivalent was found |
| `routePageBuilder`, orientation and system-bar configuration around full screen | **TBD** | Full-screen methods are provided, but no one-to-one external configuration was found for these full-screen page details |
| `progressIndicatorDelay`, `controlsSafeAreaMinimum`                      | **TBD** | No public configuration of the same name or equivalent was found; use custom slots if there is a strong need |
| chewie in-memory subtitle list                                 | **TBD** | External subtitle URLs are supported, but it is unconfirmed whether chewie's in-memory subtitle data can be accepted directly |
| Web and desktop platforms                                      | **TBD** | The current documentation explicitly covers Android and iOS; keep the original implementation on other platforms |

---

## **Appendix D: Enhanced Capabilities Available After Migration**

The following features are not supported in chewie and are not prerequisites for completing the migration. Finish the player replacement first, then adopt each one as your business requires:

| Capability            | Description                                  | Entry Point                                                    |
| --------------------- | -------------------------------------------- | -------------------------------------------------------------- |
| Quality / multi-bitrate switching | Switch video quality at runtime  | `controller.selectTrack(trackInfo)` + `trackInfoListNotifier`  |
| VID / STS playback    | Alibaba Cloud video ID + STS token authentication | `VideoSourceFactory.createVidStsSource(...)`              |
| VID / PlayAuth playback | Alibaba Cloud video ID + PlayAuth authentication | `VideoSourceFactory.createVidAuthSource(...)`            |
| Snapshot              | Capture the current video frame              | `controller.snapshot(path)`                                    |
| Video caching / preloading | Configure local caching; adopt preloading as needed | `AliPlayerWidgetGlobalSetting.setStoragePaths(...)`; for preloading, use `flutter_aliplayer`'s `FlutterAliPlayerMediaLoader` |
| Video download        | Download VID playback sources locally        | Call `controller.startVideoDownload()` after configuring the storage path |
| Scene types           | Adjust default UI behavior by scenario       | `SceneType.vod` / `.live` / `.listPlayer` / `.restricted` / `.minimal` / `.aiVod` |
| Chapter navigation    | Progress-bar chapter markers + chapter Chip list + chapter panel | `AliPlayerWidgetData(sceneType: SceneType.aiVod, chapters: [...])` |
| Slot UI customization | Multi-level slot system for fine-grained control of each area | `slotBuilders` + `hiddenSlotElements`             |
| Gesture control       | Long-press for speed, horizontal drag to Seek, vertical drag for volume/brightness | Built in, no extra configuration needed |
| Thumbnail preview     | Show thumbnails while Seeking                | `AliPlayerWidgetData(thumbnailUrl: ...)` + `thumbnailNotifier` |
| Internationalization  | Built-in Chinese and English; extensible language packs | `AliPlayerWidgetGlobalSetting.initI18n()`             |

---

## **Appendix E: Video Source Migration (optional)**

URL playback uses `VideoSourceFactory.createUrlSource(url)` from the main flow. If you want to switch to Alibaba Cloud VOD authentication, choose VID + PlayAuth or VID + STS per [Video Source Support](../advanced/video-source-support-en.md). This is not a prerequisite for completing the chewie migration.

| Original Video Source                   | Migration Status | Recommendation                                               |
| --------------------------------------- | ---------------- | ------------------------------------------------------------ |
| `VideoPlayerController.networkUrl(...)` | Supported        | Use `VideoSourceFactory.createUrlSource(url)`                |
| Network URL with custom HTTP headers    | **TBD**          | `createUrlSource` has no header parameter; confirm the underlying configuration approach before switching — do not simply discard the original headers |
| `VideoPlayerController.asset(...)`      | **TBD**          | `VideoSourceFactory` currently has no asset-specific entry point; keep chewie for this playback path for now |
| `VideoPlayerController.file(...)`       | **TBD**          | `VideoSourceFactory` currently has no local-file-specific entry point; do not assume `file://` can be used directly as a substitute |

Pages using **TBD** video sources should continue to keep chewie, and migrate only after an alternative has been confirmed and verified on real devices.

# **从 chewie 迁移到 aliplayer_widget**

本文档帮助您以尽可能少的改动，将现有 Flutter 项目的播放 UI 从 chewie 迁移到 aliplayer_widget。

---

## **1. 迁移说明**

chewie 与 aliplayer_widget 同为包含播放 UI 的 Flutter 组件，因此本次迁移属于**同层组件替换**，只需改动 UI 组件层：

| 层级           | 迁移前         | 迁移后              | 是否需要直接接入   |
| -------------- | -------------- | ------------------- | ------------------ |
| 播放器 UI 组件 | `chewie`       | `aliplayer_widget`  | 是，本指南的主路径 |
| 播放器 SDK     | `video_player` | `flutter_aliplayer` | 通常不需要         |

---

## **2. 迁移收益**

* **同层替换的直接收益**
  - **更强大的底层引擎** — flutter_aliplayer 替代 video_player，支持更多协议与格式
  - **更简洁的 API 设计** — 从双 controller（VideoPlayerController + ChewieController）简化为单 controller
  - **更灵活的架构扩展** — 多层级插槽系统替代单一 `customControls` 参数，并通过策略系统支撑业务逻辑扩展

* **端云协同的增量能力**
  * **媒资信息开箱即用** — 播放入口从 URL 升级为 VID，封面、标题、多档清晰度、Seek 缩略图由云端直接下发，业务侧无需再维护元信息透传链路
  * **播放方式与安全鉴权** — 基于 PlayAuth / STS 凭证播放，天然支持防盗链、时效控制，无需暴露源地址

---

## **3. 核心 API 对照**

迁移主要涉及以下三个类：

- `AliPlayerWidget` — **播放 UI 组件**，接收 Controller 并渲染播放界面。
- `AliPlayerWidgetController` — **播放控制器**，统一管理播放、暂停、Seek 和全屏等操作。
- `AliPlayerWidgetData` — **播放配置数据**，封装视频源、标题和封面等配置。

对应关系如下：

| 迁移内容  | chewie                                       | aliplayer_widget                          |
| --------- | -------------------------------------------- | ----------------------------------------- |
| 播放器 UI | `Chewie`                                     | `AliPlayerWidget`                         |
| 播放控制  | `VideoPlayerController` + `ChewieController` | `AliPlayerWidgetController`               |
| 播放配置  | `ChewieController(...)`                      | `AliPlayerWidgetData(...)`                |
| 视频源    | `VideoPlayerController.networkUrl(...)`      | `VideoSourceFactory.createUrlSource(...)` |

---

## **4. 迁移步骤**

迁移原则：**先并存，后替换**。迁移期间保留 chewie，先选择一个低风险播放页面完成验证，再逐步替换其他页面。

### **步骤 1：添加并配置 aliplayer_widget**

添加 `aliplayer_widget` 依赖，暂不删除旧依赖：

```bash
flutter pub add aliplayer_widget
```

对应的 `pubspec.yaml` 变更如下：

```diff
 dependencies:
   chewie: <当前使用的版本>
   video_player: <当前使用的版本>
+  aliplayer_widget: ^x.y.z
```

> 我们建议您使用最新版本的 aliplayer_widget，您可以在此处找到所有版本：[Stable versions of aliplayer_widget](https://pub.dev/packages/aliplayer_widget/versions)。

使用 `flutter pub add` 时会自动获取依赖；如果手动修改 `pubspec.yaml`，请执行：

```bash
flutter pub get
```

> `aliplayer_widget` 已依赖 `flutter_aliplayer`。只有应用代码需要直接导入和调用 `flutter_aliplayer` 时，才需要显式添加它。

然后按照 [获取播放器SDK License](https://help.aliyun.com/zh/vod/developer-reference/obtain-the-player-sdk-license) 完成 License 在 Android、iOS 平台的配置。这些属于一次性接入步骤，本文不再展开。

> 更多集成与配置说明，请参见 aliplayer_widget [集成指引](../integration-guide.md)。

### **步骤 2：替换一个播放器页面**

**这是迁移的核心步骤，但改动不大。**两套 API 在概念上高度对齐，改动集中在 Controller 声明、初始化和销毁三处。

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
+       // chewie 默认允许休眠；显式设置以保持迁移前行为。
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

此阶段请勿同时改造清晰度、缓存、下载和自定义 UI，先确认原有播放流程正常。基础播放通过后，再按实际使用范围迁移附录中的差异项。

> 更多完整示例，请参见 aliplayer_widget [快速开始](../quick-start.md)。

### **步骤 3：兼容性验证**

底层播放引擎发生了变化，不能只验证“能够起播”。至少覆盖以下场景：

| 类别     | 验证项                             | 通过标准                     |
| -------- | ---------------------------------- | ---------------------------- |
| 基础播放 | 首帧、播放、暂停、Seek、结束       | 行为与迁移前一致             |
| 视频源   | 业务实际使用的协议、格式、鉴权 URL | 均可正常起播和续播           |
| UI       | 横竖屏、全屏、返回键、刘海/安全区  | 无方向错乱、遮挡或无法退出   |
| 生命周期 | 前后台切换、锁屏恢复、页面切换     | 状态符合业务预期，无异常声音 |
| 弱网     | 加载、卡顿、断网、恢复网络         | 状态提示正确，可恢复或重试   |
| 多实例   | 列表、页面切换、连续创建销毁       | 无串音、黑屏、资源泄漏       |
| 业务能力 | 埋点、字幕、倍速、自定义控制栏     | 原有能力不丢失               |

### **步骤 4：灰度与回滚**

若影响范围较大，建议在业务层保留统一的播放器入口：

```dart
Widget buildPlayer({required bool useAliPlayer}) {
  return useAliPlayer ? buildAliPlayerWidget() : buildChewiePlayer();
}
```

该代码仅表示选择关系：**每个页面只创建当前选中的播放器及其 Controller，切勿同时初始化两套播放器**。

灰度期间以同期 chewie 分组为对照基线，按下表监控指标；任一核心指标出现显著劣化，关闭开关即可回退，无需紧急发版。

| 维度     | 核心指标                                     | 统计口径                                                     |
| -------- | -------------------------------------------- | ------------------------------------------------------------ |
| 稳定性   | 崩溃率、ANR 率                               | 播放页发生崩溃 / 无响应的会话占比                            |
| 起播     | 起播成功率、首帧耗时（P50、P95）、秒开率     | 起播成功次数 / 播放请求次数；首帧渲染耗时；首帧耗时低于 1s 的占比 |
| 播放中   | 播放错误率及错误码分布、卡顿率、卡顿时长占比 | 报错次数 / 起播成功次数；发生卡顿的播放占比；卡顿时长 / 总播放时长 |
| 播放消费 | 播放完成率、人均播放时长、人均播放次数       | 完成播放次数 / 起播成功次数；单用户日均播放时长与次数        |

### **步骤 5：清理旧依赖**

全部页面迁移完成且观察稳定后，移除 chewie：

```bash
flutter pub remove chewie
```

```diff
 dependencies:
-  chewie: <当前使用的版本>
   video_player: <当前使用的版本>
   aliplayer_widget: ^x.y.z
```

仅在确认项目中没有任何直接引用后，再删除 `video_player`：

```bash
flutter pub remove video_player
```

```diff
 dependencies:
-  video_player: <当前使用的版本>
   aliplayer_widget: ^x.y.z
```

至此，迁移已完成。以下附录仅用于处理原项目实际使用到的配置与自定义能力。

---

## **附录 A：常用调用迁移表**

### **播放生命周期**

| 功能       | chewie                                  | aliplayer_widget                          |
| ---------- | --------------------------------------- | ----------------------------------------- |
| URL 数据源 | `VideoPlayerController.networkUrl(uri)` | `VideoSourceFactory.createUrlSource(url)` |
| 播放配置   | `ChewieController(...)`                 | `AliPlayerWidgetData(...)`                |
| 初始化     | `videoController.initialize()`          | `controller.configure(data)`              |
| Widget     | `Chewie(controller: controller)`        | `AliPlayerWidget(controller)`             |
| 销毁       | 两个 Controller 分别 `dispose()`        | `controller.destroy()`                    |

### **播放控制**

| 功能         | chewie                                          | aliplayer_widget         |
| ------------ | ----------------------------------------------- | ------------------------ |
| 播放         | `await play()`                                  | `play()`                 |
| 暂停         | `await pause()`                                 | `pause()`                |
| 切换播放状态 | `togglePause()`                                 | `togglePlayState()`      |
| Seek         | `await seekTo(Duration)`                        | `seek(Duration)`         |
| 倍速         | `await videoController.setPlaybackSpeed(value)` | `setSpeed(speed: value)` |
| 音量         | `await setVolume(value)`                        | `setVolume(value)`       |
| 静音         | `await videoController.setVolume(0)`            | `await setMute(true)`    |
| 循环         | `await setLooping(true)`                        | `await setLoop(true)`    |

### **播放状态与全屏**

| 功能     | chewie                                   | aliplayer_widget                                   |
| -------- | ---------------------------------------- | -------------------------------------------------- |
| 当前进度 | `videoController.value.position`         | `currentPositionNotifier.value`                    |
| 总时长   | `videoController.value.duration`         | `totalDurationNotifier.value`                      |
| 缓冲位置 | `videoController.value.buffered`         | `bufferedPositionNotifier.value`                   |
| 播放状态 | `videoController.value.isPlaying`        | `playStateNotifier.value == FlutterAvpdef.started` |
| 错误状态 | `videoController.value.hasError`         | `playStateNotifier.value == FlutterAvpdef.error`   |
| 错误详情 | `videoController.value.errorDescription` | `playErrorNotifier.value`                          |
| 全屏状态 | `chewieController.isFullScreen`          | `isFullScreenNotifier.value`                       |
| 进入全屏 | `enterFullScreen()`                      | `enterFullScreen()`                                |
| 退出全屏 | `exitFullScreen()`                       | `exitFullScreen()`                                 |
| 切换全屏 | `toggleFullScreen()`                     | `toggleFullscreen()`                               |

自定义进度 UI 可直接将监听对象替换为对应的 `ValueNotifier`：

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

## 附录 B：常用配置迁移表

会影响用户体验的配置应显式设置，不要依赖两个组件各自的默认值。

### **播放行为配置**

| chewie 配置             | aliplayer_widget 对应方式                                    | 差异说明                                                     |
| ----------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `autoInitialize: false` | 推迟调用 `controller.configure(data)`，直到业务需要准备播放器 | 无同名开关；`configure()` 会直接进入准备流程                 |
| `autoPlay`              | `AliPlayerWidgetData(autoPlay: value)`                       | 直接对应；chewie 默认 `false`，本组件默认 `true`             |
| `startAt: duration`     | `AliPlayerWidgetData(startTime: duration.inMilliseconds)`    | 直接对应；`startTime` 单位为毫秒                             |
| `looping`               | 配置完成后调用 `await controller.setLoop(value)`             | 从构造参数变为方法调用                                       |
| `isLive: true`          | `AliPlayerWidgetData(sceneType: SceneType.live)`             | 直接对应                                                     |
| `allowedScreenSleep`    | `AliPlayerWidgetData(allowedScreenSleep: value)`             | 部分对应；chewie 默认 `true`，本组件默认 `false`，且生效范围不同 |
| `fullScreenByDefault`   | Widget 挂载后，在首次播放开始时调用 `controller.enterFullScreen()` | 无同名配置项，需自行控制触发时机                             |

### **UI 与自定义配置**

`aliplayer_widget` 的 UI 定制按成本从低到高分三级，**请从上往下依次尝试，不要直接跳到插槽改造**：

| 优先级 | 定制方式                              | 适用情况                                                     |
| ------ | ------------------------------------- | ------------------------------------------------------------ |
| 1      | `AliPlayerWidgetData(sceneType: ...)` | 默认 UI 已覆盖需求，只需切换场景形态                         |
| 2      | `hiddenSlotElements`                  | 沿用默认 UI，仅需隐藏部分入口（对应 chewie 的各类 `allowXxx: false`） |
| 3      | `slotBuilders`                        | 默认 UI 无法满足，需要自绘某一区域（对应 chewie 的 `customControls` 等 builder） |

因此，若原项目使用 chewie 默认 UI，**无需任何插槽改造**，只需 `AliPlayerWidget(_controller)` 并按业务声明 `sceneType`，组件会自动呈现该场景下的默认 UI：

| sceneType              | 适用场景          | 与 chewie 的关系                                       |
| ---------------------- | ----------------- | ------------------------------------------------------ |
| `SceneType.vod`        | 点播              | 对应 chewie 默认形态                                   |
| `SceneType.live`       | 直播              | 对应 `isLive: true`                                    |
| `SceneType.listPlayer` | 列表 / 信息流播放 | chewie 无对应配置                                      |
| `SceneType.restricted` | 播放能力受限场景  | chewie 无对应配置                                      |
| `SceneType.minimal`    | 极简 UI           | 接近 `showControls: false`，但还会隐藏封面、字幕和手势 |

下表列出 chewie 各 UI 配置项在三级定制体系中的落点：

| chewie 配置                            | aliplayer_widget 对应方式                                    | 差异说明                                                     |
| -------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `placeholder`（网络图片）              | `AliPlayerWidgetData(coverUrl: url)`                         | 通过封面图配置替代静态占位，仅适用于 URL 图片                |
| `placeholder`（任意 Widget）           | 自定义 `SlotType.coverImage`                                 | 需自行在首帧渲染后隐藏                                       |
| `overlay`                              | 自定义 `SlotType.overlays`                                   | 需将原浮层改写为插槽构建器                                   |
| `customControls`                       | `slotBuilders` 按插槽替换（`topBar`、`bottomBar`、`playState` 等） | 非一对一替换；从「替换整个控制层」变为「按区域精细替换」，未指定区域沿用默认 UI |
| `showControls: false`                  | `sceneType: SceneType.minimal`，或关闭控制栏相关插槽         | 部分对应；`minimal` 还会隐藏封面、字幕和手势                 |
| `showOptions: false`                   | 隐藏 `TopBarElements.settings`、`BottomBarElements.speed` 和 `BottomBarElements.quality` | 需同时处理横屏底部入口                                       |
| `optionsBuilder` / `additionalOptions` | 自定义 `SlotType.settingMenu`                                | 需重建原有选项 UI 和点击逻辑                                 |
| `errorBuilder`                         | 监听 `playStateNotifier` + `playErrorNotifier`，或自定义 `SlotType.playState` | 支持响应式监听与插槽替换两种方式；先判断错误状态，再读取错误详情 |
| `bufferingBuilder`                     | 使用内置加载动画，或自定义 `SlotType.playState` 并监听 `isLoadingStateNotifier` | 默认已提供加载状态 UI，仅在需要定制时改造                    |
| `subtitle` / `subtitleBuilder`         | `externalSubtitleUrl` + `SubtitleConfig` + 自定义 `SubtitleBuilder` | 支持外挂字幕 URL 自动加载                                    |

### **隐藏原项目已禁用的入口**

UI 禁用需求往往不是几个按钮，而是**一整套业务规则**。动手前应先做场景归因，再决定是逐元素隐藏还是直接换场景。

| 禁用来源       | 特征                                 | 处理顺序                                                     |
| -------------- | ------------------------------------ | ------------------------------------------------------------ |
| **场景性禁用** | 一批入口因同一业务规则被统一关闭     | 先选匹配的 `sceneType`，实测后再用 `hiddenSlotElements` 补齐差异 |
| **单点禁用**   | 仅个别入口因产品偏好关闭，与场景无关 | 直接使用 `hiddenSlotElements`                                |

常见归因示例：

| 原 chewie 配置                                       | 场景归因                       | 建议                                                         |
| ---------------------------------------------------- | ------------------------------ | ------------------------------------------------------------ |
| `allowPlaybackSpeedChanging: false` + 禁止拖动进度条 | 教育、考试类课程，要求完整观看 | 先评估 `SceneType.restricted` 是否已覆盖；「进度条显示但不可拖动」属待确认项 |
| `isLive: true` + 隐藏进度条                          | 直播                           | `SceneType.live`                                             |
| 列表内静音自动播放、不展示控制栏                     | 信息流 / 列表播放              | `SceneType.listPlayer` 或 `SceneType.minimal`                |
| 仅关闭全屏按钮（页面本身不支持横屏）                 | 单点产品偏好                   | 直接隐藏 `BottomBarElements.fullscreen`                      |

确认为单点禁用（或用于补齐场景差异）后，再按下例隐藏对应元素：

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

`hiddenSlotElements` 只隐藏默认 UI 中的入口，不会禁止业务代码调用对应的 Controller 方法。需要限制播放行为时，请同时限制业务侧调用入口。

### **替换局部控制 UI**

若原项目使用 `customControls`，只替换存在差异的区域：

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

示例中的 `MyTopBar` 和 `MyBottomBar` 代表应用已有的自定义组件，不是 `aliplayer_widget` 对外 API。

---

## **附录 C：需要单独确认的能力**

下列 chewie 能力在已核对的 `aliplayer_widget` 对外接口中未找到一对一配置。迁移使用到这些能力的页面前，应先完成专项验证或确认替代方案。

| chewie 能力                                                  | 状态    | 当前建议                                                     |
| ------------------------------------------------------------ | ------- | ------------------------------------------------------------ |
| 自定义 `playbackSpeeds` 可选列表                             | **TBD** | `setSpeed(speed: value)` 可设置当前倍速，但未确认默认设置面板的可选列表可由外部配置 |
| `draggableProgressBar: false` 且仍显示进度条                 | **TBD** | 可隐藏进度条或自定义底部栏；未找到「显示但不可拖动」的直接配置 |
| `showPlayButton`                                             | **TBD** | 未找到大播放按钮的一对一开关                                 |
| `aspectRatio`                                                | **TBD** | 组件会根据视频尺寸计算显示区域；无需再强制指定宽高比         |
| `materialProgressColors`、`cupertinoProgressColors`          | **TBD** | 未找到进度条颜色的一对一参数；如需保留品牌样式，使用自定义底部栏并专项验证 |
| `chapters`                                                   | **TBD** | 未找到 chewie 章节列表的一对一数据入口                       |
| `zoomAndPan`、`maxScale`、`transformationController`         | **TBD** | 未找到对应的缩放和平移配置                                   |
| `pauseOnBackgroundTap`                                       | **TBD** | 未找到同名或等价的公开配置                                   |
| `routePageBuilder`、全屏前后方向和系统栏配置                 | **TBD** | 全屏方法已提供，但未找到这些全屏页面细节的一对一外部配置     |
| `hideControlsTimer`、`progressIndicatorDelay`、`controlsSafeAreaMinimum` | **TBD** | 未找到同名或等价的公开配置；有强需求时使用自定义插槽         |
| chewie 内存字幕列表                                          | **TBD** | 已支持外挂字幕 URL，但未确认可直接接收 chewie 的内存字幕数据 |
| Web 和桌面平台                                               | **TBD** | 当前文档明确覆盖 Android 和 iOS；其他平台继续保留原实现      |

---

## **附录 D：迁移后可用的增强能力**

以下功能在 chewie 中不支持，也不是完成迁移的前置条件。请先完成播放器替换，再按业务需要逐项接入：

| 能力                | 说明                                       | 入口                                                         |
| ------------------- | ------------------------------------------ | ------------------------------------------------------------ |
| 清晰度/多码率切换   | 运行时切换视频清晰度                       | `controller.selectTrack(trackInfo)` + `trackInfoListNotifier` |
| VID / STS 播放      | 阿里云视频 ID + STS 令牌鉴权               | `VideoSourceFactory.createVidStsSource(...)`                 |
| VID / PlayAuth 播放 | 阿里云视频 ID + PlayAuth 鉴权              | `VideoSourceFactory.createVidAuthSource(...)`                |
| 截图                | 截取当前视频帧                             | `controller.snapshot(path)`                                  |
| 视频缓存/预加载     | 配置本地缓存；按需接入预加载               | `AliPlayerWidgetGlobalSetting.setStoragePaths(...)`；预加载使用 `flutter_aliplayer` 的 `FlutterAliPlayerMediaLoader` |
| 视频下载            | 将 VID 播放源下载到本地                    | 配置存储路径后调用 `controller.startVideoDownload()`         |
| 场景类型            | 按场景调整默认 UI 行为                     | `SceneType.vod` / `.live` / `.listPlayer` / `.restricted` / `.minimal` |
| 插槽 UI 定制        | 多层级插槽系统，精细控制各区域             | `slotBuilders` + `hiddenSlotElements`                        |
| 手势控制            | 长按倍速、水平拖动 Seek、垂直拖动音量/亮度 | 内置，无需额外配置                                           |
| 缩略图预览          | Seek 过程中显示缩略图                      | `AliPlayerWidgetData(thumbnailUrl: ...)` + `thumbnailNotifier` |
| 国际化              | 内置中英文，支持扩展语言包                 | `AliPlayerWidgetGlobalSetting.initI18n()`                    |

---

## **附录 E：视频源迁移（可选）**

URL 播放使用主流程中的 `VideoSourceFactory.createUrlSource(url)`。如需改用阿里云视频点播鉴权，可按 [视频源支持](../advanced/video-source-support.md) 选择 VID + PlayAuth 或 VID + STS。这不是完成 chewie 迁移的前置条件。

| 原视频源                                | 迁移状态 | 处理建议                                                     |
| --------------------------------------- | -------- | ------------------------------------------------------------ |
| `VideoPlayerController.networkUrl(...)` | 已支持   | 使用 `VideoSourceFactory.createUrlSource(url)`               |
| 带自定义 HTTP Header 的网络 URL         | **TBD**  | `createUrlSource` 无 Header 参数；确认底层配置方案后再切换，不能直接丢弃原 Header |
| `VideoPlayerController.asset(...)`      | **TBD**  | 当前 `VideoSourceFactory` 无 Asset 专用入口；该播放路径暂时保留 chewie |
| `VideoPlayerController.file(...)`       | **TBD**  | 当前 `VideoSourceFactory` 无本地文件专用入口；不要假设 `file://` 可直接替代 |

使用 **TBD** 播放源的页面应继续保留 chewie，确认替代方案并完成真机验证后再迁移。

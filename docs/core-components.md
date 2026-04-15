# **AliPlayerWidget 核心组件**

AliPlayerWidget 采用类似 MVC 的分层设计，将视图（View）、控制逻辑（Controller）和数据模型（Data）拆分为三个核心组件，它们协同工作以实现完整的视频播放功能。

## **1. AliPlayerWidget (View)**

`AliPlayerWidget` 是核心的播放器组件（View），用于嵌入到 Flutter 应用中并播放视频。

### **1.1 构造函数**

```dart
AliPlayerWidget(
  AliPlayerWidgetController controller, {
  Key? key,
  List<Widget> overlays = const [],
  Map<SlotType, SlotWidgetBuilder?> slotBuilders = const {},
  OnBackPressedCallback? onBackPressed,
});
```

- **`controller`**: 播放器控制器，用于管理播放逻辑。
- **`overlays`**: 可选的浮层组件列表，用于在播放器组件上叠加自定义 UI（已废弃，建议使用 `slotBuilders`）。
- **`slotBuilders`**: 可选的插槽构建器映射，允许自定义各个插槽的构建方式。详见 [插槽系统](slot-system.md)。
- **`onBackPressed`**: 可选的返回按钮点击回调。当用户按下返回键时调用。返回 `true` 表示已处理返回事件，不再执行默认行为；返回 `false` 或 `null` 将执行默认行为（`Navigator.pop`）。

### **1.2 返回事件处理（可选）**

默认情况下，当用户按下返回键时：
1. 如果当前处于全屏模式，会先退出全屏
2. 如果提供了 `onBackPressed` 回调，会调用该回调
3. 如果回调返回 `false` 或 `null`，执行默认的 `Navigator.pop()`

通过 `onBackPressed` 回调，您可以完全自定义返回行为：

```dart
AliPlayerWidget(
  _controller,
  onBackPressed: () {
    // 自定义返回逻辑
    Navigator.of(context).pop();
    return true; // 返回 true 表示已处理，不再执行默认行为
  },
);
```

## **2. AliPlayerWidgetController (Controller)**

`AliPlayerWidgetController` 是播放器组件的控制器（Controller），用于管理播放器组件的初始化、播放、销毁等逻辑。

### **2.1 主要方法**

- **`configure(AliPlayerWidgetData data)`**: 配置数据源。
- **`play()`**: 开始播放视频。
- **`pause()`**: 暂停播放。
- **`seek(Duration position)`**: 跳转到指定播放位置。
- **`destroy()`**: 销毁播放器实例，释放资源。

## **3. AliPlayerWidgetData (Data)**

`AliPlayerWidgetData` 是播放器组件的数据模型（Data），包含视频地址、封面图、标题等信息。

### **3.1 属性**

- **`videoSource`**: 播放器视频源（必填）。
- **`coverUrl`**: 封面图地址（可选）。
- **`videoTitle`**: 视频标题（可选）。
- **`thumbnailUrl`**: 缩略图地址（可选）。
- **`sceneType`**: 播放场景类型，默认为点播（`SceneType.vod`）。
- **`onPlayerConfig`**: 播放器自定义配置回调（可选）。在 `prepare()` 前调用，支持异步操作。适用于 AliPlayerWidget 未直接透出的播放器接口（如 `setConfig`、`setOption` 等），可在回调中自行调用实现。

## **4. 全局配置项（可选）**

除了上述三大核心组件外，AliPlayerWidget 还提供了一个可选的全局配置类 `AliPlayerWidgetGlobalSetting`，用于配置播放器的全局行为，如缓存设置、存储路径等。

### **4.1 主要功能**

- **全局配置初始化**: 通过 [setupConfig] 方法初始化全局配置
- **自定义全局配置回调**: 通过 [setOnGlobalInit] 方法注册回调，在全局初始化完成后调用。适用于 AliPlayerWidget 未直接透出的全局接口（如 `setOption` 等），可在回调中自行调用实现。
- **存储路径设置**: 通过 [setStoragePaths] 方法设置缓存和文件存储路径
- **缓存管理**: 通过 [clearCaches] 方法清除所有缓存

### **4.2 使用说明**

组件已内置推荐的最优全局配置，通常无需额外设置。如需自定义，可参考 `example/lib/main.dart`，通过 [AliPlayerWidgetGlobalSetting] 相关接口进行配置。

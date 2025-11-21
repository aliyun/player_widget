# **AliPlayerWidget 核心组件**

AliPlayerWidget 采用类似 MVC 的分层设计，将视图（View）、控制逻辑（Controller）和数据模型（Data）拆分为三个核心组件，它们协同工作以实现完整的视频播放功能。

## **1. AliPlayerWidget (View)**

`AliPlayerWidget` 是核心的播放器组件（View），用于嵌入到 Flutter 应用中并播放视频。

### **构造函数**

```dart
AliPlayerWidget(
  AliPlayerWidgetController controller, {
  Key? key,
  List<Widget> overlays = const [],
});
```

- **`controller`**: 播放器控制器，用于管理播放逻辑。
- **`overlays`**: 可选的浮层组件列表，用于在播放器组件上叠加自定义 UI。

### **示例**

```dart
AliPlayerWidget(
  _controller,
  overlays: [
    Positioned(
      right: 16,
      bottom: 80,
      child: Column(
        children: [
          IconButton(icon: Icon(Icons.favorite), onPressed: () {}),
          IconButton(icon: Icon(Icons.share), onPressed: () {}),
        ],
      ),
    ),
  ],
);
```

## **2. AliPlayerWidgetController (Controller)**

`AliPlayerWidgetController` 是播放器组件的控制器（Controller），用于管理播放器组件的初始化、播放、销毁等逻辑。

### **主要方法**

- **`configure(AliPlayerWidgetData data)`**: 配置数据源。
- **`play()`**: 开始播放视频。
- **`pause()`**: 暂停播放。
- **`seek(Duration position)`**: 跳转到指定播放位置。
- **`destroy()`**: 销毁播放器实例，释放资源。

## **3. AliPlayerWidgetData (Data)**

`AliPlayerWidgetData` 是播放器组件的数据模型（Data），包含视频地址、封面图、标题等信息。

### **属性**

- **`videoSource`**: 播放器视频源（必填）。
- **`coverUrl`**: 封面图地址（可选）。
- **`videoTitle`**: 视频标题（可选）。
- **`thumbnailUrl`**: 缩略图地址（可选）。
- **`sceneType`**: 播放场景类型，默认为点播（`SceneType.vod`）。

## **4. 全局配置项（可选）**

除了上述三大核心组件外，AliPlayerWidget 还提供了一个可选的全局配置类 `AliPlayerWidgetGlobalSetting`，用于配置播放器的全局行为，如缓存设置、存储路径等。该配置项不属于核心组件，但在使用 AliPlayerWidget 时通常建议进行全局配置。

### **主要功能**

- **全局配置初始化**: 通过 [setupConfig] 方法初始化全局配置
- **存储路径设置**: 通过 [setStoragePaths] 方法设置缓存和文件存储路径
- **缓存管理**: 通过 [clearCaches] 方法清除所有缓存

### **使用示例**

在应用启动时初始化全局设置：

```dart
/// 初始化 aliplayer_widget 全局配置
Future<void> initializeGlobalSettings() async {
  // 初始化全局配置
  await AliPlayerWidgetGlobalSetting.setupConfig();

  String? cachePath;
  String? filesPath;

  if (Platform.isAndroid) {
    // Android: 尝试使用外部存储
    final externalCacheDirs = await getExternalCacheDirectories();
    cachePath = externalCacheDirs?.isNotEmpty == true
        ? externalCacheDirs?.first.path
        : null;

    final externalStorageDir = await getExternalStorageDirectory();
    filesPath = externalStorageDir?.path;
  } else {
    // iOS / 其他平台：使用标准应用沙盒目录
    final cacheDir = await getApplicationCacheDirectory();
    final docsDir = await getApplicationDocumentsDirectory();
    cachePath = cacheDir.path;
    filesPath = docsDir.path;
  }

  // 设置全局存储路径
  AliPlayerWidgetGlobalSetting.setStoragePaths(
    cachePath: cachePath,
    filesPath: filesPath,
  );
}
```
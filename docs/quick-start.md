# **AliPlayerWidget 快速开始指南**

只需几步，您就可以轻松实现视频播放功能！**AliPlayerWidget** 提供了极简的 API 设计，帮助您以低代码的方式快速集成视频播放功能。

> **注意**：在开始之前，请确保您已经按照[集成指引](./integration-guide.md)完成环境配置和依赖添加。

## **1. 接入流程概览**

![Integration](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/Integration.png)

## **2. 快速开始示例**

以下是一个完整的示例，展示如何在页面中嵌入视频播放器。只需几行代码即可完成视频播放功能。

```dart
import 'package:flutter/material.dart';
import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

void main() {
  // === 0. 初始化播放器组件全局配置 ===
  // 可选调用：组件已内置推荐的最优全局配置，通常无需额外设置；如需自定义，可参考 example/lib/main.dart
  // 调用方式：通过 [AliPlayerWidgetGlobalSetting] 相关接口进行全局配置
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: VideoPlayerPage());
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late AliPlayerWidgetController _controller;

  @override
  void initState() {
    super.initState();

    // === 1. 创建控制器并配置数据 ===

    // 创建播放器视频源
    final videoSource = VideoSourceFactory.createVidAuthSource(
      vid: "<your-video-id>",
      playAuth: "<your-play-auth>",
    );

    // 配置播放器组件数据
    final data = AliPlayerWidgetData(
      videoSource: videoSource,
      videoTitle: "<your-video-title>",
    );

    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);
    _controller.configure(data);
  }

  @override
  void dispose() {
    // === 3. 页面销毁时必须释放资源 ===
    _controller.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AliPlayerWidget Demo')),
      // === 2. 嵌入播放器 UI 组件 ===
      body: AliPlayerWidget(_controller),
    );
  }
}
```

## **3. 关键步骤解析**

1. **创建控制器并配置数据**
   - 在 `initState` 方法中创建 `AliPlayerWidgetController` 实例。
   - 通过 `VideoSourceFactory` 构建 `videoSource` 视频源。
   - 使用 `AliPlayerWidgetData` 实例，封装播放数据（视频源、标题等）。
2. **绑定数据并渲染 UI**
   - 调用 `_controller.configure(data)` 完成数据绑定。
   - 在 `build` 方法中使用 `AliPlayerWidget(_controller)` 嵌入播放器 UI 组件。
3. **释放资源**：
   - 在 `dispose` 方法中调用 `_controller.destroy()`，避免内存泄漏。

## **4. 更多场景支持**

上述示例展示了点播场景的基本用法。如需了解更复杂的场景（如直播、列表播放等），请参考 `aliplayer_widget_example` 示例工程，其中包含了详细的代码和使用说明。
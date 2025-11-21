# **AliPlayerWidget 快速开始指南**

只需几步，您就可以轻松实现视频播放功能！**AliPlayerWidget** 提供了极简的 API 设计，帮助您以低代码的方式快速集成视频播放功能。

> **注意**：在开始之前，请确保您已经按照[集成指引](./integration-guide.md)完成环境配置和依赖添加。

## **1. 实现视频播放**

![Integration](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/Integration.png)

以下是一个完整的示例，展示如何在页面中嵌入视频播放器。只需几行代码即可完成视频播放功能。

```dart
import 'package:flutter/material.dart';
import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoPlayerPage(),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late AliPlayerWidgetController _controller;

  @override
  void initState() {
    super.initState();

    // 1. 设置播放器视频源
    final videoSource = VideoSourceFactory.createUrlSource(
      "https://example.com/video.mp4", // 替换为实际视频地址
    );
    // 2. 配置播放器组件数据
    final data = AliPlayerWidgetData(
      videoSource: videoSource,
      coverUrl: "https://example.com/cover.jpg", // 替换为实际封面图地址
      videoTitle: "Sample Video",
    );

    // 3. 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);
    _controller.configure(data);
  }

  @override
  void dispose() {
    // 4. 销毁播放器组件控制器，释放资源
    _controller.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AliPlayerWidget(
          _controller,
        ),
      ),
    );
  }
}
```

## **2. 关键点解析**

1. **初始化 `AliPlayerWidgetController`**：
   - 在 `initState` 方法中创建 `_controller` 实例。
2. **调用 `configure` 接口**：
   - 使用 `AliPlayerWidgetData` 配置视频地址、封面图、标题等信息。
   - 调用 `_controller.configure(data)` 将数据传递给播放器组件。
3. **释放资源**：
   - 在 `dispose` 方法中调用 `_controller.destroy()`，避免内存泄漏。

## **3. 更多场景支持**

上述示例展示了点播场景的基本用法。如需了解更复杂的场景（如直播、列表播放等），请参考 `aliplayer_widget_example` 示例工程，其中包含了详细的代码和使用说明。
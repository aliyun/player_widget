# **AliPlayerWidget Quick Start Guide**

In just a few steps, you can easily implement video playback functionality! **AliPlayerWidget** offers a minimalist API design to help you rapidly integrate video playback features with minimal coding.

> **Note**: Before getting started, please ensure you have completed environment setup and dependency installation according to the [Integration Guide](./integration-guide-en.md).

## **1. Implement Video Playback**

![Integration_en](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/Integration_en.png)

Below is a complete example demonstrating how to embed a video player into a page. With just a few lines of code, you can achieve video playback functionality.

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

    // 1. Configure the video source for the player
    final videoSource = VideoSourceFactory.createUrlSource(
      "https://example.com/video.mp4", // Substitute with the actual video URL
    );
    // 2. Configure the data for the player component
    final data = AliPlayerWidgetData(
      videoSource: videoSource,
      coverUrl: "https://example.com/cover.jpg", // Substitute with the actual cover URL
      videoTitle: "Sample Video",
    );

    // 3. Initialize the controller for the player component
    _controller = AliPlayerWidgetController(context);
    _controller.configure(data);
  }

  @override
  void dispose() {
    // 4. Destroy the player component controller and release resources
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

**Key Points Analysis**
1. **Initialize `AliPlayerWidgetController`**:
   - Create `_controller` instance within the `initState` method.
2. **Call `configure` Interface**:
   - Use `AliPlayerWidgetData` to configure video URL, cover image, title, and other information.
   - Call `_controller.configure(data)` to pass data to the player component.
3. **Release Resources**:
   - Call `_controller.destroy()` within the `dispose` method to avoid memory leaks.

## **2. Support for More Scenarios**

The above example demonstrates basic usage for VOD scenarios. For more complex scenarios (e.g., live streaming, playlist playback), refer to the `aliplayer_widget_example` sample project, which includes detailed code and usage instructions.
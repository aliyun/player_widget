# **AliPlayerWidget Quick Start Guide**

In just a few steps, you can easily implement video playback functionality! **AliPlayerWidget** offers a minimalist API design to help you rapidly integrate video playback features with minimal coding.

> **Note**: Before getting started, please ensure you have completed environment setup and dependency installation according to the [Integration Guide](./integration-guide-en.md).

## **1. Integration Flow Overview**

![Integration_en](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/Integration_en.png)

## **2. Quick Start Example**

Below is a complete example demonstrating how to embed a video player into a page. With just a few lines of code, you can achieve video playback functionality.

```dart
import 'package:flutter/material.dart';
import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

void main() {
  // === 0. Initialize global configuration for the player component ===
  // Optional: The component already includes recommended optimal global settings by default; usually no extra setup is needed.
  // If customization is required, refer to example/lib/main.dart
  // Usage: Configure globally via [AliPlayerWidgetGlobalSetting] related APIs
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

    // === 1. Create controller and configure data ===

    // Create player video source
    final videoSource = VideoSourceFactory.createVidAuthSource(
      vid: "<your-video-id>",
      playAuth: "<your-play-auth>",
    );

    // Configure player component data
    final data = AliPlayerWidgetData(
      videoSource: videoSource,
      videoTitle: "<your-video-title>",
    );

    // Initialize player component controller
    _controller = AliPlayerWidgetController(context);
    _controller.configure(data);
  }

  @override
  void dispose() {
    // === 3. Resources must be released when the page is destroyed ===
    _controller.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AliPlayerWidget Demo')),
      // === 2. Embed the player UI component ===
      body: AliPlayerWidget(_controller),
    );
  }
}
```

## **3. Key Steps Analysis**

1. **Create Controller and Configure Data**
   - Create `AliPlayerWidgetController` instance within the `initState` method.
   - Build `videoSource` video source via `VideoSourceFactory`.
   - Use `AliPlayerWidgetData` instance to encapsulate playback data (video source, title, etc.).
2. **Bind Data and Render UI**
   - Call `_controller.configure(data)` to complete data binding.
   - Use `AliPlayerWidget(_controller)` in the `build` method to embed the player UI component.
3. **Release Resources**:
   - Call `_controller.destroy()` in the `dispose` method to avoid memory leaks.

## **4. Support for More Scenarios**

The above example demonstrates basic usage for VOD scenarios. For more complex scenarios (e.g., live streaming, playlist playback), please refer to the `aliplayer_widget_example` sample project, which includes detailed code and usage instructions.

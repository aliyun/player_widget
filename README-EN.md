Language: [Simplified Chinese](README.md) | English

![alibaba_cloud_logo](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/AlibabaCloud.svg)

# **aliplayer_widget**

[![pub package](https://img.shields.io/pub/v/aliplayer_widget.svg)](https://pub.dev/packages/aliplayer_widget) [![platform](https://img.shields.io/badge/-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/) [![language](https://img.shields.io/badge/-Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev/) [![website](https://img.shields.io/badge/Product-VOD-FF6A00)](https://www.aliyun.com/product/vod)

## **1. Overview**
**AliPlayerWidget** is a high-performance video playback component specifically designed for Flutter applications, built on top of the AliCloud Player SDK `flutter_aliplayer`. It supports multi-scenario adaptation such as Video-on-Demand (VOD), live streaming, playlist playback, and short drama scenes. Additionally, it offers a rich set of features and highly flexible UI customization capabilities, meeting video playback needs across various fields like education, entertainment, e-commerce, and short drama applications.

With a minimalist API design, AliPlayerWidget achieves low-code integration, allowing developers to quickly implement complex video playback functionalities with just a few lines of code, significantly reducing development costs. Whether it's basic playback control or complex interactive scenarios (such as gesture adjustments and overlay stacking), AliPlayerWidget can handle them effortlessly, helping developers build smooth and efficient user experiences.

---

## **2. Features**
### **2.1 Core Functionalities**
- **Multi-scenario Adaptation**: Supports VOD, live streaming, playlist playback, and full-screen modes.
- **Rich Feature Set**:
  - **Basic Functions**: Provides core functionalities such as playback control, settings panel, cover image display, and quality switching to meet standard video playback requirements.
  - **Gesture Control**: Supports intuitive brightness, volume, and playback progress adjustments via gestures, enhancing user experience.
  - **Support for Multiple Playback Sources**: Compatible with various video source types, including direct URL playback, VID+STS token playback, and VID+Auth authentication playback, meeting the playback requirements of different scenarios.
- **Flexible UI Customization**:
  - **Slot System**: Provides a powerful slot system that supports customizing various parts of the player interface, including top bar, bottom bar, play control, cover image, subtitles, etc., allowing developers to flexibly combine and create personalized interfaces. Through predefined slot positions, developers can easily replace default UI components or add custom elements.
  - **Overlay Support**: Allows custom overlay components with strong extensibility, enabling developers to implement complex features like advertisements and bullet chats.
  - **Modular Design**: Includes reusable UI components such as top bars, bottom bars, and settings panels, making it easy for developers to customize according to their needs.
  - **Full-Screen Adaptation**: Automatically adapts to landscape and portrait orientations, ensuring optimal display across different devices.
- **Event and State Management**:
  - **Real-Time Status Monitoring**: Offers real-time updates on playback status, video dimensions, buffering progress, etc., facilitating dynamic interactions.
  - **Event Callback Mechanism**: Provides comprehensive player event listeners, including play start, pause, completion, and other state management tools, making it convenient for developers to handle various playback scenarios.
  - **Logging and Debugging Support**: Equipped with a detailed logging system to aid in troubleshooting and performance optimization.

### **2.2 Core Advantages**
- **Ease of Use**: Complex video playback functions can be implemented through simple API calls, allowing quick integration into Flutter projects.
- **Flexibility and Extensibility**:
  - Modular design supporting various customization options, enabling developers to tailor the player based on specific needs.
  - Automatic adaptation to different screen sizes and resolutions ensures consistent user experience.
- **High Performance and Stability**:
  - Built on the AliCloud Player SDK, providing low-latency and highly stable video playback.
  - Optimized architecture design featuring lightweight components, asynchronous loading, and an event-driven model to ensure efficient operation and smooth user experience.
- **Cross-Platform Support**: Fully leverages Flutter's cross-platform capabilities, supporting both Android and iOS platforms, allowing single-codebase development for dual-platform execution.

Detailed documentation can be found in the docs directory: [Complete Documentation Directory](./docs/README-EN.md)

---

## **3. Integration Guide**

For detailed information about prerequisites, please refer to the integration guide in the docs directory: [Integration Guide](./docs/integration-guide-en.md)

---

## **4. Quick Start**

In just a few steps, you can easily implement video playback functionality! **AliPlayerWidget** offers a minimalist API design to help you rapidly integrate video playback features with minimal coding.

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

**Support for More Scenarios**
The above example demonstrates basic usage for VOD scenarios. For more complex scenarios (e.g., live streaming, playlist playback), refer to the `aliplayer_widget_example` sample project, which includes detailed code and usage instructions.

For a more detailed quick start guide, please refer to the quick start documentation in the docs directory: [Quick Start Guide](./docs/quick-start-en.md)

---

## **5. Core Components**

`AliPlayerWidget` adopts an MVC-inspired layered design, dividing the player's responsibilities into three core components:

1. **AliPlayerWidget (View)**: The core player component used to embed and play videos within Flutter applications.
2. **AliPlayerWidgetController (Controller)**: The core controller of the player component, managing initialization, playback, destruction, and other logic.
3. **AliPlayerWidgetData (Data)**: The data model required by the player component, containing video URL, cover image, title, and other information.

For detailed information about each core component, please refer to the core components documentation in the docs directory: [Core Components Documentation](./docs/core-components-en.md)

---

## **6. Custom Features**
### **6.1 Video Source Support**

The player provides flexible video source configuration methods, supporting multiple video source types. For detailed information, please refer to the video source support documentation in the docs directory: [Video Source Support Documentation](./docs/video-source-support-en.md)

### **6.2 Overlay Components**

Using the `overlays` parameter, you can easily overlay custom UI components onto the player. For detailed information, please refer to the slot system documentation in the docs directory: [Slot System Documentation](./docs/slot-system-en.md)

### **6.3 API Reference**

`AliPlayerWidget` provides a series of external interfaces that allow developers to directly control player behavior. For detailed information, please refer to the API reference documentation in the docs directory: [API Reference Documentation](./docs/api-reference-en.md)

---

## **7. Example Project and Demo Package**
To help developers quickly get started and deeply understand how to integrate and use **AliPlayerWidget** in real-world projects, we provide two resources: the **example project** and a **demo package** built based on this project. Below, we will introduce the purpose and access methods of each.

### **1. Example Project**
`aliplayer_widget_example` is a complete example project designed to help developers quickly understand and integrate the core functionalities of **AliPlayerWidget**.

You can access the full documentation of the example project through the following links:
- **Chinese Documentation**: [aliplayer_widget_example README](./example/README.md)
- **English Documentation**: [aliplayer_widget_example README-EN](./example/README-EN.md)

Through the example project, you can intuitively learn the following:

- How to embed a video player component.
- How to configure playback functionality for different scenarios (e.g., VOD, live streaming, playlist playback).
- How to leverage custom options to achieve personalized user experiences.

### **2. Demo Package**
To help developers quickly experience the functionalities of **AliPlayerWidget**, we have built a demo package based on the `aliplayer_widget_example` project. This demo package can be directly installed and run on a device without additional development environment setup.

#### **Access Method**
Scan the QR code below with your mobile phone to quickly download and install the demo package:

![Demo QR Code](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/demo-qr-code.png)  

> **Note**: The QR code links to the latest version of the demo package. Ensure that your device allows the installation of third-party applications.

---

## **8. Open Source and Source Code Access**
**aliplayer_widget** has been published to the following Pub sources. Developers are recommended to integrate it via the package management tool:

- **Pub Official Source**: [pub.dev](https://pub.dev/packages/aliplayer_widget)
- **Domestic Mirror Source**: [pub.flutter-io.cn](https://pub.flutter-io.cn/packages/aliplayer_widget)

If you need to customize the component, you can use the source code dependency method to directly obtain and modify the source code. The complete source code can be accessed through the following methods:
- **GitHub Repository**: [aliplayer_widget](https://github.com/aliyun/player_widget)
  

If GitHub is inaccessible, you can download the source code package directly via the link below:

- **Source Code Package Download**: [aliplayer_widget.zip](https://alivc-demo-cms.alicdn.com/versionProduct/sourceCode/aliplayer_widget/aliplayer_widget.zip)

The open-source content includes:
- **Core components**: Complete implementation of `AliPlayerWidget` and `AliPlayerWidgetController`.
- **Example project**: `aliplayer_widget_example` provides code examples for scenarios such as video-on-demand, live streaming, and playlist playback, helping developers quickly integrate and get started.
- **Documentation and comments**: The source code includes detailed comments and development guidelines for easier secondary development and customization.

---

For more common issues and resolution suggestions related to the use of Alibaba Cloud Player SDK, please refer to [FAQ about ApsaraVideo Player](https://www.alibabacloud.com/help/en/vod/support/faq-about-apsaravideo-player/).
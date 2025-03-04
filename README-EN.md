Language: [Simplified Chinese](README.md) | English

# **aliplayer_widget**

[![pub package](https://img.shields.io/pub/v/aliplayer_widget.svg)](https://pub.dev/packages/aliplayer_widget)

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
- **Flexible UI Customization**:
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
- **Cross-Platform Support**: Fully leverages Flutter’s cross-platform capabilities, supporting both Android and iOS platforms, allowing single-codebase development for dual-platform execution.

---

## **3. Prerequisites**
### **3.1 Development Environment Setup**
Before using **AliPlayerWidget**, ensure your development environment meets the following requirements:
- **Flutter SDK**:
  - Version must be no less than `2.10.0`, with version `3.22.2` recommended.
  - Run `flutter doctor` to check and resolve any issues.
- **JDK 11**:
  > JDK 11 setup method: Preferences -> Build, Execution, Deployment -> Build Tools -> Gradle -> Gradle JDK -> Select 11 (Upgrade Android Studio if 11 is unavailable).
- **Android Development Environment**:
  - Install the latest version of Android Studio.
  - Configure Android SDK with a minimum supported API level of 21 (Android 5.0).
  - Gradle version should be no less than `7.0`.
- **iOS Development Environment**:
  - Install the latest version of Xcode.
  - Configure CocoaPods, with version `1.13.0` recommended.
  - Minimum supported iOS version is `10.0`.

### **3.2 Permission Configuration**
- **Permission Settings**:
  - Enable network permissions in both Android and iOS to allow the player to load online video resources.
- **License Configuration**:
  - You must obtain the License Authorization Certificate and License Key for the ApsaraVideo Player SDK. Detailed steps for obtaining these can be found at [Apply for License](https://www.alibabacloud.com/help/en/apsara-video-sdk/user-guide/license-authorization-and-management#13133fa053843).
  - **Note**: If the License is not correctly configured, the player will not function properly and may throw authorization exceptions.
  For more initialization configurations, refer to the `aliplayer_widget_example` sample project.

---

## **4. Quick Start**
In just a few steps, you can easily implement video playback functionality! **AliPlayerWidget** offers a minimalist API design to help you rapidly integrate video playback features with minimal coding.
### **4.1. Add Dependency**
You can integrate `AliPlayerWidget` into your Flutter project using one of the following two methods:

* **Method 1: Manually Add Dependency**

In your `pubspec.yaml` file, add the following dependency:

```yaml
dependencies:
  aliplayer_widget: ^x.y.z
```
> **Note**: `x.y.z` represents the version number of `aliplayer_widget`. You can check the latest stable version on the [Pub.dev official page](https://pub.dev/packages/aliplayer_widget) and replace it with the actual value (e.g., `^7.0.0`).

* **Method 2: Use Command-Line Tool**

If you prefer using the command line, you can run the following command to add the dependency:

```shell
flutter pub add aliplayer_widget
```
This command will automatically update your `pubspec.yaml` file.

Regardless of the method you choose, after completing the dependency addition, run the following command in your terminal to install the dependencies:
```shell
flutter pub get
```

After completing the above steps, `AliPlayerWidget` will be successfully integrated into your project, and you can start using it!

### **4.2 Implement Video Playback**
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
    // Initialize the player component controller
    _controller = AliPlayerWidgetController(context);
    // Configure the player component data
    final data = AliPlayerWidgetData(
      videoUrl: "https://example.com/video.mp4", // Replace with actual video URL
      coverUrl: "https://example.com/cover.jpg", // Replace with actual cover image URL
      videoTitle: "Sample Video",
    );
    _controller.configure(data); // Set autoplay
  }

  @override
  void dispose() {
    // Destroy the player instance to release resources
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

---

## **5. Core Components**
### **5.1 AliPlayerWidget**
`AliPlayerWidget` is the core player component used to embed and play videos within Flutter applications.
**Constructor**
```dart
AliPlayerWidget(
  AliPlayerWidgetController controller, {
  Key? key,
  List<Widget> overlays = const [],
});
```
- **`controller`**: The player controller used to manage playback logic.
- **`overlays`**: Optional list of overlay components to stack custom UI elements over the player component.

**Example**

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

### **5.2 AliPlayerWidgetController**
`AliPlayerWidgetController` is the core controller of the player component, managing initialization, playback, destruction, and other logic.
**Primary Methods**
- **`configure(AliPlayerWidgetData data)`**: Configures the data source.
- **`play()`**: Starts video playback.
- **`pause()`**: Pauses playback.
- **`seek(Duration position)`**: Jumps to the specified playback position.
- **`setUrl(String url)`**: Sets the video playback URL.
- **`destroy()`**: Destroys the player instance to release resources.

**Example**

```dart
// Initialize the player component controller
final controller = AliPlayerWidgetController(context);
// Set player component data
AliPlayerWidgetData data = AliPlayerWidgetData(
  videoUrl: "https://example.com/video.mp4",
);
controller.configure(data);
// Destroy the player
controller.destroy();
```

### **5.3 AliPlayerWidgetData**
`AliPlayerWidgetData` is the data model required by the player component, containing video URL, cover image, title, and other information.
**Attributes**
- **`videoUrl`**: Video playback URL (mandatory).
- **`coverUrl`**: Cover image URL (optional).
- **`videoTitle`**: Video title (optional).
- **`thumbnailUrl`**: Thumbnail URL (optional).
- **`sceneType`**: Playback scenario type, defaulting to VOD (`SceneType.vod`).

**Example**

```dart
AliPlayerWidgetData(
  videoUrl: "https://example.com/video.mp4",
  coverUrl: "https://example.com/cover.jpg",
  videoTitle: "Sample Video",
  sceneType: SceneType.vod,
);
```

---

## **6. Custom Features**
### **6.1 Overlay Components**
Using the `overlays` parameter, you can easily overlay custom UI components onto the player. For example, add like, comment, and share buttons.
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
          IconButton(icon: Icon(Icons.comment), onPressed: () {}),
          IconButton(icon: Icon(Icons.share), onPressed: () {}),
        ],
      ),
    ),
  ],
);
```

### **6.2 Common Interfaces**
`AliPlayerWidget` provides a series of external interfaces that allow developers to directly control player behavior. These interfaces are exposed through `AliPlayerWidgetController`, supporting playback control, status queries, data updates, and more.
Here are some commonly used external interfaces and their use cases:

| **Category**                       | **Interface Name**       | **Function Description**                                     |
| ---------------------------------- | ------------------------ | ------------------------------------------------------------ |
| **Configuration & Initialization** | `configure`              | Configures the player data source and initializes the player. |
|                                    | `prepare`                | Manually triggers the preparation process of the player.     |
| **Playback Control**               | `play`                   | Starts video playback.                                       |
|                                    | `pause`                  | Pauses playback.                                             |
|                                    | `stop`                   | Stops playback and resets the player.                        |
|                                    | `seek`                   | Jumps to the specified playback position.                    |
|                                    | `togglePlayState`        | Toggles between play and pause states.                       |
|                                    | `replay`                 | Replays the video (typically used after playback completion). |
| **Playback Property Settings**     | `setSpeed`               | Sets playback speed.                                         |
|                                    | `setVolume`              | Sets volume.                                                 |
|                                    | `setVolumeWithDelta`     | Adjusts volume incrementally.                                |
|                                    | `setBrightness`          | Sets screen brightness.                                      |
|                                    | `setBrightnessWithDelta` | Adjusts screen brightness incrementally.                     |
|                                    | `setLoop`                | Sets whether to loop playback.                               |
|                                    | `setMute`                | Sets whether to mute audio.                                  |
|                                    | `setMirrorMode`          | Sets mirror mode (e.g., horizontal or vertical mirroring).   |
|                                    | `setRotateMode`          | Sets rotation angle (e.g., 90°, 180°, etc.).                 |
|                                    | `setScaleMode`           | Sets rendering fill mode (e.g., stretch, crop, etc.).        |
| **Quality Switching**              | `selectTrack`            | Switches playback quality.                                   |
| **Thumbnail Related**              | `requestThumbnailBitmap` | Requests thumbnails at specified time points.                |
| **Other Functions**                | `clearCaches`            | Clears player caches (including video and image caches).     |
|                                    | `getWidgetVersion`       | Retrieves the current Flutter Widget version number.         |

### **6.3 Event Notifications**
`AliPlayerWidgetController` provides a series of `ValueNotifier`s for real-time notifications of player state changes and user operations. Below are some commonly used `notifier`s and their purposes:

#### **Overview of Common Notifiers**
**1. Playback State Management**

| **Notifier**        | **Function Description**                                     |
| ------------------- | ------------------------------------------------------------ |
| `playStateNotifier` | Monitors changes in playback state (e.g., playing, paused, stopped). |
| `playErrorNotifier` | Listens for errors during playback, providing error codes and descriptions. |

**2. Playback Progress Management**

| **Notifier**               | **Function Description**                                     |
| -------------------------- | ------------------------------------------------------------ |
| `currentPositionNotifier`  | Updates current playback progress in real-time (unit: milliseconds). |
| `bufferedPositionNotifier` | Tracks video buffering progress, helping users understand cached content ranges. |
| `totalDurationNotifier`    | Provides total video duration information for calculating playback percentage or displaying total duration. |

**3. Volume and Brightness Control**

| **Notifier**         | **Function Description**                                     |
| -------------------- | ------------------------------------------------------------ |
| `volumeNotifier`     | Monitors volume changes, supporting dynamic adjustment of volume levels (range typically 0.0 to 1.0). |
| `brightnessNotifier` | Monitors screen brightness changes, allowing users to adjust brightness based on ambient light (range typically 0.0 to 1.0). |

**4. Quality and Thumbnails**

| **Notifier**               | **Function Description**                                     |
| -------------------------- | ------------------------------------------------------------ |
| `currentTrackInfoNotifier` | Tracks changes in current video quality information (e.g., SD, HD, UHD) and provides details after switching. |
| `thumbnailNotifier`        | Monitors thumbnail loading status, ensuring real-time preview when dragging the progress bar. |

#### **Usage Method**
Use `ValueListenableBuilder` to listen for changes in `notifier`s, enabling real-time UI updates or logic execution.
**Example Code**
```dart
// Listen for playback errors
ValueListenableBuilder<Map<int?, String?>?>(
  valueListenable: _controller.playErrorNotifier,
  builder: (context, error, _) {
    if (error != null) {
      final errorCode = error.keys.firstOrNull;
      final errorMsg = error.values.firstOrNull;
      return Text("Playback Error: [$errorCode] $errorMsg");
    }
    return SizedBox.shrink();
  },
);
```

---

## **7. Notes**
1. **Resource Release**: Ensure calling `AliPlayerWidgetController.destroy()` when destroying pages to release player resources.
2. **Network Permissions**: Ensure necessary network permissions are configured in the app to load online videos.
3. **Thumbnail Support**: If using thumbnail functionality, ensure valid thumbnail URLs are provided.
4. **Debugging and Optimization**: Enable logging during development to facilitate troubleshooting. Also, optimize overlay component performance to avoid affecting playback smoothness.

----

## **8. Example Project and Demo Package**
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

## **9. Open Source and Source Code Access**
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
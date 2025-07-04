Language: 中文简体 | [English](README-EN.md)

![alibaba_cloud_logo](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/AlibabaCloud.svg)

# **aliplayer_widget**

[![pub package](https://img.shields.io/pub/v/aliplayer_widget.svg)](https://pub.dev/packages/aliplayer_widget) [![platform](https://img.shields.io/badge/-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/) [![language](https://img.shields.io/badge/-Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev/) [![website](https://img.shields.io/badge/Product-VOD-FF6A00)](https://www.aliyun.com/product/vod)

## **一、概述**

**AliPlayerWidget** 是一款专为 Flutter 应用程序打造的高性能视频播放组件，基于阿里云播放器 SDK `flutter_aliplayer` 构建。它不仅支持点播（VOD）、直播、列表播放以及短剧场景等多场景适配，还提供了丰富的功能集和高度灵活的 UI 定制能力，能够满足教育、娱乐、电商以及短剧应用等多种领域的视频播放需求。

通过极简的 API 设计，AliPlayerWidget 实现了低代码集成，开发者只需几行代码即可快速实现复杂的视频播放功能，显著降低开发成本。无论是基础的播放控制，还是复杂的交互场景（如手势调节、浮层叠加），AliPlayerWidget 都能轻松应对，帮助开发者构建流畅且高效的用户体验。

---

## **二、功能特性**

### **1. 核心功能**

- **多场景适配**：支持点播、直播、列表播放及全屏播放等多种场景。
- **丰富的功能集：**
  - **基础功能**：提供播放控制、设置面板、封面图显示、清晰度切换等核心功能，满足常规视频播放需求。
  - **手势控制**：支持亮度、音量和播放进度的手势调节，操作直观便捷，提升用户体验。
  - **多种播放源支持**：兼容多种视频源类型，包括直接 URL 播放、VID+STS 令牌播放，以及 VID+Auth 认证播放，满足不同场景下的播放需求。
  
- **灵活的 UI 定制：**
  - **浮层支持**：支持自定义浮层组件，扩展性强，允许开发者实现如广告、弹幕等复杂功能。
  - **模块化设计**：内置顶部栏、底部栏、设置面板等可复用的 UI 组件，方便开发者按需定制。
  - **全屏适配**：自动适配横竖屏切换，确保在不同设备上的最佳显示效果。
- **事件与状态管理**
  - **实时状态监控**：提供播放状态、视频尺寸、缓冲进度等实时数据更新，便于开发者实现动态交互。
  - **事件回调机制**：提供全面的播放器事件监听，包括播放开始、暂停、完成等状态管理，方便开发者处理各种播放场景。
  - **日志与调试支持**：内置详细的日志系统，便于问题排查和性能优化。


### **2. 核心优势**

- **简单易用**：通过简单的 API 调用即可实现复杂的视频播放功能，快速集成到 Flutter 项目中。
- **灵活可扩展：**
  - 模块化设计，支持多种自定义选项，方便开发者根据需求进行定制。
  - 自动适配不同屏幕尺寸和分辨率，确保一致的用户体验。

- **高性能与稳定性：**
  - 基于阿里云播放器 SDK，提供低延迟、高稳定性的视频播放体验。
  - 优化的架构设计，通过轻量化组件、异步加载和事件驱动模型，确保高效运行与流畅用户体验。

- **跨平台支持**：充分利用 Flutter 的跨平台特性，支持 Android 和 iOS 平台，一次开发即可实现双端运行。

---

## **三、前提条件**

### **1. 开发环境配置**

在使用 **AliPlayerWidget** 之前，请确保您的开发环境满足以下要求：

- **Flutter SDK**

  - 版本要求不低于 `2.10.0`，推荐版本为 `3.22.2`。
  - 运行 `flutter doctor` 检查并解决所有问题。

- **JDK 11**

  > JDK 11设置方法：Preferences -> Build, Execution, Deployment -> Build Tools -> Gradle -> Gradle JDK -> 选择 11（如果没有11，请升级你的Android Studio版本）

- **Android 开发环境**

  - 安装最新版本的 Android Studio。
  - 配置 Android SDK，最低支持 API 级别为 21（Android 5.0）。
  - Gradle 版本不低于 `7.0`。

- **iOS 开发环境**

  - 安装最新版本的 Xcode。
  - 配置 CocoaPods，推荐版本为 `1.13.0`。
  - 最低支持 iOS 版本为 `10.0`。

### **2. 权限配置**

- **权限配置**
  - 在 Android 和 iOS 中启用网络权限，以便播放器能够加载在线视频资源。
- **License 配置**
  - 您已获取音视频终端 SDK 的播放器的 License 授权证书和 License Key，获取的详细步骤请参见[申请License](https://help.aliyun.com/zh/apsara-video-sdk/user-guide/license-authorization-and-management#13133fa053843)。
  - **注意**：如未正确配置 License，播放器将无法正常工作，并可能抛出授权异常。

更多初始化配置，请参考 `aliplayer_widget_example` 示例工程。

---

## **四、快速开始**

只需几步，您就可以轻松实现视频播放功能！**AliPlayerWidget** 提供了极简的 API 设计，帮助您以低代码的方式快速集成视频播放功能。

### **1. 添加依赖**

在您的 `pubspec.yaml` 文件中，添加以下依赖项：
```yaml
dependencies:
  aliplayer_widget: <latest_version>
  flutter_aliplayer: <latest_version>
```

### **2. 实现视频播放**

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
    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);
    // 配置播放器组件数据
    final data = AliPlayerWidgetData.fromUrl(
      videoUrl: "https://example.com/video.mp4", // 替换为实际视频地址
      coverUrl: "https://example.com/cover.jpg", // 替换为实际封面图地址
      videoTitle: "Sample Video",
    );
    _controller.configure(data); // 设置自动播放
  }

  @override
  void dispose() {
    // 销毁播放器实例，释放资源
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

**关键点解析**

1. **初始化 `AliPlayerWidgetController`**：
   - 在 `initState` 方法中创建 `_controller` 实例。
2. **调用 `configure` 接口**：
   - 使用 `AliPlayerWidgetData` 配置视频地址、封面图、标题等信息。
   - 调用 `_controller.configure(data)` 将数据传递给播放器组件。
3. **释放资源**：
   - 在 `dispose` 方法中调用 `_controller.destroy()`，避免内存泄漏。

**更多场景支持**

上述示例展示了点播场景的基本用法。如需了解更复杂的场景（如直播、列表播放等），请参考 `aliplayer_widget_example` 示例工程，其中包含了详细的代码和使用说明。

---

## **五、核心组件**

### **1. AliPlayerWidget**

`AliPlayerWidget` 是核心的播放器组件，用于嵌入到 Flutter 应用中并播放视频。

**构造函数**

```dart
AliPlayerWidget(
  AliPlayerWidgetController controller, {
  Key? key,
  List<Widget> overlays = const [],
});
```

- **`controller`**: 播放器控制器，用于管理播放逻辑。
- **`overlays`**: 可选的浮层组件列表，用于在播放器组件上叠加自定义 UI。

**示例**

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

### **2. AliPlayerWidgetController**

`AliPlayerWidgetController` 是播放器组件的核心控制器，用于管理播放器组件的初始化、播放、销毁等逻辑。

**主要方法**

- **`configure(AliPlayerWidgetData data)`**: 配置数据源。

- **`play()`**: 开始播放视频。

- **`pause()`**: 暂停播放。

- **`seek(Duration position)`**: 跳转到指定播放位置。

- **`setUrl(String url)`**: 设置视频播放地址。

- **`destroy()`**: 销毁播放器实例，释放资源。

**示例**

```dart
// 初始化播放器组件控制器
final controller = AliPlayerWidgetController(context);

// 设置播放器组件数据
AliPlayerWidgetData data = AliPlayerWidgetData.fromUrl(
  videoUrl: "https://example.com/video.mp4",
);
controller.configure(data);

// 销毁播放器
controller.destroy();
```

### **3. AliPlayerWidgetData**

`AliPlayerWidgetData` 是播放器组件所需的数据模型，包含视频地址、封面图、标题等信息。

**属性**

- **`videoUrl`**: 视频播放地址（必填）。

- **`coverUrl`**: 封面图地址（可选）。

- **`videoTitle`**: 视频标题（可选）。

- **`thumbnailUrl`**: 缩略图地址（可选）。

- **`sceneType`**: 播放场景类型，默认为点播（`SceneType.vod`）。

**示例**

```dart
AliPlayerWidgetData.fromUrl(
  videoUrl: "https://example.com/video.mp4",
  coverUrl: "https://example.com/cover.jpg",
  videoTitle: "Sample Video",
  sceneType: SceneType.vod,
);
```

---

## **六、自定义功能**

### **1. 视频源支持**

播放器提供了灵活的视频源配置方式，支持以下四种主要的视频源类型：

- **URL 模式**：通过直接提供视频 URL 进行播放，适用于公开访问的视频资源。

  ```dart
  // 方式1：使用 URL 创建播放数据
  final data = AliPlayerWidgetData.fromUrl(
    videoUrl: "https://example.com/video.mp4",
  );
  
  // 方式2：使用 videoSource 创建播放数据
  final videoSource = VideoSourceFactory.createUrlSource(
    "https://example.com/video.mp4",
  );
  final data = AliPlayerWidgetData(
    videoSource: videoSource,
  );
  ```

- **VidSts 模式**：通过视频 ID(VID) 和阿里云 STS (Security Token Service) 令牌进行播放，提供更高的安全性和访问控制。

  ```dart
  // 示例：使用VidSts创建播放数据
  final videoSource = VideoSourceFactory.createVidStsSource(
    vid: "视频ID",
    accessKeyId: "访问密钥ID",
    accessKeySecret: "访问密钥密文",
    securityToken: "安全令牌",
    region: "区域信息",
  );
  final data = AliPlayerWidgetData(
    videoSource: videoSource,
  );
  ```

- **VidAuth 模式**：通过视频 ID 和播放凭证进行授权播放，适用于需要更简单授权机制的场景。

  ```dart
  // 示例：使用VidAuth创建播放数据
  final videoSource = VideoSourceFactory.createVidAuthSource(
    vid: "视频ID",
    playAuth: "播放凭证",
  );
  final data = AliPlayerWidgetData(
    videoSource: videoSource,
  );
  ```

开发者可以根据实际需求选择最适合的视频源类型。

### **2. 浮层组件**

通过 `overlays` 参数，您可以轻松地在播放器上叠加自定义 UI 组件。例如，添加点赞、评论、分享按钮等。

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

### **3. 常用接口**

`AliPlayerWidget` 提供了一系列对外接口，方便开发者直接控制播放器的行为。这些接口通过 `AliPlayerWidgetController` 暴露，支持播放控制、状态查询、数据更新等功能。

以下是一些常用的对外接口及其使用场景：

| **分类**         | **接口名称**             | **功能描述**                               |
| ---------------- | ------------------------ | ------------------------------------------ |
| **配置与初始化** | `configure`              | 配置播放器数据源并初始化播放器             |
|                  | `prepare`                | 准备播放器（手动调用准备流程）             |
| **播放控制**     | `play`                   | 开始播放视频                               |
|                  | `pause`                  | 暂停播放                                   |
|                  | `stop`                   | 停止播放并重置播放器                       |
|                  | `seek`                   | 跳转到指定的播放位置                       |
|                  | `togglePlayState`        | 切换播放状态（播放/暂停）                  |
|                  | `replay`                 | 重新播放视频（通常用于播放完成后重新开始） |
| **播放属性设置** | `setSpeed`               | 设置播放速度                               |
|                  | `setVolume`              | 设置音量                                   |
|                  | `setVolumeWithDelta`     | 根据增量调整音量                           |
|                  | `setBrightness`          | 设置屏幕亮度                               |
|                  | `setBrightnessWithDelta` | 根据增量调整屏幕亮度                       |
|                  | `setLoop`                | 设置是否循环播放                           |
|                  | `setMute`                | 设置是否静音                               |
|                  | `setMirrorMode`          | 设置镜像模式（如水平镜像、垂直镜像等）     |
|                  | `setRotateMode`          | 设置旋转角度（如 90°、180° 等）            |
|                  | `setScaleMode`           | 设置渲染填充模式（如拉伸、裁剪等）         |
| **清晰度切换**   | `selectTrack`            | 切换播放清晰度                             |
| **缩略图相关**   | `requestThumbnailBitmap` | 请求指定时间点的缩略图                     |
| **其他功能**     | `clearCaches`            | 清除播放器缓存（包括视频缓存和图片缓存）   |
|                  | `getWidgetVersion`       | 获取当前 Flutter Widget 的版本号           |

### **4. 事件通知**

`AliPlayerWidgetController` 提供了一系列 `ValueNotifier`，用于实时通知播放器的状态变化和用户操作。以下是一些常用的 `notifier` 及其用途：

#### **常用 Notifier 概览**

**1. 播放状态管理**

| **Notifier**        | **功能描述**                                         |
| ------------------- | ---------------------------------------------------- |
| `playStateNotifier` | 用于监听播放状态的变化（如播放、暂停、停止等）。     |
| `playErrorNotifier` | 监听播放过程中发生的错误信息，提供错误码和错误描述。 |

**2. 播放进度管理**

| **Notifier**               | **功能描述**                                               |
| -------------------------- | ---------------------------------------------------------- |
| `currentPositionNotifier`  | 实时更新当前播放进度（单位：毫秒）。                       |
| `bufferedPositionNotifier` | 跟踪视频的缓冲进度，帮助用户了解已缓存的内容范围。         |
| `totalDurationNotifier`    | 提供视频的总时长信息，便于计算播放进度百分比或显示总时长。 |

**3. 音量与亮度控制**

| **Notifier**         | **功能描述**                                                 |
| -------------------- | ------------------------------------------------------------ |
| `volumeNotifier`     | 监听音量变化，支持动态调整音量大小（范围通常为 0.0 到 1.0）。 |
| `brightnessNotifier` | 监听屏幕亮度变化，允许用户根据环境光线调整亮度（范围通常为 0.0 到 1.0）。 |

**4. 清晰度与缩略图**

| **Notifier**               | **功能描述**                                                 |
| -------------------------- | ------------------------------------------------------------ |
| `currentTrackInfoNotifier` | 跟踪当前视频清晰度信息的变化（如标清、高清、超清等），并提供切换后的清晰度详情。 |
| `thumbnailNotifier`        | 监听缩略图加载状态，确保在拖动进度条时能够实时显示对应的缩略图预览。 |

#### **使用方法**

通过 `ValueListenableBuilder` 监听 `notifier` 的变化，可以实时更新 UI 或执行逻辑。

**示例代码**

```dart
// 监听播放错误
ValueListenableBuilder<Map<int?, String?>?>(
  valueListenable: _controller.playErrorNotifier,
  builder: (context, error, _) {
    if (error != null) {
      final errorCode = error.keys.firstOrNull;
      final errorMsg = error.values.firstOrNull;
      return Text("播放错误: [$errorCode] $errorMsg");
    }
    return SizedBox.shrink();
  },
);
```

---

## **七、注意事项**

1. **资源释放**：在页面销毁时，请务必调用 `AliPlayerWidgetController.destroy()` 方法以释放播放器资源。
2. **网络权限**：确保应用已配置必要的网络权限，以便加载在线视频。
3. **缩略图支持**：如果需要使用缩略图功能，请确保提供了有效的缩略图地址。
4. **调试与优化**：建议在开发过程中开启日志功能，便于排查问题。同时，注意优化浮层组件的性能，避免影响播放流畅性。

---

## **八、示例工程与演示包**

为了让开发者更快速地上手并深入理解如何在实际项目中集成和使用 **AliPlayerWidget**，我们提供了两种资源：**示例工程** 和基于该工程构建的 **演示包**。以下分别介绍两者的用途和获取方式。

### **1. 示例工程**
`aliplayer_widget_example` 是一个完整的示例工程，旨在帮助开发者快速理解和集成 **AliPlayerWidget** 的核心功能。

您可以访问以下链接查看示例工程的完整文档：

- **中文文档**: [aliplayer_widget_example README](./example/README.md)
- **English Documentation**: [aliplayer_widget_example README-EN](./example/README-EN.md)

通过示例工程，您可以直观地了解以下内容：

- 如何嵌入视频播放器组件。
- 如何配置不同场景下的播放功能（如点播、直播、列表播放）。
- 如何利用自定义选项实现个性化的用户体验。

### **2. 演示包**
为了帮助开发者快速体验 **AliPlayerWidget** 的功能，我们基于 `aliplayer_widget_example` 示例工程构建了一个演示包。该演示包可以直接安装到设备上运行，无需额外配置开发环境。

#### **获取方式**
使用手机扫描以下二维码，即可快速下载并安装演示包：

![Demo QR Code](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/demo-qr-code.png)  
> **注意**：二维码链接指向最新版本的演示包，请确保您的设备已开启允许安装第三方应用的权限。

---

## **九、开源与源码获取**

**aliplayer_widget** 已发布至以下 Pub 源，推荐开发者通过包管理工具集成：

- **Pub 官方源**: [pub.dev](https://pub.dev/packages/aliplayer_widget)
- **国内镜像源**: [pub.flutter-io.cn](https://pub.flutter-io.cn/packages/aliplayer_widget)

如果需要对组件进行自定义修改，您可以使用源码依赖的方式，直接获取并修改源码。完整源码可通过以下方式获取：

- **GitHub 仓库**: [aliplayer_widget](https://github.com/aliyun/player_widget)
  

如果无法访问 GitHub，可通过以下链接直接下载源码包：

- **源码包下载地址**: [aliplayer_widget.zip](https://alivc-demo-cms.alicdn.com/versionProduct/sourceCode/aliplayer_widget/aliplayer_widget.zip)

开源内容包括：

- **核心组件**：`AliPlayerWidget` 和 `AliPlayerWidgetController` 的完整实现。
- **示例工程**：`aliplayer_widget_example` 提供点播、直播、列表播放等场景的代码示例，帮助开发者快速集成和使用。
- **文档与注释**：源码包含详细注释和开发指南，便于二次开发与定制。

---

更多关于使用阿里云播放器 SDK 的常见问题及修复建议，请参见[播放器常见问题](https://help.aliyun.com/zh/vod/support/faq-about-apsaravideo-player/)。


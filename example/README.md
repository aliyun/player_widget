Language: 中文简体 | [English](README-EN.md)

# aliplayer_widget_example

## **一、概述**

`aliplayer_widget_example` 是基于 `aliplayer_widget` Flutter 库的示例工程，旨在帮助开发者快速上手并深入理解如何在实际项目中集成和使用 `AliPlayerWidget`。作为一款高性能的视频播放组件，`AliPlayerWidget` 专为 Flutter 应用设计，支持点播（VOD）、直播、列表播放等多种场景，同时提供灵活的 UI 定制能力和丰富的功能集。

通过本示例工程，开发者可以直观地了解以下内容：

- 如何嵌入视频播放器组件。
- 如何配置不同场景下的播放功能（如点播、直播、列表播放）。
- 如何利用自定义选项实现个性化的用户体验。

无论是教育、娱乐、电商领域，还是近年来兴起的短剧应用场景，`AliPlayerWidget` 都能显著降低开发成本，帮助构建流畅且高效的视频播放体验。

---

## **二、编译与运行**

### **1. 环境要求**

在编译和运行 `aliplayer_widget_example` 工程之前，请确保您的开发环境满足以下要求：

- **Flutter SDK**
  - 版本要求不低于 `2.10.0`，推荐版本为 `3.22.2`。
  - 运行 `flutter doctor` 检查并解决所有问题。
- **JDK**
  - 推荐使用 JDK 11。
  - 设置方法：`Preferences -> Build, Execution, Deployment -> Build Tools -> Gradle -> Gradle JDK -> 选择 11`。
- **Android 开发环境**
  - 安装最新版本的 Android Studio。
  - 配置 Android SDK，最低支持 API 级别为 21（Android 5.0）。
  - Gradle 版本不低于 `7.0`。
- **iOS 开发环境**
  - 安装最新版本的 Xcode。
  - 配置 CocoaPods，推荐版本为 `1.13.0`。
  - 最低支持 iOS 版本为 `10.0`。

### **2. 编译与运行方式**

#### **a. 命令行方式**

1. **克隆仓库**

首先，克隆 `aliplayer_widget_example` 仓库到本地：

```bash
cd aliplayer_widget_example
```

2. **安装依赖**

执行以下命令以安装项目所需的依赖：

```bash
flutter pub get
```

3. **编译 Android 工程**

如果您需要编译 Android 工程，请按照以下步骤操作：

* 确保已安装 Android SDK 和 Gradle。
* 执行以下命令生成 APK 文件：

```bash
flutter build apk
```

编译完成后，APK 文件将位于`build/app/outputs/flutter-apk/app-release.apk`。

4. **编译 iOS 工程**

如果您需要编译 iOS 工程，请按照以下步骤操作：

* 确保已安装 Xcode 和 CocoaPods。

* 初始化 CocoaPods 依赖：

```bash
cd ios && pod install && cd ..
```

* 执行以下命令生成 iOS 应用包（IPA 文件）：

```bash
flutter build ipa
```

编译完成后，IPA 文件将位于`build/ios/ipa/Runner.ipa`。

5. **运行 Android 示例**

```bash
flutter run lib/main.dart
```

6. **运行 iOS 示例**

```bash
cd ios && pod install && cd ..

flutter run lib/main.dart
```

#### **b. IDE 方式**

1. **使用 Android Studio**

* 打开项目：

  - 启动 Android Studio。

  - 选择 `Open an Existing Project`，然后导航到克隆的 `aliplayer_widget_example` 目录并打开。

* 安装依赖：
  - 在 Android Studio 中，点击 `pubspec.yaml` 文件，然后点击右上角的 `Pub Get` 按钮以安装依赖。

* 配置设备：
  - 确保已连接 Android 真机设备。

* 运行应用：
  - 点击工具栏中的绿色运行按钮（`Run`），选择目标设备后即可启动应用。

2. **使用 VS Code**

* 打开项目：

  - 启动 VS Code。

  - 选择 `File -> Open Folder`，然后导航到克隆的 `aliplayer_widget_example` 目录并打开。

* 安装依赖：

  - 打开终端（`Ctrl + ~`），运行以下命令以安装依赖：

    ```bash
    flutter pub get
    ```

* 配置设备：

  - 确保已连接 Android 或 iOS 真机设备。

  - 使用 VS Code 的设备选择器（左下角）选择目标设备。

* 运行应用：
  - 按下 `F5` 或点击左侧活动栏中的 `Run and Debug` 图标，选择 `Flutter` 配置并启动调试会话。

3. **使用 Xcode（仅限 iOS）**

* 打开项目：
  - 导航到 `ios` 目录，双击 `Runner.xcworkspace` 文件以在 Xcode 中打开项目。

* 安装 CocoaPods 依赖：

  - 如果尚未安装 CocoaPods 依赖，请在终端中运行以下命令：

    ```bash
    cd ios && pod install && cd ..
    ```

* 配置签名：
  - 在 Xcode 中，选择 `Runner` 项目，进入 `Signing & Capabilities` 标签页，配置有效的开发者账号和签名证书。

* 运行应用：
  - 点击 Xcode 工具栏中的运行按钮（`▶️`），选择目标设备后即可启动应用。

---

## **三、示例场景说明**

`aliplayer_widget_example` 工程涵盖了多个典型场景，展示了 `AliPlayerWidget` 的核心功能及其在不同场景中的实际应用。

### **1. 点播播放页面（LongVideoPage）**

- **功能描述**：
  展示如何使用 `AliPlayerWidget` 实现基础的点播视频播放功能。
- **关键代码**：
  
  ```dart
  @override
  void initState() {
    super.initState();
    _controller = AliPlayerWidgetController(context);
    final videoSource = VideoSourceFactory.createUrlSource(
      "https://example.com/sample-video.mp4",
    );
    final data = AliPlayerWidgetData(
      videoSource: videoSource,
      coverUrl: "https://example.com/sample-cover.jpg",
      videoTitle: "Sample Video Title",
    );
    _controller.configure(data);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AliPlayerWidget(_controller),
    );
  }
  ```
- **运行效果**：
  页面加载后自动播放指定的点播视频，并显示封面图和标题。用户可以通过控制栏进行暂停、快进、调整音量等操作。

### **2. 直播播放页面（LivePage）**

- **功能描述**：
  
  展示如何配置 `AliPlayerWidget` 以支持实时直播流媒体播放。
  
- **关键代码**：
  
  ```dart
  @override
  void initState() {
    super.initState();
    _controller = AliPlayerWidgetController(context);
    final videoSource = VideoSourceFactory.createUrlSource(
      "https://example.com/live-stream.m3u8",
    );
    final data = AliPlayerWidgetData(
      sceneType: SceneType.live,
      videoSource: videoSource,
    );
    _controller.configure(data);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: AliPlayerWidget(_controller)),
          _buildChatArea(),
          _buildMessageInput(),
        ],
      ),
    );
  }
  ```
  
- **运行效果**：
  页面加载后实时播放直播流，支持低延迟播放。用户可以在聊天窗口中查看消息并发送自己的评论。

### **3. 短视频列表播放页面（ShortVideoPage）**

- **功能描述**：
  
  展示如何在列表中嵌入多个 `AliPlayerWidget` 实例，实现多视频的列表播放功能。
  
- **关键代码**：
  ```dart
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadVideoInfoList();
    _pageController.addListener(_onPageChanged);
  }
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: videoInfoList.length,
        itemBuilder: (context, index) {
          final videoInfo = videoInfoList[index];
          return ShortVideoItem(videoInfo: videoInfo);
        },
      ),
    );
  }
  ```
  
- **运行效果**：
  页面展示一个视频列表，每个列表项包含一个独立的播放器实例。用户可以通过滑动切换视频，同时支持手势滑动切换视频。

---

## **四、总结**

`aliplayer_widget_example` 工程通过具体的页面实现，全面展示了 `aliplayer_widget` 的核心功能及其在不同场景中的实际应用。无论是基础的点播播放页面，还是复杂的直播播放页面和短视频列表播放页面，开发者都可以通过本示例工程快速掌握集成和使用方法，并根据需求进行定制化开发。

---

更多关于使用阿里云播放器 SDK 的常见问题及修复建议，请参见[播放器常见问题](https://help.aliyun.com/zh/vod/support/faq-about-apsaravideo-player/)。


# **AliPlayerWidget 集成指引**

本文档详细介绍了 AliPlayerWidget 的集成步骤和前提条件，帮助开发者快速上手使用该组件。

## **一、前提条件**

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

## **二、添加依赖**

您可以通过以下任一方式添加依赖：

### **方式一：使用命令行添加（推荐）**

在项目根目录下执行以下命令：

```bash
flutter pub add aliplayer_widget
flutter pub add flutter_aliplayer
```

### **方式二：手动添加**

在您的 `pubspec.yaml` 文件的 `dependencies` 部分添加以下内容：

```yaml
dependencies:
  aliplayer_widget: <latest_version>
  flutter_aliplayer: <latest_version>
```

## **三、获取依赖并构建项目**

添加依赖后，需要获取依赖并构建项目：

1. **获取依赖包**（如果使用手动添加方式）：
   ```bash
   flutter pub get
   ```

2. **iOS平台额外步骤**（仅限iOS）：
   ```bash
   cd ios
   pod install
   cd ..
   ```

3. **构建项目**：
   构建Android APK：
   ```bash
   flutter build apk
   ```
   
   构建iOS应用：
   ```bash
   flutter build ios
   ```
   
   或构建通用应用：
   ```bash
   flutter build
   ```

完成以上步骤后，您就可以开始使用 AliPlayerWidget 进行视频播放开发了。如需了解具体的使用方法，请参考我们的[快速开始指南](./quick-start.md)。
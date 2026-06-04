# **AliPlayerWidget Integration Guide**

This document details the integration steps and prerequisites for AliPlayerWidget, helping developers get started quickly with this component.

## **1. Prerequisites**

### **1.1 Development Environment Setup**

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

### **1.2 Permission Configuration**

- **Permission Settings**:
  - Enable network permissions in both Android and iOS to allow the player to load online video resources.

- **License Configuration**:
  - You must obtain the License Authorization Certificate and License Key for the ApsaraVideo Player SDK. Detailed steps for obtaining these can be found at [Apply for License](https://www.alibabacloud.com/help/en/apsara-video-sdk/user-guide/license-authorization-and-management#13133fa053843).
  - **Note**: If the License is not correctly configured, the player will not function properly and may throw authorization exceptions.

For more initialization configurations, refer to the `aliplayer_widget_example` sample project.

## **2. Add Dependencies**

`aliplayer_widget` already depends on `flutter_aliplayer` internally. For most users, you only need to add `aliplayer_widget`. If you need direct access to low-level APIs (e.g., MediaLoader for preloading), you can additionally declare `flutter_aliplayer` explicitly.

### **SDK Version Notes**

`aliplayer_widget` uses the standalone player SDK version by default.

| Scenario | Recommended Version | Description |
|----------|-------------------|-------------|
| Playback only | Standard Player SDK (Recommended) | Use the standard [`flutter_aliplayer`](https://pub.dev/packages/flutter_aliplayer) version |
| Push streaming + Playback | interactivelive special version | Only recommended when integrating [`flutter_livepush_plugin`](https://pub.dev/packages/flutter_livepush_plugin) or similar push streaming capabilities, and when alignment with the underlying AliVCSDK is required |

> **⚠️ Important**: Do not use the `interactivelive` special version unless necessary. If your project only requires playback capabilities, use the standard player SDK with a fixed full version number to avoid unnecessary integration of the all-in-one SDK, which may increase dependency complexity or cause potential SDK conflicts.

You can add dependencies using either of the following methods:

### **Method 1: Command Line Addition (Recommended)**

Execute the following commands in the project root directory:

```bash
# Required
flutter pub add aliplayer_widget

# Optional: only if you need direct access to low-level flutter_aliplayer APIs
flutter pub add flutter_aliplayer
```

### **Method 2: Manual Addition**

Add the following content to the `dependencies` section of your `pubspec.yaml` file:

```yaml
dependencies:
  # Required
  aliplayer_widget: <latest_version>

  # Optional: only if you need direct access to low-level flutter_aliplayer APIs
  flutter_aliplayer: <latest_version>
```

## **3. Get Dependencies and Build Project**

After adding dependencies, you need to fetch dependencies and build the project:

1. **Get dependencies** (if using manual addition method):
   ```bash
   flutter pub get
   ```

2. **Additional steps for iOS platform** (iOS only):
   ```bash
   cd ios
   pod install
   cd ..
   ```

3. **Build project**:
   Build Android APK:
   ```bash
   flutter build apk
   ```
   
   Build iOS app:
   ```bash
   flutter build ios
   ```
   
   Or build universal app:
   ```bash
   flutter build
   ```

After completing the above steps, you can start developing video playback with AliPlayerWidget. For specific usage instructions, please refer to our [Quick Start Guide](./quick-start-en.md).
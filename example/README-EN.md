Language: [Simplified Chinese](README.md) | English

# aliplayer_widget_example

## **1. Overview**

`aliplayer_widget_example` is a sample project based on the `aliplayer_widget` Flutter library, designed to help developers quickly get started and deeply understand how to integrate and use `AliPlayerWidget` in real-world projects. As a high-performance video playback component, `AliPlayerWidget` is specifically tailored for Flutter applications, supporting various scenarios such as Video-on-Demand (VOD), live streaming, playlist playback, and more. It also provides flexible UI customization capabilities and a rich set of features.

Through this sample project, developers can intuitively understand the following:

- How to embed a video player component.
- How to configure playback functionality for different scenarios (e.g., VOD, live streaming, playlist playback).
- How to leverage custom options to achieve personalized user experiences.

Whether in the fields of education, entertainment, and e-commerce, or in the rapidly emerging short drama application scenarios in recent years, `AliPlayerWidget` significantly reduces development costs and helps build a smooth and efficient video playback experience.

---

## **2. Compilation and Execution**

### **2.1 Environment Requirements**

Before compiling and running the `aliplayer_widget_example` project, ensure your development environment meets the following requirements:

- **Flutter SDK**
  - Version must be no lower than `2.10.0`, with version `3.22.2` recommended.
  - Run `flutter doctor` to check and resolve any issues.
- **JDK**
  - JDK 11 is recommended.
  - Setup method: `Preferences -> Build, Execution, Deployment -> Build Tools -> Gradle -> Gradle JDK -> Select 11`.
- **Android Development Environment**
  - Install the latest version of Android Studio.
  - Configure Android SDK with a minimum supported API level of 21 (Android 5.0).
  - Gradle version must be no lower than `7.0`.
- **iOS Development Environment**
  - Install the latest version of Xcode.
  - Configure CocoaPods, with version `1.13.0` recommended.
  - Minimum supported iOS version is `10.0`.

### **2.2 Compilation and Execution Methods**

#### **a. Command-Line Method**

1. **Clone the Repository**

First, clone the `aliplayer_widget_example` repository to your local machine:

```bash
cd aliplayer_widget_example
```

2. **Install Dependencies**

Run the following command to install the required dependencies for the project:

```bash
flutter pub get
```

3. **Compile Android Project**

If you need to compile the Android project, follow these steps:

* Ensure Android SDK and Gradle are installed.
* Execute the following command to generate an APK file:

```bash
flutter build apk
```

After compilation, the APK file will be located at `build/app/outputs/flutter-apk/app-release.apk`.

4. **Compile iOS Project**

If you need to compile the iOS project, follow these steps:

* Ensure Xcode and CocoaPods are installed.

* Initialize CocoaPods dependencies:

```bash
cd ios && pod install && cd ..
```

* Execute the following command to generate an iOS app package (IPA file):

```bash
flutter build ipa
```

After compilation, the IPA file will be located at `build/ios/ipa/Runner.ipa`.

5. **Run Android Example**

```bash
flutter run lib/main.dart
```

6. **Run iOS Example**

```bash
cd ios && pod install && cd ..

flutter run lib/main.dart
```

#### **b. IDE Method**

1. **Using Android Studio**

* Open the Project:

  - Launch Android Studio.

  - Select `Open an Existing Project`, then navigate to the cloned `aliplayer_widget_example` directory and open it.

* Install Dependencies:
  - In Android Studio, click the `pubspec.yaml` file, then click the `Pub Get` button in the top-right corner to install dependencies.

* Configure Device:
  - Ensure an Android physical device is connected.

* Run the Application:
  - Click the green run button (`Run`) in the toolbar, select the target device, and the application will launch.

2. **Using VS Code**

* Open the Project:

  - Launch VS Code.

  - Select `File -> Open Folder`, then navigate to the cloned `aliplayer_widget_example` directory and open it.

* Install Dependencies:

  - Open the terminal (`Ctrl + ~`) and run the following command to install dependencies:

    ```bash
    flutter pub get
    ```

* Configure Device:

  - Ensure an Android or iOS physical device is connected.

  - Use the device selector in VS Code (bottom-left) to choose the target device.

* Run the Application:
  - Press `F5` or click the `Run and Debug` icon in the left activity bar, select the `Flutter` configuration, and start the debugging session.

3. **Using Xcode (iOS Only)**

* Open the Project:
  - Navigate to the `ios` directory and double-click the `Runner.xcworkspace` file to open the project in Xcode.

* Install CocoaPods Dependencies:

  - If CocoaPods dependencies are not installed, run the following command in the terminal:

    ```bash
    cd ios && pod install && cd ..
    ```

* Configure Signing:
  - In Xcode, select the `Runner` project, go to the `Signing & Capabilities` tab, and configure a valid developer account and signing certificate.

* Run the Application:
  - Click the run button (`▶️`) in the Xcode toolbar, select the target device, and the application will launch.

---

## **3. Example Scenario Descriptions**

The `aliplayer_widget_example` project covers multiple typical scenarios, showcasing the core functionalities of `AliPlayerWidget` and their practical applications in different contexts.

### **3.1 VOD Playback Page (LongVideoPage)**

Demonstrates how to use `AliPlayerWidget` to implement basic VOD video playback functionality.

- **Core Features**:
  - Supports Vid + PlayAuth playback method
  - Supports video title display
  - Provides complete playback control bar (pause, fast-forward, volume adjustment, etc.)

- **Implementation Points**:
  - Use `AliPlayerWidgetController` to create a controller
  - Configure Vid video source via `VideoSourceFactory.createVidAuthSource()`
  - Use `AliPlayerWidgetData` to set playback parameters

- **Execution Effect**: The specified VOD video plays automatically after the page loads, and users can perform various playback operations via the control bar.

### **3.2 Live Streaming Playback Page (LivePage)**

Demonstrates how to configure `AliPlayerWidget` to support real-time live streaming playback.

- **Core Features**:
  - Supports HLS/FLV and other live streaming formats
  - Supports low-latency playback mode
  - Can integrate interactive features such as chat and danmaku

- **Implementation Points**:
  - Set `sceneType: SceneType.live` to specify the live streaming scenario
  - Configure live stream URL as the video source
  - Can extend chat area and message input components

- **Execution Effect**: The page plays the live stream in real-time, supporting a smooth live streaming viewing experience.

### **3.3 Short Video List Playback Page (ShortVideoPage)**

Demonstrates how to embed multiple `AliPlayerWidget` instances in a list to achieve short video swipe playback functionality.

- **Core Features**:
  - Supports both `PreloadPageView` (preload) and `PageView` modes
  - Automatically plays the current video and pauses others when swiping
  - Supports interactive button overlays for like, comment, and share

- **Implementation Points**:
  - Set `sceneType: SceneType.listPlayer` to specify the list playback scenario
  - Control playback state through page change listener for mutual exclusion
  - Implement video preloading via `AliPlayerPreload` for smoother swiping
  - Use `slotBuilders` to build the right-side action button overlay

- **Execution Effect**: Displays a swipeable video list, users can swipe up/down to switch videos, only the current video plays automatically.

---

## **4. Summary**

The `aliplayer_widget_example` project comprehensively demonstrates the core functionalities of `aliplayer_widget` and their practical applications in various scenarios through concrete page implementations. Whether it's a basic VOD playback page, a complex live streaming playback page, or a short video list playback page, developers can quickly grasp integration and usage methods through this sample project and customize it according to their needs.

---

For more common issues and resolution suggestions related to the use of Alibaba Cloud Player SDK, please refer to [FAQ about ApsaraVideo Player](https://www.alibabacloud.com/help/en/vod/support/faq-about-apsaravideo-player/).

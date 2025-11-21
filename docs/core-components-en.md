# **AliPlayerWidget Core Components**

AliPlayerWidget adopts an MVC-inspired layered design, separating the view (View), control logic (Controller), and data model (Data) into three core components that work together to deliver complete video playback functionality.

## **1. AliPlayerWidget (View)**

`AliPlayerWidget` is the core player component (View) used to embed and play videos within Flutter applications.

### **Constructor**

```dart
AliPlayerWidget(
  AliPlayerWidgetController controller, {
  Key? key,
  List<Widget> overlays = const [],
});
```

- **`controller`**: The player controller used to manage playback logic.
- **`overlays`**: Optional list of overlay components to stack custom UI elements over the player component.

### **Example**

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

## **2. AliPlayerWidgetController (Controller)**

`AliPlayerWidgetController` is the controller component that manages initialization, playback, destruction, and other logic of the player component.

### **Primary Methods**

- **`configure(AliPlayerWidgetData data)`**: Configures the data source.
- **`play()`**: Starts video playback.
- **`pause()`**: Pauses playback.
- **`seek(Duration position)`**: Jumps to the specified playback position.
- **`destroy()`**: Destroys the player instance to release resources.

## **3. AliPlayerWidgetData (Data)**

`AliPlayerWidgetData` is the data model (Data) required by the player component, containing video URL, cover image, title, and other information.

### **Attributes**

- **`videoSource`**: Video playback source (required).
- **`coverUrl`**: Cover image URL (optional).
- **`videoTitle`**: Video title (optional).
- **`thumbnailUrl`**: Thumbnail URL (optional).
- **`sceneType`**: Playback scenario type, defaulting to VOD (`SceneType.vod`).

## **4. Global Configuration (Optional)**

In addition to the three core components mentioned above, AliPlayerWidget also provides an optional global configuration class `AliPlayerWidgetGlobalSetting` for configuring global player behavior, such as cache settings and storage paths. This configuration item is not part of the core components, but global configuration is usually recommended when using AliPlayerWidget.

### **Main Functions**

- **Global Configuration Initialization**: Initialize global configuration through the [setupConfig] method
- **Storage Path Setting**: Set cache and file storage paths through the [setStoragePaths] method
- **Cache Management**: Clear all caches through the [clearCaches] method

### **Usage Example**

Initialize global settings at application startup:

```dart
/// Initialize aliplayer_widget global settings
Future<void> initializeGlobalSettings() async {
  // Initialize global configuration
  await AliPlayerWidgetGlobalSetting.setupConfig();

  String? cachePath;
  String? filesPath;

  if (Platform.isAndroid) {
    // Android: Try to use external storage
    final externalCacheDirs = await getExternalCacheDirectories();
    cachePath = externalCacheDirs?.isNotEmpty == true
        ? externalCacheDirs?.first.path
        : null;

    final externalStorageDir = await getExternalStorageDirectory();
    filesPath = externalStorageDir?.path;
  } else {
    // iOS / Other platforms: Use standard app sandbox directories
    final cacheDir = await getApplicationCacheDirectory();
    final docsDir = await getApplicationDocumentsDirectory();
    cachePath = cacheDir.path;
    filesPath = docsDir.path;
  }

  // Set global storage paths
  AliPlayerWidgetGlobalSetting.setStoragePaths(
    cachePath: cachePath,
    filesPath: filesPath,
  );
}
```
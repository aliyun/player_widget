# **AliPlayerWidget API Reference**

AliPlayerWidget provides a rich set of API interfaces that allow developers to directly control player behavior. These interfaces are exposed through `AliPlayerWidgetController`, supporting playback control, status queries, data updates, and more.

## **Common Interfaces**

### **Configuration & Initialization**

| Interface Name | Function Description                              |
| -------------- | ------------------------------------------------- |
| `configure`    | Configures the player data source and initializes the player |
| `prepare`      | Manually triggers the preparation process of the player |
| `destroy`      | Destroys the player instance and releases resources |

### **Playback Control**

| Interface Name      | Function Description                                     |
| ------------------- | -------------------------------------------------------- |
| `play`              | Starts video playback                                    |
| `pause`             | Pauses playback                                          |
| `stop`              | Stops playback and resets the player                     |
| `seek`              | Jumps to the specified playback position                 |
| `togglePlayState`   | Toggles between play and pause states                    |
| `replay`            | Replays the video (typically used after playback completion) |

### **Playback Property Settings**

| Interface Name          | Function Description                                                           |
| ----------------------- |--------------------------------------------------------------------------------|
| `setSpeed`              | Sets playback speed                                                            |
| `setVolume`             | Sets volume                                                                    |
| `setVolumeWithDelta`    | Adjusts volume incrementally                                                   |
| `setBrightness`         | Sets screen brightness(The logical details need to be implemented by yourself) |
| `setBrightnessWithDelta`| Adjusts screen brightness incrementally(The logical details need to be implemented by yourself)|
| `setLoop`               | Sets whether to loop playback                                                  |
| `setMute`               | Sets whether to mute audio                                                     |
| `setMirrorMode`         | Sets mirror mode (e.g., horizontal or vertical mirroring)                      |
| `setRotateMode`         | Sets rotation angle (e.g., 90°, 180°, etc.)                                    |
| `setScaleMode`          | Sets rendering fill mode (e.g., stretch, crop, etc.)                           |

### **Quality Switching**

| Interface Name | Function Description     |
| -------------- | ------------------------ |
| `selectTrack`  | Switches playback quality|

### **Thumbnail Related**

| Interface Name          | Function Description              |
| ----------------------- | --------------------------------- |
| `requestThumbnailBitmap`| Requests thumbnails at specified time points |

### **Other Functions**

| Interface Name    | Function Description                                    |
| ----------------- | ------------------------------------------------------- |
| `clearCaches`     | Clears player caches (including video and image caches) |
| `getWidgetVersion`| Retrieves the current Flutter Widget version number     |

## **Event Notifications**

`AliPlayerWidgetController` provides a series of `ValueNotifier`s for real-time notifications of player state changes and user operations.

### **Playback State Management**

| Notifier            | Function Description                                      |
| ------------------- | --------------------------------------------------------- |
| `playStateNotifier` | Monitors changes in playback state (e.g., playing, paused, stopped). |
| `playErrorNotifier` | Listens for errors during playback, providing error codes and descriptions. |
| `isRenderedNotifier`| Listens for whether the player has rendered the first frame. |

### **Playback Progress Management**

| Notifier                 | Function Description                                              |
| ------------------------ | ----------------------------------------------------------------- |
| `currentPositionNotifier`| Updates current playback progress in real-time (unit: milliseconds). |
| `bufferedPositionNotifier`| Tracks video buffering progress, helping users understand cached content ranges. |
| `totalDurationNotifier`  | Provides total video duration information for calculating playback percentage or displaying total duration. |

### **Volume and Brightness Control**

| Notifier           | Function Description                                               |
| ------------------ | ------------------------------------------------------------------ |
| `volumeNotifier`   | Monitors volume changes, supporting dynamic adjustment of volume levels (range typically 0.0 to 1.0). |
| `brightnessNotifier`| Monitors screen brightness changes, allowing users to adjust brightness based on ambient light (range typically 0.0 to 1.0). |
| `speedNotifier`    | Monitors playback speed changes.                                   |

### **Playback Property States**

| Notifier            | Function Description                                               |
| ------------------- | ------------------------------------------------------------------ |
| `isLoopNotifier`    | Monitors changes in loop playback state.                           |
| `isMuteNotifier`    | Monitors changes in mute state.                                    |
| `mirrorModeNotifier`| Monitors changes in mirror mode.                                   |
| `rotateModeNotifier`| Monitors changes in rotation angle.                                |
| `scaleModeNotifier` | Monitors changes in rendering fill mode.                           |

### **Quality and Thumbnails**

| Notifier                 | Function Description                                               |
| ------------------------ | ------------------------------------------------------------------ |
| `currentTrackInfoNotifier`| Tracks changes in current video quality information (e.g., SD, HD, UHD) and provides details after switching. |
| `trackInfoListNotifier`  | Provides a list of all available video quality information.        |
| `thumbnailNotifier`      | Monitors thumbnail loading status, ensuring real-time preview when dragging the progress bar. |

### **Subtitle Related**

| Notifier                  | Function Description                                             |
| ------------------------- | ---------------------------------------------------------------- |
| `subtitleNotifier`        | Monitors changes in external subtitle information.               |
| `subtitleTrackIndexNotifier`| Monitors changes in the currently displayed subtitle track index. |
| `isSubtitleVisibleNotifier`| Monitors changes in subtitle display state.                     |

### **Other States**

| Notifier               | Function Description                                           |
| ---------------------- | -------------------------------------------------------------- |
| `videoSizeNotifier`    | Monitors changes in video dimensions.                          |
| `snapFileStateNotifier`| Monitors changes in screenshot file state.                     |
| `downloadStateNotifier`| Monitors changes in download state.                            |

### **Usage Method**

Use `ValueListenableBuilder` to listen for changes in `notifier`s, enabling real-time UI updates or logic execution.

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
    return const SizedBox.shrink();
  },
);
```

## **Appendix: API Documentation Reference**

For more detailed API documentation and usage instructions, please refer to our official documentation published on Pub:

- **Pub Official Source**: [pub.dev API Documentation](https://pub.dev/documentation/aliplayer_widget/latest/)
- **Domestic Mirror Source**: [pub.flutter-io.cn API Documentation](https://pub.flutter-io.cn/documentation/aliplayer_widget/latest/)

In these official documents, you can find detailed descriptions of each interface, parameter descriptions, return value descriptions, and more usage examples.
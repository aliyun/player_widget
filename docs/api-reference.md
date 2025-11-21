# **AliPlayerWidget API 参考**

AliPlayerWidget 提供了丰富的 API 接口，方便开发者直接控制播放器的行为。这些接口通过 `AliPlayerWidgetController` 暴露，支持播放控制、状态查询、数据更新等功能。

## **常用接口**

### **配置与初始化**

| 接口名称    | 功能描述                           |
| ----------- | ---------------------------------- |
| `configure` | 配置播放器数据源并初始化播放器     |
| `prepare`   | 准备播放器（手动调用准备流程）     |
| `destroy`   | 销毁播放器实例，释放资源           |

### **播放控制**

| 接口名称          | 功能描述                               |
| ----------------- | -------------------------------------- |
| `play`            | 开始播放视频                           |
| `pause`           | 暂停播放                               |
| `stop`            | 停止播放并重置播放器                   |
| `seek`            | 跳转到指定的播放位置                   |
| `togglePlayState` | 切换播放状态（播放/暂停）              |
| `replay`          | 重新播放视频（通常用于播放完成后重新开始） |

### **播放属性设置**

| 接口名称                | 功能描述                         |
| ----------------------- | -------------------------------- |
| `setSpeed`              | 设置播放速度                     |
| `setVolume`             | 设置音量                         |
| `setVolumeWithDelta`    | 根据增量调整音量                 |
| `setBrightness`         | 设置屏幕亮度                     |
| `setBrightnessWithDelta`| 根据增量调整屏幕亮度             |
| `setLoop`               | 设置是否循环播放                 |
| `setMute`               | 设置是否静音                     |
| `setMirrorMode`         | 设置镜像模式（如水平镜像、垂直镜像等） |
| `setRotateMode`         | 设置旋转角度（如 90°、180° 等）  |
| `setScaleMode`          | 设置渲染填充模式（如拉伸、裁剪等） |

### **清晰度切换**

| 接口名称      | 功能描述         |
| ------------- | ---------------- |
| `selectTrack` | 切换播放清晰度   |

### **缩略图相关**

| 接口名称                | 功能描述                 |
| ----------------------- | ------------------------ |
| `requestThumbnailBitmap`| 请求指定时间点的缩略图   |

### **其他功能**

| 接口名称          | 功能描述                           |
| ----------------- | ---------------------------------- |
| `clearCaches`     | 清除播放器缓存（包括视频缓存和图片缓存） |
| `getWidgetVersion`| 获取当前 Flutter Widget 的版本号     |

## **事件通知**

`AliPlayerWidgetController` 提供了一系列 `ValueNotifier`，用于实时通知播放器的状态变化和用户操作。

### **播放状态管理**

| Notifier             | 功能描述                                         |
| -------------------- | ------------------------------------------------ |
| `playStateNotifier`  | 用于监听播放状态的变化（如播放、暂停、停止等）。     |
| `playErrorNotifier`  | 监听播放过程中发生的错误信息，提供错误码和错误描述。 |
| `isRenderedNotifier` | 监听播放器是否已经渲染首帧。                     |

### **播放进度管理**

| Notifier                  | 功能描述                                               |
| ------------------------- | ------------------------------------------------------ |
| `currentPositionNotifier` | 实时更新当前播放进度（单位：毫秒）。                       |
| `bufferedPositionNotifier`| 跟踪视频的缓冲进度，帮助用户了解已缓存的内容范围。         |
| `totalDurationNotifier`   | 提供视频的总时长信息，便于计算播放进度百分比或显示总时长。 |

### **音量与亮度控制**

| Notifier            | 功能描述                                                 |
| ------------------- | -------------------------------------------------------- |
| `volumeNotifier`    | 监听音量变化，支持动态调整音量大小（范围通常为 0.0 到 1.0）。 |
| `brightnessNotifier`| 监听屏幕亮度变化，允许用户根据环境光线调整亮度（范围通常为 0.0 到 1.0）。 |
| `speedNotifier`     | 监听播放速度变化。                                       |

### **播放属性状态**

| Notifier            | 功能描述                                                 |
| ------------------- | -------------------------------------------------------- |
| `isLoopNotifier`    | 监听循环播放状态的变化。                                 |
| `isMuteNotifier`    | 监听静音状态的变化。                                     |
| `mirrorModeNotifier`| 监听镜像模式的变化。                                     |
| `rotateModeNotifier`| 监听旋转角度的变化。                                     |
| `scaleModeNotifier` | 监听渲染填充模式的变化。                                 |

### **清晰度与缩略图**

| Notifier                  | 功能描述                                                 |
| ------------------------- | -------------------------------------------------------- |
| `currentTrackInfoNotifier`| 跟踪当前视频清晰度信息的变化（如标清、高清、超清等），并提供切换后的清晰度详情。 |
| `trackInfoListNotifier`   | 提供所有可用的视频清晰度信息列表。                       |
| `thumbnailNotifier`       | 监听缩略图加载状态，确保在拖动进度条时能够实时显示对应的缩略图预览。 |

### **字幕相关**

| Notifier                  | 功能描述                                                 |
| ------------------------- | -------------------------------------------------------- |
| `subtitleNotifier`        | 监听外挂字幕信息的变化。                                 |
| `subtitleTrackIndexNotifier`| 监听当前显示的字幕轨道索引变化。                         |
| `isSubtitleVisibleNotifier`| 监听字幕显示状态的变化。                                 |

### **其他状态**

| Notifier               | 功能描述                                                 |
| ---------------------- | -------------------------------------------------------- |
| `videoSizeNotifier`    | 监听视频尺寸的变化。                                     |
| `snapFileStateNotifier`| 监听截图文件状态的变化。                                 |
| `downloadStateNotifier`| 监听下载状态的变化。                                     |

### **使用方法**

通过 `ValueListenableBuilder` 监听 `notifier` 的变化，可以实时更新 UI 或执行逻辑。

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
    return const SizedBox.shrink();
  },
);
```

## **附录：API 文档参考**

有关更详细的 API 文档和使用说明，请参考我们在 Pub 上发布的官方文档：

- **Pub 官方源**: [pub.dev API Documentation](https://pub.dev/documentation/aliplayer_widget/latest/)
- **国内镜像源**: [pub.flutter-io.cn API Documentation](https://pub.flutter-io.cn/documentation/aliplayer_widget/latest/)

在这些官方文档中，您可以找到每个接口的详细说明、参数说明、返回值说明以及更多的使用示例。
# **AliPlayerWidget 视频源支持**

AliPlayerWidget 提供了灵活的视频源配置方式，支持多种视频源类型，开发者可以根据实际需求选择最适合的视频源类型。

## **1. 支持的视频源类型**

### **1.1 VidAuth 模式（推荐）**

通过视频 ID 和播放凭证进行授权播放，适用于需要更简单授权机制的场景。

```dart
// 示例：使用 VidAuth 创建播放数据
final videoSource = VideoSourceFactory.createVidAuthSource(
  vid: "<your-video-id>",
  playAuth: "<your-play-auth>",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

### **1.2 VidSts 模式**

通过视频 ID(VID) 和阿里云 STS (Security Token Service) 令牌进行播放，提供更高的安全性和访问控制。

```dart
// 示例：使用 VidSts 创建播放数据
final videoSource = VideoSourceFactory.createVidStsSource(
  vid: "<your-video-id>",
  accessKeyId: "<your-access-key-id>",
  accessKeySecret: "<your-access-key-secret>",
  securityToken: "<your-security-token>",
  region: "<your-region>",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

### **1.3 URL 模式**

通过直接提供视频 URL 进行播放，适用于公开访问的视频资源。

```dart
// 示例：使用 URL 创建播放数据
final videoSource = VideoSourceFactory.createUrlSource(
  "<your-video-url>",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

## **2. 使用方法**

在配置播放器时，通过 [AliPlayerWidgetData] 的 [videoSource] 属性设置视频源：

```dart
// 1. 创建播放器视频源
final videoSource = VideoSourceFactory.createVidAuthSource(
  vid: "<your-video-id>",
  playAuth: "<your-play-auth>",
);

// 2. 配置播放器组件数据
final data = AliPlayerWidgetData(
  videoSource: videoSource,
  videoTitle: "<your-video-title>",
);

// 3. 初始化播放器组件控制器
_controller = AliPlayerWidgetController(context);
_controller.configure(data);
```

## **3. 注意事项**

1. 不同的视频源类型适用于不同的业务场景，请根据实际需求选择。
2. VidAuth 和 VidSts 模式提供更高的安全性，适用于需要授权验证的场景。
3. URL 模式适用于公开资源，使用简单但安全性较低。

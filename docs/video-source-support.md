# **AliPlayerWidget 视频源支持**

播放器提供了灵活的视频源配置方式，支持多种视频源类型，开发者可以根据实际需求选择最适合的视频源类型。

## **支持的视频源类型**

### **1. URL 模式**

通过直接提供视频 URL 进行播放，适用于公开访问的视频资源。

```dart
// 示例：使用 URL 创建播放数据
final videoSource = VideoSourceFactory.createUrlSource(
  "https://example.com/video.mp4",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

### **2. VidAuth 模式（推荐）**

通过视频 ID 和播放凭证进行授权播放，适用于需要更简单授权机制的场景。

```dart
// 示例：使用 VidAuth 创建播放数据
final videoSource = VideoSourceFactory.createVidAuthSource(
  vid: "视频ID",
  playAuth: "播放凭证",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

### **3. VidSts 模式**

通过视频 ID(VID) 和阿里云 STS (Security Token Service) 令牌进行播放，提供更高的安全性和访问控制。

```dart
// 示例：使用 VidSts 创建播放数据
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

## **使用方法**

在配置播放器时，通过 [AliPlayerWidgetData] 的 [videoSource] 属性设置视频源：

```dart
// 1. 创建视频源
final videoSource = VideoSourceFactory.createUrlSource(
  "https://example.com/video.mp4",
);

// 2. 创建播放数据
final data = AliPlayerWidgetData(
  videoSource: videoSource,
  coverUrl: "https://example.com/cover.jpg",
  videoTitle: "Sample Video",
);

// 3. 配置播放器
_controller.configure(data);
```

## **注意事项**

1. 不同的视频源类型适用于不同的业务场景，请根据实际需求选择。
2. VidAuth 和 VidSts 模式提供更高的安全性，适用于需要授权验证的场景。
3. URL 模式适用于公开资源，使用简单但安全性较低。
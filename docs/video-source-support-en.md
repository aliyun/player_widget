# **AliPlayerWidget Video Source Support**

AliPlayerWidget provides flexible video source configuration, supporting multiple video source types. Developers can choose the most suitable video source type according to actual needs.

## **1. Supported Video Source Types**

### **1.1 VidAuth Mode (Recommended)**

Plays videos through video ID and playback credentials, suitable for scenarios requiring a simpler authorization mechanism.

```dart
// Example: Create playback data using VidAuth
final videoSource = VideoSourceFactory.createVidAuthSource(
  vid: "<your-video-id>",
  playAuth: "<your-play-auth>",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

### **1.2 VidSts Mode**

Plays videos through video ID (VID) and Alibaba Cloud STS (Security Token Service) token, providing higher security and access control.

```dart
// Example: Create playback data using VidSts
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

### **1.3 URL Mode**

Plays videos by directly providing the video URL, suitable for publicly accessible video resources.

```dart
// Example: Create playback data using URL
final videoSource = VideoSourceFactory.createUrlSource(
  "<your-video-url>",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

## **2. Usage**

When configuring the player, set the video source through the [videoSource] property of [AliPlayerWidgetData]:

```dart
// 1. Create player video source
final videoSource = VideoSourceFactory.createVidAuthSource(
  vid: "<your-video-id>",
  playAuth: "<your-play-auth>",
);

// 2. Configure player component data
final data = AliPlayerWidgetData(
  videoSource: videoSource,
  videoTitle: "<your-video-title>",
);

// 3. Initialize player component controller
_controller = AliPlayerWidgetController(context);
_controller.configure(data);
```

## **3. Notes**

1. Different video source types are suitable for different business scenarios, please choose according to actual needs.
2. VidAuth and VidSts modes provide higher security, suitable for scenarios requiring authorization verification.
3. URL mode is suitable for public resources, simple to use but with lower security.

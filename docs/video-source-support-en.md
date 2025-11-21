# **AliPlayerWidget Video Source Support**

The player provides flexible video source configuration methods, supporting multiple video source types. Developers can choose the most suitable video source type based on their actual requirements.

## **Supported Video Source Types**

### **1. URL Mode**

Play videos by directly providing the video URL, suitable for publicly accessible video resources.

```dart
// Example: Create playback data using a URL
final videoSource = VideoSourceFactory.createUrlSource(
  "https://example.com/video.mp4",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

### **2. VidAuth Mode (Recommended)**

Authorize playback using a Video ID and playback credentials, suitable for scenarios requiring simpler authorization mechanisms.

```dart
// Example: Create playback data using VidAuth
final videoSource = VideoSourceFactory.createVidAuthSource(
  vid: "Video ID",
  playAuth: "Playback Credentials",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

### **3. VidSts Mode**

Play videos using a Video ID (VID) and Alibaba Cloud STS (Security Token Service) token, providing enhanced security and access control.

```dart
// Example: Create playback data using VidSts
final videoSource = VideoSourceFactory.createVidStsSource(
  vid: "Video ID",
  accessKeyId: "Access Key ID",
  accessKeySecret: "Access Key Secret",
  securityToken: "Security Token",
  region: "Region Information",
);
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
```

## **Usage**

When configuring the player, set the video source through the [videoSource] property of [AliPlayerWidgetData]:

```dart
// 1. Create video source
final videoSource = VideoSourceFactory.createUrlSource(
  "https://example.com/video.mp4",
);

// 2. Create playback data
final data = AliPlayerWidgetData(
  videoSource: videoSource,
  coverUrl: "https://example.com/cover.jpg",
  videoTitle: "Sample Video",
);

// 3. Configure the player
_controller.configure(data);
```

## **Notes**

1. Different video source types are suitable for different business scenarios. Please choose according to actual requirements.
2. VidAuth and VidSts modes provide higher security and are suitable for scenarios requiring authorization verification.
3. URL mode is suitable for public resources, easy to use but with lower security.
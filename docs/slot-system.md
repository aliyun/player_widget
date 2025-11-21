# **插槽系统使用指南**

## **概述**

AliPlayerWidget 插槽系统允许开发者灵活自定义播放器界面的各个部分。通过插槽系统，您可以轻松实现多种 UI 风格，满足不同产品和用户需求。就像搭积木一样，您可以自由组合各个界面组件，创建出符合您品牌特色的播放器界面。

## **插槽类型及功能**

系统提供了以下几种插槽类型，覆盖播放器界面的各个方面：

| 插槽类型 | 功能描述 | 默认显示 |
|---------|---------|---------|
| **playerSurface** | 播放器视图插槽，用于显示视频内容（不建议自定义） | 是 |
| **topBar** | 顶部栏插槽，通常包含返回按钮、标题和设置按钮 | 是 |
| **bottomBar** | 底部栏插槽，通常包含播放控制、进度条和全屏按钮 | 是 |
| **playControl** | 播放控制插槽，处理播放器的手势控制 | 是 |
| **coverImage** | 封面图插槽，在视频加载前显示封面图片 | 是（有条件） |
| **playState** | 播放状态插槽，显示播放错误等状态信息 | 是（有条件） |
| **centerDisplay** | 中心显示插槽，在手势操作时显示音量、亮度等信息 | 是（有条件） |
| **seekThumbnail** | seek缩略图插槽，在拖动进度条时显示预览缩略图 | 是（有条件） |
| **subtitle** | 字幕插槽，用于显示视频字幕 | 是（有条件） |
| **settingMenu** | 设置菜单插槽，包含播放器设置选项 | 是（minimal场景除外） |
| **overlays** | 浮层插槽，用于添加自定义覆盖层 | 否 |

> **注意**：`playerSurface` 插槽负责视频内容的渲染显示，修改此插槽可能导致播放器无法正常工作，因此不建议自定义该插槽。

## **使用方法**

### **1. 使用默认界面**

最简单的使用方式是不提供 slotBuilders 参数，播放器将使用默认界面：

```dart
AliPlayerWidget(controller)
```

### **2. 自定义部分插槽**

只自定义特定插槽，其他使用默认界面。例如，只自定义顶部栏：

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.topBar: (context) => MyCustomTopBar(),
  },
)
```

### **3. 完全自定义界面**

您可以自定义所有插槽，创建完全个性化的播放器界面：

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    // 注意：不建议自定义 playerSurface
    SlotType.topBar: (context) => MyCustomTopBar(),
    SlotType.bottomBar: (context) => MyCustomBottomBar(),
    SlotType.playControl: (context) => MyPlayControl(),
    SlotType.coverImage: (context) => MyCoverImage(),
    SlotType.playState: (context) => MyPlayState(),
    SlotType.centerDisplay: (context) => MyCenterDisplay(),
    SlotType.seekThumbnail: (context) => MySeekThumbnail(),
    SlotType.subtitle: (context) => MySubtitle(),
    SlotType.settingMenu: (context) => MySettingMenu(),
    SlotType.overlays: (context) => MyOverlays(),
  },
)
```

### **4. 隐藏特定插槽**

通过将插槽值设置为 null，可以隐藏特定插槽：

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.topBar: null, // 隐藏顶部栏
    SlotType.bottomBar: null, // 隐藏底部栏
    SlotType.centerDisplay: null, // 隐藏中心显示
  },
)
```

### **5. 自定义浮层**

使用浮层插槽添加自定义覆盖层：

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.overlays: (context) => MyCustomOverlays(),
  },
)
```

### **6. 向后兼容**

为保证向后兼容，旧版本使用的 overlays 参数仍然可以工作，但已被标记为废弃，请使用新的插槽系统替代：

```dart
// 旧版本方式（已废弃）
AliPlayerWidget(
  controller,
  overlays: [MyOverlayWidget()],
)

// 新版本方式（推荐）
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.overlays: (context) => MyOverlayWidget(),
  },
)
```

## **插槽系统工作原理**

插槽系统通过以下三级渲染策略工作：

1. **自定义优先**：如果提供了插槽的自定义构建器，则使用自定义构建器
2. **默认备选**：如果没有提供自定义构建器，则使用系统默认构建器
3. **显式隐藏**：如果插槽值为 null，则隐藏该插槽

## **场景适配**

根据不同的播放场景（SceneType），某些插槽的行为会自动适配：

- **vod** (点播场景): 支持所有插槽功能
- **live** (直播场景): 禁用进度拖拽相关插槽功能
- **listPlayer** (列表播放场景): 禁用垂直手势相关插槽功能
- **restricted** (受限播放场景): 禁用时间轴操作相关插槽功能
- **minimal** (最小化播放场景): 仅显示 playerSurface 插槽

## 实践示例

请参考 `example/lib/pages/slot/slot_demo_page.dart` 查看完整的插槽使用示例，其中包括：

- 现代、经典、极简三种 UI 风格的实现
- 如何自定义顶部栏、底部栏和播放控制插槽
- 如何在 Widget 外部通过 Notifier 控制播放器

通过插槽系统，您可以轻松创建满足各种需求的播放器界面。


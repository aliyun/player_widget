# **插槽系统 (Slot System)**

**插槽 (Slot)** 是播放器 UI 的基本组成单元，每个插槽负责界面中的一部分功能，如顶部控制栏、底部进度条等。所有插槽按层级叠加，共同构成完整的播放器界面。

AliPlayerWidget 插槽系统允许开发者灵活自定义播放器界面的各个部分。通过插槽系统，您可以轻松实现多种 UI 风格，满足不同产品和用户需求。就像搭积木一样，您可以自由组合各个界面组件，创建出符合您品牌特色的播放器界面。

---

## **1. 插槽类型及功能**

系统提供了以下几种插槽类型，**按层级从底到顶排列**：

| 插槽类型 | 功能描述 | 默认显示 |
|---------|---------|---------|
| **playerSurface** | 播放器视图插槽，用于显示视频内容（不建议自定义） | 是 |
| **subtitle** | 字幕插槽，用于显示视频字幕 | 是（有条件） |
| **coverImage** | 封面图插槽，在视频加载前显示封面图片 | 是（有条件） |
| **playControl** | 播放控制插槽，处理播放器的手势控制 | 是 |
| **topBar** | 顶部栏插槽，通常包含返回按钮、标题和设置按钮 | 是 |
| **bottomBar** | 底部栏插槽，通常包含播放控制、进度条和全屏按钮 | 是 |
| **seekThumbnail** | Seek 缩略图插槽，在拖动进度条时显示预览缩略图 | 是（有条件） |
| **centerDisplay** | 中心显示插槽，在手势操作时显示音量、亮度等信息 | 是（有条件） |
| **playState** | 播放状态插槽，显示播放错误等状态信息 | 是（有条件） |
| **settingMenu** | 设置菜单插槽，包含播放器设置选项 | 是（minimal 场景除外） |
| **overlays** | 浮层插槽，位于最顶层，用于添加点赞、评论、分享等自定义覆盖内容 | 否 |

> **注意**：`playerSurface` 插槽负责视频内容的渲染显示，修改此插槽可能导致播放器无法正常工作，因此不建议自定义该插槽。

## **2. 使用方法**

### **2.1 使用默认界面**

无需任何配置，播放器将使用内置的默认界面：

```dart
AliPlayerWidget(controller)
```

### **2.2 自定义插槽**

通过 `slotBuilders` 参数，您可以自定义任意插槽。未指定的插槽将继续使用默认界面。

#### **部分自定义**

只替换需要自定义的插槽，其他保持默认：

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.topBar: (context) => MyCustomTopBar(),
  },
)
```

#### **完全自定义**

自定义所有插槽，实现完全个性化的界面：

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

### **2.3 隐藏插槽**

将插槽设置为 `null` 即可隐藏该插槽：

```dart
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.topBar: null,
    SlotType.bottomBar: null,
  },
)
```

### **2.4 细粒度控制**

当您希望**在保留默认插槽 UI 的前提下**，仅隐藏其中的部分元素（如按钮），而不需要完全自定义整个插槽时，可使用 `hiddenSlotElements`：

```dart
AliPlayerWidget(
  controller,
  hiddenSlotElements: const {
    // 隐藏顶部栏中的下载和截图按钮
    SlotType.topBar: {
      TopBarElements.download,
      TopBarElements.snapshot,
    },
    // 禁用播放控制中的双击和垂直滑动手势
    SlotType.playControl: {
      PlayControlElements.doubleTap,
      PlayControlElements.leftVerticalDrag,
      PlayControlElements.rightVerticalDrag,
    },
  },
)
```

> **注意**：`hiddenSlotElements` 仅对默认插槽生效。如果通过 `slotBuilders` 自定义了某个插槽，该插槽的 `hiddenSlotElements` 配置将被忽略。

### **2.5 向后兼容**

旧版本的 `overlays` 参数已废弃，请迁移至新的插槽系统：

```dart
// 旧版本（已废弃）
AliPlayerWidget(
  controller,
  overlays: [MyOverlayWidget()],
)

// 新版本（推荐）
AliPlayerWidget(
  controller,
  slotBuilders: {
    SlotType.overlays: (context) => MyOverlayWidget(),
  },
)
```

## **3. 插槽系统工作原理**

插槽系统通过以下三级渲染策略工作：

1. **自定义优先**：如果提供了插槽的自定义构建器，则使用自定义构建器
2. **默认备选**：如果没有提供自定义构建器，则使用系统默认构建器
3. **显式隐藏**：如果插槽值为 null，则隐藏该插槽

## **4. 场景适配**

根据不同的播放场景（SceneType），某些插槽的行为会自动适配：

- **vod** (点播场景): 支持所有插槽功能
- **live** (直播场景): 禁用进度拖拽相关插槽功能
- **listPlayer** (列表播放场景): 禁用垂直手势相关插槽功能
- **restricted** (受限播放场景): 禁用时间轴操作相关插槽功能
- **minimal** (最小化播放场景): 仅显示 playerSurface 插槽

## **5. 实践示例**

请参考 `example/lib/pages/slot/slot_demo_page.dart` 查看完整的插槽使用示例。

---

通过插槽系统，您可以轻松创建满足各种需求的播放器界面。


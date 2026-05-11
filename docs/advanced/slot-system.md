# **插槽系统 (Slot System)**

**插槽 (Slot)** 是播放器 UI 的基本组成单元，每个插槽负责界面中的一部分功能，如顶部控制栏、底部进度条等。所有插槽按层级叠加，共同构成完整的播放器界面。

AliPlayerWidget 插槽系统允许开发者灵活自定义播放器界面的各个部分。通过插槽系统，您可以轻松实现多种 UI 风格，满足不同产品和用户需求。就像搭积木一样，您可以自由组合各个界面组件，创建出符合您品牌特色的播放器界面。

---

## **1. 插槽类型及功能**

系统提供了以下几种插槽类型，**按层级从底到顶排列**：

| 插槽类型 | 默认层级 | 功能描述 | 默认显示 |
|---------|:-------:|---------|:-------:|
| **playerSurface** | 10 | 播放器视图插槽，用于显示视频内容（不建议自定义） | 是 |
| **subtitle** | 20 | 字幕插槽，用于显示视频字幕 | 是（有条件） |
| **coverImage** | 30 | 封面图插槽，在视频加载前显示封面图片 | 是（有条件） |
| **playControl** | 40 | 播放控制插槽，处理播放器的手势控制 | 是 |
| **topBar** | 50 | 顶部栏插槽，通常包含返回按钮、标题和设置按钮 | 是 |
| **bottomBar** | 60 | 底部栏插槽，通常包含播放控制、进度条和全屏按钮 | 是 |
| **seekThumbnail** | 70 | Seek 缩略图插槽，在拖动进度条时显示预览缩略图 | 是（有条件） |
| **centerDisplay** | 80 | 中心显示插槽，在手势操作时显示音量、亮度等信息 | 是（有条件） |
| **playState** | 90 | 播放状态插槽，显示播放错误等状态信息 | 是（有条件） |
| **settingMenu** | 100 | 设置菜单插槽，包含播放器设置选项 | 是（有条件） |
| **overlays** | 110 | 浮层插槽，位于最顶层，用于添加点赞、评论、分享等自定义覆盖内容 | 否 |

> **默认层级**：数值越小越靠底层。内置插槽间距为 10，为自定义插槽预留了充足的插入空间。

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

#### **SlotWidgetBuilder 类型**

插槽系统当前使用简洁的构建器签名：

```dart
// 当前签名（推荐）
typedef SlotWidgetBuilder = Widget Function(BuildContext context);

// 旧签名（已弃用）
@Deprecated('请改用 SlotWidgetBuilder')
typedef SlotWidgetBuilderWithController = Widget Function(
  BuildContext context,
  AliPlayerWidgetController controller,
);
```

**说明**：

* 当前采用单一共享 Controller 模式，全屏与普通模式共享同一个 Controller 实例，无需通过 builder 参数传递。
* 如需在自定义插槽中访问 Controller，可直接通过外部引用获取。

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

### **2.5 自定义 UI 插入与层级控制**

与传统的浮层（overlays）方案不同，插槽系统允许您在播放器的**任意层级**插入自定义 UI 组件，而不仅仅是最顶层。通过 `defaultOrder` 精确控制渲染顺序，实现如水印、弹幕、广告等组件的精确层级插入：

`SlotType` 是一个可扩展的类，您可以创建自定义插槽类型并通过 `defaultOrder` 控制其层级位置：

```dart
// 创建自定义插槽类型，层级位于 coverImage(30) 和 playControl(40) 之间
const myWatermark = SlotType('watermark', defaultOrder: 35);

AliPlayerWidget(
  controller,
  slotBuilders: {
    myWatermark: (context) => MyWatermarkWidget(),
  },
  // 所有插槽按 defaultOrder 自动排序，无需手动枚举
)
```

> **提示**：系统会自动将所有内置插槽和自定义插槽按 `defaultOrder` 排序。

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


# **SceneType 场景说明**

## **概述**

`sceneType` 用于告知 AliPlayerWidget 在不同业务语境下需要启用哪些 UI、插槽和交互能力。它定义在 `AliPlayerWidgetData.sceneType` 字段中，默认值为 `SceneType.vod`。通过合理选择场景，既可以得到符合业务的交互，也能自动复用内置的插槽裁剪、手势屏蔽和安全限制。

## **配置方式**

```dart
final controller = AliPlayerWidgetController();

controller.configure(
  AliPlayerWidgetData(
    videoSource: videoSource,
    sceneType: SceneType.live, // 根据业务切换播放场景
  ),
);
```

> **提示**：运行时可通过 `isSceneType` / `isNotSceneType`（`lib/utils/scene_util.dart`）快速判断当前场景并执行差异化逻辑。

## **场景能力矩阵**

| 场景 | 典型场景 | UI/手势能力 | 插槽策略 | 适用建议 |
|------|----------|-------------|----------|----------|
| `SceneType.vod` | 常规点播、课程、媒体库 | 支持全部控制（播放、进度拖拽、倍速、手势等） | 所有插槽可用 | 默认首选 |
| `SceneType.live` | 直播、赛事 | 禁用时间轴操作，仅保留刷新、手势调节、设置菜单 | `coverImage`、`seekThumbnail` 不显示 | 用于实时流 |
| `SceneType.listPlayer` | 信息流、短视频瀑布流 | 禁用垂直手势，避免与列表滑动冲突，保留基础控制 | 插槽与点播一致 | 嵌套列表时使用 |
| `SceneType.restricted` | 考试监控、培训学习、防跳播场景 | 禁用进度拖拽、快进/快退、倍速等时间轴能力，其余保留 | `coverImage`、`seekThumbnail` 不显示 | 需要防跳播时启用 |
| `SceneType.minimal` | 背景播放、纯自定义 UI、装饰视频 | 仅保留播放画面；隐藏所有控制与字幕；所有手势关闭 | 仅 `playerSurface` / `overlays` 可见 | 作为画布或定制外层 UI |

## **单场景详解**

### **SceneType.vod**
- **功能**：完整的视频控制、所有手势、全部插槽。
- **典型业务**：点播课程、影视播放、培训视频。
- **注意事项**：作为默认值，无需额外配置即可拥有最完整能力。

### **SceneType.live**
- **功能**：禁止时间轴相关控件（进度条拖拽、seek 缩略图、倍速），但仍保留播放/暂停、刷新、音量/亮度手势、全屏与设置菜单。
- **典型业务**：直播频道、活动直播、监控画面。
- **注意事项**：`SlotType.coverImage` 与 `SlotType.seekThumbnail` 会被自动移除。

### **SceneType.listPlayer**
- **功能**：与点播类似，但移除垂直手势（音量/亮度），避免与父级列表手势冲突。
- **典型业务**：Feed 信息流、短视频列表、卡片播放器。
- **注意事项**：若需要手势交互，可在全屏模式切换到 `SceneType.vod` 再恢复。

### **SceneType.restricted**
- **功能**：严格禁止所有时间轴操作（拖拽、快进、倍速），仅允许顺序播放。
- **典型业务**：考试、培训、受控演示、需防跳播的版权内容。
- **注意事项**：`SlotType.coverImage` 与 `SlotType.seekThumbnail` 自动关闭；可配合自定义插槽展示倒计时或提示文案。

### **SceneType.minimal**
- **功能**：只渲染视频画面，不加载任何 UI 插槽（包含字幕、中心提示、控制栏等），手势与控制能力全部关闭。
- **典型业务**：背景视频、桌面动效、完全自定义外部 UI、画中画内核。
- **注意事项**：如需叠加自定义组件，可使用 `SlotType.overlays` 或在外部包裹自定义 UI。

## **插槽与场景联动**

| 插槽类型 | 自动隐藏的场景 |
|----------|----------------|
| `SlotType.coverImage` | `live`, `restricted`, `minimal` |
| `SlotType.playControl` / `topBar` / `bottomBar` / `centerDisplay` / `settingMenu` / `subtitle` | `minimal` |
| `SlotType.seekThumbnail` | `live`, `restricted`, `minimal` |
| `SlotType.playerSurface` / `playState` / `overlays` | 永远可用 |

若需要在特定场景下显示某些 UI，可自定义 `slotBuilders` 强制渲染，或在业务逻辑中根据 `sceneType` 切换不同的构建器。

## **最佳实践**

- **运行时切换**：可通过重新调用 `controller.configure` 搭配新的 `AliPlayerWidgetData.sceneType`，以支持同一播放器在不同页面间重用。
- **配合状态同步**：当外部 UI 需要感知当前场景时，可将 `sceneType` 保存在状态管理（如 Provider、Riverpod），避免重复查询。
- **测试策略**：重点验证特殊场景（`restricted`, `minimal`）下的插槽是否被正确隐藏，以及 `listPlayer` 中的手势冲突是否消失。

通过合理使用 `sceneType`，可以在不手动写大量条件分支的情况下，统一管控播放器在不同业务场景下的 UI 与交互行为。


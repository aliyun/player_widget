# **自定义配置**

AliPlayerWidget 内置了最佳实践配置，大多数场景无需额外设置即可获得优质体验。当您需要的播放器能力未通过 AliPlayerWidget 的接口直接提供时，可通过以下自定义配置机制，直接调用 `flutter_aliplayer` 库的 API 来实现。

## **1. 前置条件**

使用自定义配置时，需要直接调用 `flutter_aliplayer` 库的原生 API。虽然 `aliplayer_widget` 内部已依赖该库，但建议在您的项目中显式声明依赖，以确保可以正常导入并使用其 API：

```yaml
# pubspec.yaml
dependencies:
  aliplayer_widget: <latest_version>

  # 自定义配置时需显式依赖
  flutter_aliplayer: <latest_version>
```

## **2. 配置层级概览**

AliPlayerWidget 提供两个层级的自定义配置入口，满足不同粒度的需求：

| 层级 | 接口 | 调用时机 | 典型场景 |
|------|------|----------|----------|
| **全局配置** | `AliPlayerWidgetGlobalSetting.setOnGlobalInit` | 全局初始化完成后（仅一次） | setOption、mediaLoader 等全局行为 |
| **实例配置** | `AliPlayerWidgetData.onPlayerConfig` | 每个播放器实例 prepare() 前 | setPlayConfig（缓冲、Referer）、setOption 等实例行为 |

> **说明**：播放器 SDK 本身分为全局配置和实例配置两种类型。AliPlayerWidget 已内置最佳实践配置，但对于未直接透出的原生接口，提供了上述两个回调入口，供开发者自行获取播放器实例并调用。

## **3. 全局配置：setOnGlobalInit**

### **3.1 适用场景**

- 设置全局 Option（如全局日志级别）
- 配置 mediaLoader（自定义媒体加载逻辑）
- 其他需要在所有播放器实例创建前生效的全局行为

### **3.2 使用方式**

在 `main()` 函数中，调用 `AliPlayerWidgetGlobalSetting.setupConfig()` **之前**注册回调：

```dart
import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册全局自定义配置回调（在 setupConfig 之前调用）
  AliPlayerWidgetGlobalSetting.setOnGlobalInit(() {
    // 示例：设置全局 Option
    FlutterAliPlayerGlobalSettings.setOption(
      AliPlayerGlobalSettings.ENABLE_H2_MULTIPLEX, 1,
    );
  });

  // 初始化全局配置（内部会在初始化完成后触发上面注册的回调）
  AliPlayerWidgetGlobalSetting.setupConfig();

  runApp(const MyApp());
}
```

### **3.3 触发时机**

回调在 `setupConfig()` 内部全局初始化完成后触发，仅执行一次。此时底层 SDK 已就绪，可安全调用全局 API。

### **3.4 注意事项**

- `setOnGlobalInit` 应在 `setupConfig()` **之前**调用，否则回调可能不会被触发。
- 全局配置仅执行一次，后续重复调用 `setupConfig()` 不会再次触发。

## **4. 实例配置：onPlayerConfig**

### **4.1 适用场景**

- 自定义缓冲策略（`maxBufferDuration`、`highBufferDuration` 等）
- 设置 Referer 防盗链
- 配置 HTTP Header
- 设置实例级 Option
- 其他 AliPlayerWidget 未直接透出的播放器接口

### **4.2 使用方式**

在构建 `AliPlayerWidgetData` 时，通过 `onPlayerConfig` 参数传入回调：

```dart
final data = AliPlayerWidgetData(
  videoSource: videoSource,
  videoTitle: "视频标题",
  onPlayerConfig: (player) async {
    // 示例 1：自定义缓冲策略和 Referer
    var config = await player.getPlayConfig();
    config.maxBufferDuration = 50000;        // 最大缓冲时长 50s
    config.highBufferDuration = 3000;        // 高水位缓冲 3s
    config.startBufferDuration = 500;        // 起播缓冲 500ms
    config.referer = "https://your-domain.com";  // 设置 Referer 防盗链
    await player.setPlayConfig(config);

    // 示例 2：设置实例级 Option
    player.setOption(FlutterAvpdef.ALLOW_PRE_RENDER, 1);
  },
);

// 配置并播放
controller.configure(data);
```

### **4.3 触发时机**

回调在播放器执行 `prepare()` **之前**触发。此时播放器实例已创建完成，但尚未开始加载和播放，是进行自定义配置的最佳时机。每次调用 `controller.configure(data)` 都会触发。

### **4.4 注意事项**

- 回调支持异步操作（`async/await`），Widget 会等待回调完成后再执行 `prepare()`。
- 回调参数 `player` 是原生 `FlutterAliplayer` 实例，可调用 SDK 的所有原生接口。
- 每次调用 `controller.configure(data)` 都会触发该回调，适合动态配置场景。

## **5. 常见问题**

### Q: 全局配置和实例配置的执行顺序是什么？

全局配置（`setOnGlobalInit`）在应用启动时执行一次；实例配置（`onPlayerConfig`）在每个播放器实例 `prepare()` 前执行。两者互不影响。

### Q: 如果不设置自定义配置会怎样？

AliPlayerWidget 已内置最佳实践配置，不设置任何自定义配置即可正常使用，适合大多数场景。

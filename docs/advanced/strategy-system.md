# **策略系统 (Strategy System)**

**策略 (Strategy)** 是业务逻辑的基本组织单元。每个策略封装一项独立的业务关注点（如首帧耗时统计、卡顿检测、记忆播放等），通过观察播放器状态并处理相关数据来完成其职责。所有策略由 StrategyManager 统一管理生命周期，随播放器创建而启动，随销毁而停止。

AliPlayerWidget 策略系统允许开发者灵活扩展播放器的业务逻辑。通过策略系统，您可以将播放质量监控、业务埋点、用户行为分析等关注点封装为独立策略，像插件一样自由组合，满足不同业务场景的需求。

---

## **1. 内置策略**

系统默认注册以下推荐策略，**开箱即用**：

| 策略名称 | 类名 | 功能描述 | 可选回调 |
|---------|------|---------|--------|
| **首帧统计** | `FirstFrameStrategy` | 统计 prepare→prepared 和 prepare→rendered 耗时 | `onPrepared`、`onFirstFrame` |
| **卡顿检测** | `StutterDetectStrategy` | 协调监听播放/加载状态，统计卡顿次数、时长和卡顿率 | `onStutterDetected` |

> **说明**：内置策略无需任何配置，播放器创建后自动生效。如需获取策略数据，可通过回调参数传入。

## **2. 使用方法**

### **2.1 使用默认策略**

无需任何配置，内置策略自动运行：

```dart
final data = AliPlayerWidgetData(
  videoSource: videoSource,
);
controller.configure(data);
```

### **2.2 替换内置策略**

通过 `register()` 注册同名策略实例，可替换默认的无回调版本，从而获取策略运行数据：

```dart
controller.strategyManager
  ..register(FirstFrameStrategy(
    onPrepared: (cost) {
      print('Prepare 耗时: ${cost.inMilliseconds}ms');
    },
    onFirstFrame: (cost) {
      print('首帧耗时: ${cost.inMilliseconds}ms');
    },
  ))
  ..register(StutterDetectStrategy(
    onStutterDetected: (info) {
      print('卡顿 ${info.stutterCount}次, 卡顿率 ${(info.stutterRate * 100).toStringAsFixed(1)}%');
    },
  ));
```

> **注意**：注册同名策略会自动替换已有实例，无需手动移除。

### **2.3 注册自定义策略**

通过 `register()` 注册新名称的策略实例，可扩展播放器行为：

```dart
controller.strategyManager.register(ResumePlayStrategy(
  onPositionSaved: (position) {
    print('已保存进度: ${position.inSeconds}s');
  },
));
```

> 自定义策略的开发方法请参考下方「自定义策略开发」章节。

### **2.4 管理策略**

通过 `strategyManager` 可在运行时移除策略：

```dart
// 按名称移除策略
controller.strategyManager.unregister('MyCustomStrategy');

// 移除所有策略
controller.strategyManager.clear();
```

## **3. 自定义策略开发**

### **3.1 继承 BasePlayerStrategy**

继承 `BasePlayerStrategy` 即可创建自定义策略，框架自动管理监听器的生命周期：

```dart
class MyCustomStrategy extends BasePlayerStrategy {
  @override
  String get name => 'MyCustomStrategy';

  @override
  void onStart(AliPlayerWidgetController controller) {
    // 通过 listen() 订阅感兴趣的 notifier，框架在 onStop 时自动清理
    listen<int>(controller.playStateNotifier, (state) {
      // 处理播放状态变化
    });

    listen<Duration>(controller.currentPositionNotifier, (position) {
      // 处理播放进度变化
    });
  }

  @override
  void onReset() {
    // 视频切换时重置内部状态（策略保持活跃）
  }
}
```

### **3.2 生命周期方法**

| 方法 | 触发时机 | 职责 |
|------|---------|------|
| `onStart` | 策略启动时 | 订阅状态信号，初始化内部状态 |
| `onStop` | 策略停止时（Controller 销毁） | 释放资源（BasePlayerStrategy 自动清理监听器） |
| `onReset` | 视频源切换时 | 重置内部计数器/时间戳，保持策略活跃 |

### **3.3 回调安全机制**

策略通常通过回调向外部报告数据（如通知 UI 更新）。策略停止时，UI 可能已销毁，因此框架提供两层保护：

| 机制 | 作用范围 | 说明 |
|------|---------|------|
| `listen()` 内置守卫 | Notifier 驱动的回调 | 策略停止后，监听器不再触发 `onChanged` |
| `notify()` 便捷方法 | `onStop()` 中的主动回调 | 安全触发外部回调，停止后自动跳过 |

```dart
class ResumePlayStrategy extends BasePlayerStrategy {
  final void Function(Duration)? onPositionSaved;

  @override
  void onStop() {
    super.onStop();
    _savePosition();
  }

  void _savePosition() {
    // 持久化始终执行（数据安全）
    storage.save(position);

    // 通过 notify() 安全触发外部回调（停止后自动跳过）
    notify(onPositionSaved, position);
  }
}
```

> **设计原则**：持久化（数据安全）与通知（UI 更新）是不同关注点。`onStop()` 中可以执行持久化，但外部通知必须通过 `notify()` 守卫。

## **4. 数据来源与状态信号**

策略本质上是业务逻辑的基本组织单元。既然涉及业务逻辑，就必然涉及数据的获取与处理。策略在 `onStart` 中获得完整的 `controller` 引用，可以通过多种方式获取所需数据。

### **4.1 可观察的状态信号**

策略通过 `listen()` 方法订阅 Controller 上的 ValueNotifier：

| Notifier | 类型 | 说明 |
|----------|------|------|
| `prepareNotifier` | `int` | prepare() 调用事件 |
| `isPreparedNotifier` | `bool` | 数据源准备完成 |
| `isRenderedNotifier` | `bool` | 首帧渲染完成 |
| `playStateNotifier` | `int` | 播放状态变化 |
| `currentPositionNotifier` | `Duration` | 当前播放位置 |
| `totalDurationNotifier` | `Duration` | 视频总时长 |
| `isLoadingStateNotifier` | `bool` | 加载状态 |
| `isDraggingNotifier` | `bool` | 是否正在拖拽进度条 |
| `currentSeekTimeNotifier` | `Duration` | 拖拽过程中的当前 seek 时间 |
| `contentViewTypeNotifier` | `ContentViewType` | 当前中心展示内容类型（音量/亮度/倍速指示器） |
| `settingPanelRequestNotifier` | `int` | 设置面板打开请求计数器 |

> **设计原则**：策略只观察播放器状态，不直接控制播放行为。

### **4.2 其他数据来源**

数据来源不仅限于 ValueNotifier，Controller 上的任何公开 API 都是合法的数据获取途径：

| 来源方式 | 说明 | 示例 |
|---------|------|------|
| **ValueNotifier 监听** | 响应式、推送型，适合状态变化驱动的逻辑 | `listen(controller.playStateNotifier, ...)` |
| **配置数据读取** | 读取视频源、场景类型等配置信息 | `controller.widgetData?.videoSource` |
| **主动查询** | 调用 Controller 异步方法获取实时数据 | `await controller.getCurrentPosition()` |
| **构造函数注入** | 通过策略构造参数传入外部依赖 | `MyStrategy(apiClient: dio)` |

**当所需数据没有对应的 Notifier 时**，可以：

```dart
class MyCustomStrategy extends BasePlayerStrategy {
  late AliPlayerWidgetController _controller;

  @override
  String get name => 'MyCustomStrategy';

  @override
  void onStart(AliPlayerWidgetController controller) {
    _controller = controller;

    // 方式 1：结合已有 Notifier 在回调中主动查询
    listen<int>(controller.playStateNotifier, (state) {
      // 播放状态变化时，主动查询当前位置
      controller.getCurrentPosition().then((pos) {
        // ...处理业务逻辑
      });
    });

    // 方式 2：直接读取配置信息
    final videoSource = controller.widgetData?.videoSource;
    // ...根据视频源类型执行不同逻辑
  }
}
```

> **提示**：Notifier 是首选的数据来源（响应式、自动清理），但策略并不被它限制 —— Controller 上的任何公开 API 都是合法的数据获取途径。

## **5. 策略系统工作原理**

策略系统通过以下机制工作：

1. **自动注册**：StrategyManager 创建时默认注册内置推荐策略
2. **生命周期绑定**：策略随 Controller 的 `configure()` 启动，随 `destroy()` 销毁
3. **异常隔离**：单个策略异常不影响其他策略运行
4. **回调安全**：框架通过 `isActive` 保证策略停止后不触发外部回调

## **6. 实践示例**

请参考 `example/lib/pages/strategy/strategy_demo_page.dart` 查看完整的策略系统使用示例，包括自定义策略（记忆播放）的完整实现。

---

通过策略系统，您可以将各种业务关注点封装为独立策略，灵活组合以满足不同场景的需求。

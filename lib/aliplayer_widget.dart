// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/6
// Brief: Player Widget, used to play videos

part of 'aliplayer_widget_lib.dart';

/// 插槽构建器类型定义
///
/// Slot builder type definition
///
/// [context] 构建上下文
typedef SlotWidgetBuilder = Widget Function(BuildContext context);

/// 返回键回调类型定义
///
/// Return button callback type definition
/// 返回 true 表示已处理返回事件，不再执行默认行为
/// 返回 false 或 null 表示未处理，执行默认行为（Navigator.pop）
typedef OnBackPressedCallback = bool? Function();

/// 一个用于播放视频的 Widget，支持自定义控制器和覆盖层。
///
/// A widget for video playback that supports custom controllers and overlay layers.
class AliPlayerWidget extends StatefulWidget {
  /// 视频播放控制器，用于控制视频的播放、暂停等操作。
  ///
  /// The video player controller used to control playback, pause, etc.
  final AliPlayerWidgetController _controller;

  /// 插槽构建器映射，允许自定义各个插槽的构建方式
  ///
  /// Slot builder map, allowing customization of how each slot is built
  ///
  /// Key 为 [SlotType]，支持内置插槽和自定义插槽：
  /// - 内置插槽：使用预定义常量（如 `SlotType.topBar`、`SlotType.bottomBar`）
  /// - 自定义插槽：通过 `SlotType('name', defaultOrder: N)` 创建，
  ///   `defaultOrder` 决定插槽在 Stack 中的层级位置
  ///
  /// Key is [SlotType], supporting both built-in and custom slots:
  /// - Built-in: Use predefined constants (e.g. `SlotType.topBar`, `SlotType.bottomBar`)
  /// - Custom: Create via `SlotType('name', defaultOrder: N)`,
  ///   where `defaultOrder` determines the slot's z-level in the Stack
  ///
  /// Value 为 [SlotWidgetBuilder] 构建器：
  /// `Widget Function(BuildContext context)`
  ///
  /// 对于内置插槽，支持三种用法：
  /// 1. 不提供 key：使用默认实现
  /// 2. key 对应非 null 构建器：使用自定义构建器完全替换该插槽
  /// 3. key 对应 null：禁用该插槽（返回 SizedBox.shrink）
  ///
  /// 示例 / Example:
  /// ```dart
  /// // 定义自定义插槽，order=35 自动落在 coverImage(30) 和 playControl(40) 之间
  /// const watermark = SlotType('watermark', defaultOrder: 35);
  ///
  /// slotBuilders: {
  ///   // 替换内置插槽
  ///   SlotType.topBar: (ctx) => MyCustomTopBar(),
  ///   // 注册自定义插槽（按 defaultOrder 自动排序）
  ///   watermark: (ctx) => WatermarkWidget(),
  /// }
  /// ```
  final Map<SlotType, SlotWidgetBuilder?> slotBuilders;

  /// 控制默认插槽中单个 UI 元素的显示与隐藏。
  ///
  /// 用于在不替换整个插槽的情况下，对插槽内部元素进行细粒度控制。
  ///
  /// Controls the visibility of individual UI elements within default slots.
  ///
  /// Allows fine-grained control over elements inside a slot without
  /// replacing the entire slot widget.
  ///
  /// 与 [slotBuilders] 不同，后者会完全替换整个插槽（例如整个顶部栏），
  /// [hiddenSlotElements] 仅对默认实现中的部分元素进行隐藏。
  ///
  /// Unlike [slotBuilders], which replaces an entire slot (e.g. the top bar),
  /// [hiddenSlotElements] only hides selected elements while preserving
  /// the default implementation.
  ///
  /// 在保留默认 UI 结构（如顶部栏、底部栏、设置面板等）的前提下，
  /// 可以显式排除某些可选元素（如下载按钮、截图按钮等）。
  ///
  /// This makes it possible to keep the default UI structure (such as the
  /// top bar, bottom bar, or settings panel) while excluding specific
  /// optional elements (e.g. download or snapshot buttons).
  ///
  /// 注意：如果某个 [SlotType] 已通过 [slotBuilders] 自定义，
  /// 则该插槽对应的 [hiddenSlotElements] 配置不会生效，
  /// 因为该插槽已完全由自定义组件接管。
  ///
  /// If a [SlotType] is overridden via [slotBuilders], the corresponding
  /// configuration in [hiddenSlotElements] does not take effect, since
  /// the slot is fully controlled by the custom implementation.
  ///
  /// Key 为插槽类型 [SlotType]，
  /// Value 为需要隐藏的元素 key 集合。
  ///
  /// The map key is a [SlotType], and the value is the set of element
  /// keys to hide.
  ///
  /// 元素 key 由常量类定义，例如：
  /// [TopBarElements]、[BottomBarElements] 等。
  ///
  /// Element keys are defined by constant classes such as
  /// [TopBarElements] and [BottomBarElements].
  ///
  /// 示例：
  ///
  /// Example:
  /// ```dart
  /// hiddenSlotElements: {
  ///   SlotType.topBar: {
  ///     TopBarElements.download,
  ///     TopBarElements.snapshot,
  ///   },
  ///   SlotType.bottomBar: {
  ///     BottomBarElements.fullscreen,
  ///   },
  /// }
  /// ```
  final Map<SlotType, Set<String>> hiddenSlotElements;

  /// 返回按钮点击回调。当用户按下返回键时调用。
  /// 如果返回 true，表示已处理返回事件，不再执行默认行为。
  /// 如果返回 false 或 null，且当前不是全屏状态，将执行默认行为（Navigator.pop）。
  ///
  /// Back button press callback. Called when the user presses the back button.
  /// Returns true to indicate the back event was handled and no default action is needed.
  /// Returns false or null to allow default behavior (Navigator.pop) if not in fullscreen mode.
  final OnBackPressedCallback? onBackPressed;

  /// UI 资源路径，用于自定义皮肤。
  ///
  /// UI assets path for customizing skins.
  ///
  /// - 默认值：[PlayerAssetsScope.defaultAssetsPath]（包内资源）
  /// - 自定义：客户应用资源路径，如 `assets/player_icons`
  ///
  /// 自定义皮肤步骤：
  /// 1. 在应用目录创建资源文件夹，如 `assets/player_icons/`
  /// 2. 在应用 `pubspec.yaml` 中注册：`- assets/player_icons/`
  /// 3. 传入此参数：`assetsPath: 'assets/player_icons'`
  final String assetsPath;

  /// 构造函数，用于创建 [AliPlayerWidget] 实例。
  ///
  /// Constructor to create an instance of [AliPlayerWidget].
  ///
  /// 参数：
  /// - [_controller]：视频播放控制器，必须提供，用于管理视频播放逻辑。
  /// - [key]：可选参数，用于标识 Widget 的唯一性。
  /// - [slotBuilders]：可选参数，默认为空映射，用于定义各个插槽的自定义构建器。
  /// - [hiddenSlotElements]：可选参数，默认为空映射，用于隐藏插槽内单个 UI 元素。
  /// - [onBackPressed]：可选参数，返回按钮点击回调，用于自定义返回行为。
  /// - [assetsPath]：UI 资源路径，可选，默认使用包内资源。
  ///
  /// Parameters:
  /// - _controller: The video player controller, required to manage video playback logic.
  /// - key: Optional parameter used to identify the uniqueness of the widget.
  /// - slotBuilders: Optional parameter, defaults to empty map, used to define custom builders for each slot.
  /// - hiddenSlotElements: Optional parameter, defaults to empty map, used to hide individual UI elements within slots.
  /// - onBackPressed: Optional parameter, back button press callback, used to customize back behavior.
  /// - assetsPath: UI assets path, optional, defaults to package internal resources.
  const AliPlayerWidget(
    this._controller, {
    super.key,
    this.slotBuilders = const {},
    this.hiddenSlotElements = const {},
    this.onBackPressed,
    this.assetsPath = PlayerAssetsScope.defaultAssetsPath,
  });

  @override
  State<StatefulWidget> createState() => AliPlayerWidgetState();
}

/// 播放器组件状态
///
/// Player Widget State
class AliPlayerWidgetState extends State<AliPlayerWidget>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  /// 播放组件控制器
  late AliPlayerWidgetController _playController;

  /// 本实例绑定的 context provider 引用
  late final BuildContext? Function() _contextProvider;

  /// 共享动画控制器
  late SharedAnimationManager _animationManager;

  /// 当前播放场景类型
  ///
  /// 从控制器的 [sceneTypeNotifier] 实时读取，避免在 initState 中缓存
  /// 导致异步 configure 后场景类型无法更新的问题。
  SceneType get _sceneType => _playController.sceneTypeNotifier.value;

  /// 缓存的插槽渲染顺序，在 initState 计算，slotBuilders 变化时刷新
  late List<SlotType> _resolvedSlotOrder;

  /// 当前是否处于全屏状态（用于防止重复 push）
  bool _isFullScreen = false;

  /// 本实例是否位于全屏路由内部（在 initState 依据 isFullScreenNotifier 捕获）
  ///
  /// 用于设置面板请求的身份匹配：全屏激活时仅全屏实例响应，竖屏激活时仅竖屏
  /// 实例响应。与 [_isFullScreen]（竖屏实例是否已 push 全屏路由）语义不同，
  /// 不可混用——竖屏实例在 push 全屏期间 [_isFullScreen] 为 true 但仍位于
  /// 全屏路由之外。
  bool _isInsideFullScreenRoute = false;

  /// 设置面板是否正在展示（防重入保护，避免快速多次点击叠加面板）
  bool _isSettingPanelShowing = false;

  /// 是否注册了全屏监听器（全屏上下文中的实例不注册，防止重复 push）
  bool _hasFullScreenListener = false;

  /// 构建播放器视图
  ///
  /// Builds the main player view.
  @override
  Widget build(BuildContext context) {
    // 监听语言变化，确保 UI 响应系统语言切换
    return ValueListenableBuilder<Locale>(
      valueListenable: PlayerI18n.localeNotifier,
      builder: (context, locale, _) {
        return PlayerAssetsScope(
          assetsPath: widget.assetsPath,
          child: PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              if (didPop) return; // 如果已经处理了返回操作，则直接返回
              _handleBackPress();
            },
            child: _buildContentBody(),
          ),
        );
      },
    );
  }

  /// 构建主体内容
  Widget _buildContentBody() {
    // 监听 场景类别、视频大小、全屏状态
    Listenable listenable = Listenable.merge([
      _playController.videoSizeNotifier,
      _playController.sceneTypeNotifier,
      _playController.isFullScreenNotifier,
    ]);

    // 根据视频尺寸计算渲染尺寸，同时监听场景类型变化以刷新场景相关 UI
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, __) {
        final videoSize = _playController.videoSizeNotifier.value;
        // 如果视频尺寸为空，则不渲染
        if (videoSize == Size.zero) {
          return const SizedBox.shrink();
        }

        // 调用工具类计算渲染尺寸
        Size playerViewSize = ScreenUtil.calculateRenderSize(
          context,
          videoSize: videoSize,
          isFullScreenMode: _playController.isFullScreenNotifier.value,
        );

        logi("[build]: videoSize: $videoSize, playerViewSize: $playerViewSize");

        final double width = playerViewSize.width;
        final double height = playerViewSize.height;

        return ConstrainedBox(
          constraints: BoxConstraints.tight(playerViewSize),
          child: Stack(
            children: _buildAllSlots(width, height),
          ),
        );
      },
    );
  }

  /// 构建所有插槽组件
  ///
  /// Builds all slot widgets
  List<Widget> _buildAllSlots(double width, double height) {
    final slots = <Widget>[];
    final sortedSlots = _resolvedSlotOrder;

    // 按顺序构建插槽
    for (final entry in sortedSlots) {
      // overlays 插槽可返回多个 Widget，单独处理
      if (entry == SlotType.overlays) {
        slots.addAll(
          SlotManager.buildOverlaysSlot(
            widget: widget,
            context: context,
            defaultBuilder: (context) => const SizedBox.shrink(),
          ),
        );
        continue;
      }

      // 内置插槽：检查场景可见性 + 自定义构建器
      final defaultBuilder = _slotBuilders[entry];
      if (defaultBuilder != null) {
        // 内置插槽
        if (_shouldShowSlot(entry)) {
          final content = _buildSlot(
            entry,
            builder: (context) => defaultBuilder(width, height),
          );
          slots.add(content);
        }
      } else {
        // 自定义插槽：直接调用构建器
        final builder = widget.slotBuilders[entry];
        if (builder != null) {
          slots.add(builder(context));
        }
      }
    }

    return slots;
  }

  /// 解析插槽渲染顺序
  ///
  /// 将内置插槽与自定义插槽合并，按 defaultOrder 自动排序。
  List<SlotType> _resolveSlotOrder() {
    // 收集自定义插槽（不在内置列表中的 slotBuilders key）
    final customSlots = widget.slotBuilders.keys
        .where((slot) => !SlotType.builtInSlots.contains(slot))
        .toList();

    if (customSlots.isEmpty) {
      return SlotType.builtInSlots;
    }

    // 合并内置 + 自定义，按 defaultOrder 排序
    final allSlots = [...SlotType.builtInSlots, ...customSlots];
    allSlots.sort((a, b) => a.defaultOrder.compareTo(b.defaultOrder));
    return allSlots;
  }

  /// 插槽构建依赖上下文。
  /// Slot build dependency context.
  late SlotBuildContext _slotBuildContext;

  /// 内置插槽构建器映射（由 [DefaultSlotFactory] 创建）。
  ///
  /// Built-in slot content builder map (created by [DefaultSlotFactory]).
  late Map<SlotType, SlotBuilder> _slotBuilders;

  /// 构建插槽或默认组件
  ///
  /// Build slot widget or default widget
  Widget _buildSlot(
    SlotType slotType, {
    required Widget Function(BuildContext context) builder,
  }) {
    return SlotManager.buildSlot(
      widget: widget,
      slotType: slotType,
      context: context,
      defaultBuilder: builder,
    );
  }

  /// 检查插槽是否应该显示
  bool _shouldShowSlot(SlotType slotType) {
    final config = SlotConstants.slotConfigs[slotType];
    if (config == null) return true;

    // 检查是否在排除场景中
    if (config.excludedScenes.contains(_sceneType)) {
      return false;
    }

    // 检查额外条件
    if (config.additionalCondition != null) {
      return config.additionalCondition!();
    }

    return true;
  }

  /// 创建插槽构建依赖上下文。
  /// Creates the slot build dependency context.
  ///
  /// 将 State 内部字段和回调打包为 [SlotBuildContext]，
  /// 供插槽构建函数通过显式参数访问。
  ///
  /// Bundles State-internal fields and callbacks into a [SlotBuildContext]
  /// so slot builder functions access dependencies via an explicit parameter.
  SlotBuildContext _createSlotBuildContext() {
    return SlotBuildContext(
      controller: _playController,
      animationManager: _animationManager,
      hiddenSlotElements: widget.hiddenSlotElements,
      onBackPress: () => _handleBackPress(),
    );
  }

  /// 处理设置面板请求
  ///
  /// 监听 [settingPanelRequestNotifier] 计数器变化时触发弹窗。
  void _handleSettingPanelRequest() {
    if (!mounted) return;

    // 仅当本实例的身份（竖屏/全屏）与当前全屏状态匹配时才响应：
    // 全屏激活时仅全屏路由内的实例响应，竖屏时仅竖屏实例响应。
    if (_playController.isFullScreenNotifier.value !=
        _isInsideFullScreenRoute) {
      return;
    }

    if (_isSettingPanelShowing) return;
    _isSettingPanelShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isSettingPanelShowing = false;
        return;
      }

      SettingPanelManager.showSettingPanel(
        context: context,
        controller: _playController,
        sceneType: _sceneType,
        hiddenSlotElements: widget.hiddenSlotElements,
      ).whenComplete(() => _isSettingPanelShowing = false);
    });
  }

  /// 返回事件处理
  ///
  /// 涉及 Navigator、widget.onBackPressed 和全屏状态的三重交互，
  /// 无法在单一插槽中独立实现，因此保留在 State 中。
  bool _handleBackPress() {
    // 如果当前是全屏模式，先退出全屏
    if (_playController.isFullScreenNotifier.value) {
      _playController.exitFullScreen();
      return false; // 已处理返回事件（退出全屏），不执行默认行为
    }

    // 调用用户自定义的返回回调
    final onBackPressed = widget.onBackPressed;
    if (onBackPressed != null) {
      final handled = onBackPressed();
      if (handled == true) {
        return false; // 用户已处理，不执行默认行为
      }
    }

    // 执行默认的返回操作
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    return true;
  }

  /// 初始化状态
  /// StatefulWidget 的状态类中第一个被调用的方法，用于初始化状态，可以执行一些一次性的初始化工作
  ///
  /// Called when the state is first created. Used for one-time initialization.
  @override
  void initState() {
    super.initState();

    logi("[lifecycle] initState");

    /// 获取播放控制器
    _playController = widget._controller;

    /// 绑定 context provider
    _contextProvider = () => context;
    _playController._bindContext(_contextProvider);

    /// 捕获本实例身份：initState 时若已处于全屏，则本实例位于全屏路由内部
    _isInsideFullScreenRoute = _playController.isFullScreenNotifier.value;

    /// 初始化共享动画管理器
    _animationManager = SharedAnimationManager(this);

    /// 缓存插槽渲染顺序（与场景类型无关）
    _resolvedSlotOrder = _resolveSlotOrder();

    /// 创建插槽构建依赖上下文与构建器映射
    _slotBuildContext = _createSlotBuildContext();

    /// 创建默认插槽构建器映射
    _slotBuilders = DefaultSlotFactory.createDefaultBuilders(_slotBuildContext);

    /// 添加观察者
    WidgetsBinding.instance.addObserver(this);

    /// 仅在非全屏上下文中注册全屏监听，防止全屏路由中的 AliPlayerWidget 再次 push
    if (!_playController.isFullScreenNotifier.value) {
      _playController.isFullScreenNotifier.addListener(_fullScreenListener);
      _hasFullScreenListener = true;
    }

    /// 监听设置面板请求
    /// 仅在未自定义 settingMenu 时监听，否则由用户的自定义插槽处理。
    /// 每个 State 实例（竖屏/全屏）各自注册，
    /// 由 [_handleSettingPanelRequest] 内的全屏身份匹配守卫决定谁响应。
    if (!widget.slotBuilders.containsKey(SlotType.settingMenu)) {
      _playController.settingPanelRequestNotifier
          .addListener(_handleSettingPanelRequest);
    }
  }

  /// 全屏状态监听器
  void _fullScreenListener() {
    if (_playController.isFullScreenNotifier.value && !_isFullScreen) {
      _pushFullScreenWidget();
    } else if (!_playController.isFullScreenNotifier.value && _isFullScreen) {
      // 退出全屏：由 listener 统一 pop 全屏路由
      // 使用 rootNavigator 与 _pushFullScreenWidget 中的 push 对应
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// 推送全屏 Widget 路由
  Future<void> _pushFullScreenWidget() async {
    _isFullScreen = true;

    // 在 push route 之前触发方向切换（fire-and-forget）
    // 让旋转在 route 过渡动画期间并行生效
    FullScreenUtil.enterFullScreen();

    final route = PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return FullScreenWidget(
          controller: _playController,
          child: AliPlayerWidget(
            _playController,
            slotBuilders: widget.slotBuilders,
            hiddenSlotElements: widget.hiddenSlotElements,
            assetsPath: widget.assetsPath,
          ),
        );
      },
    );

    await Navigator.of(context, rootNavigator: true).push(route);

    // pop 返回后，恢复屏幕方向和系统 UI
    FullScreenUtil.exitFullScreen();
    _isFullScreen = false;

    // 全屏 dispose 会解绑 contextProvider，需重新绑定竖屏 context
    if (mounted) {
      _playController._bindContext(_contextProvider);
    }

    // Note keria:
    // 坑点：由于 Flutter SDK 内部实现限制，需重新绑定原生播放器到端屏的 AliPlayerView
    // 全屏期间，全屏的 AliPlayerView 调用了 _setPlayerView(fullscreenViewId)，覆盖了端屏的绑定
    // 全屏 pop 后，全屏的 PlatformView 被销毁，需要将原生播放器重新指向端屏仍然存活的 PlatformView
    final portraitViewId = _playController.portraitViewId;
    if (mounted && portraitViewId != null) {
      _playController._setPlayerView(portraitViewId);
    }
  }

  /// 清理资源
  /// 在 StatefulWidget 被从树中移除并销毁时调用的，这个方法用于清理资源。
  ///
  /// Called when the widget is removed from the tree permanently. Used to release resources.
  @override
  void dispose() {
    logi("[lifecycle] dispose");

    // 解绑 context provider（仅解绑自己绑定的）
    _playController._unbindContext(_contextProvider);

    // 移除全屏状态监听（仅在注册过时才移除）
    if (_hasFullScreenListener) {
      _playController.isFullScreenNotifier.removeListener(_fullScreenListener);
    }

    // 安全移除设置面板请求监听（即使未注册也不会报错）
    _playController.settingPanelRequestNotifier
        .removeListener(_handleSettingPanelRequest);

    // 销毁共享动画管理器
    _animationManager.dispose();

    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// 状态更新回调
  /// 当 Widget 的状态被更新时，该方法被调用。
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    logi("[lifecycle] didUpdateWidget");

    // 检测控制器是否发生变化
    final controllerChanged = widget._controller != oldWidget._controller;
    if (controllerChanged) {
      final oldController = _playController;

      // 从旧控制器解绑监听器和 context
      oldController._unbindContext(_contextProvider);
      if (_hasFullScreenListener) {
        oldController.isFullScreenNotifier.removeListener(_fullScreenListener);
        _hasFullScreenListener = false;
      }
      oldController.settingPanelRequestNotifier
          .removeListener(_handleSettingPanelRequest);

      // 切换到新控制器
      _playController = widget._controller;

      // 对新控制器绑定 context 和监听器
      _playController._bindContext(_contextProvider);
      if (!_playController.isFullScreenNotifier.value) {
        _playController.isFullScreenNotifier.addListener(_fullScreenListener);
        _hasFullScreenListener = true;
      }
      if (!widget.slotBuilders.containsKey(SlotType.settingMenu)) {
        _playController.settingPanelRequestNotifier
            .addListener(_handleSettingPanelRequest);
      }
    }

    // slotBuilders 变化时刷新插槽顺序缓存
    if (widget.slotBuilders != oldWidget.slotBuilders) {
      _resolvedSlotOrder = _resolveSlotOrder();
    }

    // 控制器或插槽相关 Widget 参数变化时重建上下文与构建器映射
    // 控制器变化时必须重建，否则插槽仍引用旧控制器的 Notifier
    if (controllerChanged ||
        widget.hiddenSlotElements != oldWidget.hiddenSlotElements) {
      _slotBuildContext = _createSlotBuildContext();
      _slotBuilders =
          DefaultSlotFactory.createDefaultBuilders(_slotBuildContext);
    }
  }

  /// 窗口尺寸变化回调
  /// 当窗口尺寸变化时被调用，通常是旋转设备或者是窗口大小调整时。
  ///
  /// Called when the window size changes (e.g., device rotation or resizing).
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    loge("Window metrics changed");
  }

  /// 主题模式变化回调
  /// 当系统的主题模式（亮/暗模式）发生变化时调用。
  ///
  /// Called when the system theme mode changes (light/dark mode).
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    var widgetsBinding = WidgetsBinding.instance;
    final brightness = widgetsBinding.platformDispatcher.platformBrightness;
    final themeMode = (brightness == Brightness.light ? 'Light' : 'Dark');
    loge("Theme mode changed to $themeMode");
  }
}

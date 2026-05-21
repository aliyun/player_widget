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

/// 插槽构建器类型定义（带控制器，已废弃）
///
/// Slot builder type definition with controller (deprecated)
///
/// **已废弃**: 全屏模式已升级为单 Controller 共享，controller 参数不再有信息增益，
/// 请使用 [SlotWidgetBuilder] 替代。
///
/// **Deprecated**: Since fullscreen now shares a single controller,
/// the controller parameter is no longer needed. Use [SlotWidgetBuilder] instead.
@Deprecated('Use SlotWidgetBuilder instead. '
    'Since fullscreen now shares a single controller, '
    'the controller parameter is no longer needed.')
typedef SlotWidgetBuilderWithController = Widget Function(
  BuildContext context,
  AliPlayerWidgetController controller,
);

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
    with WidgetsBindingObserver, TickerProviderStateMixin {
  /// 播放组件控制器
  late AliPlayerWidgetController _playController;

  /// 本实例绑定的 context provider 引用
  late final BuildContext? Function() _contextProvider;

  /// 共享动画控制器
  late SharedAnimationManager _animationManager;

  /// 当前播放场景类型
  late SceneType _sceneType;

  /// 缓存的插槽渲染顺序，在 initState 计算，slotBuilders 变化时刷新
  late List<SlotType> _resolvedSlotOrder;

  /// 当前是否处于全屏状态（用于防止重复 push）
  bool _isFullScreen = false;

  /// 当前竖屏 AliPlayerView 的 viewId，用于全屏返回后重新绑定原生渲染面
  int? _currentViewId;

  /// 是否注册了全屏监听器（全屏上下文中的实例不注册，防止重复 push）
  bool _hasFullScreenListener = false;

  /// 播放状态显示视图的内容类型，默认为 none 不显示
  final SafeValueNotifier<ContentViewType> _contentViewTypeNotifier =
      SafeValueNotifier(ContentViewType.none);

  /// 是否正在拖动进度条
  final SafeValueNotifier<bool> _isDraggingNotifier = SafeValueNotifier(false);

  /// 设置面板显示请求（内部状态）
  ///
  /// 点击设置按钮时变为 true，弹窗关闭后重置为 false。
  final SafeValueNotifier<bool> _settingsPanelRequestNotifier =
      SafeValueNotifier(false);

  /// 上一次设置面板请求的值，用于边缘触发检测
  bool _previousSettingsPanelRequestValue = false;

  /// 拖拽开始的位置
  Duration? _dragStartPosition;

  /// 当前拖动进度条的时间
  final SafeValueNotifier<Duration> _currentSeekTimeNotifier =
      SafeValueNotifier(Duration.zero);

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
    // 根据视频尺寸计算渲染尺寸
    return ValueListenableBuilder(
      valueListenable: _playController.videoSizeNotifier,
      builder: (context, videoSize, __) {
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
        slots.addAll(SlotManager.buildOverlaysSlot(
          widget: widget,
          context: context,
          defaultBuilder: (context) => const SizedBox.shrink(),
        ));
        continue;
      }

      // 内置插槽：检查场景可见性 + 自定义构建器
      final defaultBuilder = _slotContentBuilders[entry.key];
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

  /// 内置插槽构建器映射（替代 switch 语句）
  ///
  /// Built-in slot content builder map (replaces switch statement)
  late final Map<String, Widget Function(double width, double height)>
      _slotContentBuilders = {
    SlotType.playerSurface.key: (w, h) => _buildPlaySurfaceView(w, h),
    SlotType.coverImage.key: (w, h) => _buildPlayCoverView(w, h),
    SlotType.playControl.key: (w, h) => _buildPlayControlView(),
    SlotType.topBar.key: (w, h) => _buildTopBarWidget(),
    SlotType.bottomBar.key: (w, h) => _buildBottomBarWidget(),
    SlotType.seekThumbnail.key: (w, h) => _buildSeekThumbnailWidget(),
    SlotType.centerDisplay.key: (w, h) => _buildCenterDisplayWidget(),
    SlotType.playState.key: (w, h) => _buildPlayStateView(),
    SlotType.settingMenu.key: (w, h) => _buildSettingsPanelSlot(),
    SlotType.subtitle.key: (w, h) => _buildSubtitleWidget(),
  };

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

  /// 构建播放器视图
  ///
  /// build player view
  Widget _buildPlaySurfaceView(double width, double height) {
    return AliPlayerView(
      onCreated: (int viewId) {
        _currentViewId = viewId;
        _playController._setPlayerView(viewId);
      },
      x: 0,
      y: 0,
      width: width,
      height: height,
      aliPlayerViewType: (_playController._widgetData?.androidViewType ??
              AndroidViewType.defaultValue)
          .toPlayerViewType(),
    );
  }

  /// 构建封面视图
  ///
  /// build cover view
  Widget _buildPlayCoverView(double width, double height) {
    // 获取封面图片的 URL
    final coverUrl = _playController._widgetData?.coverUrl;
    // 如果没有封面图片，则不显示
    if (coverUrl == null || coverUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    // 监听播放器是否渲染完成，如果没有渲染完成，则显示封面图片
    return ValueListenableBuilder(
      valueListenable: _playController.isRenderedNotifier,
      builder: (context, isRendered, __) {
        // 如果播放器已经渲染完成，则不显示封面图片
        if (isRendered) {
          return const SizedBox.shrink();
        }

        return AliPlayerCoverImageWidget(
          imageUrl: coverUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  /// 构建播放控制视图
  Widget _buildPlayControlView() {
    // 双击控制（场景限制）
    bool enableDoubleTap = isNotSceneType(_sceneType, [
      SceneType.live,
    ]);
    // 长按控制（场景限制）
    bool enableLongPress = isNotSceneType(_sceneType, [
      SceneType.live,
      SceneType.restricted,
    ]);
    // 水平拖动控制（场景限制）
    bool enableDrag = isNotSceneType(_sceneType, [
      SceneType.live,
      SceneType.restricted,
    ]);
    // 竖向手势控制（场景限制）
    bool enableVerticalGestures = isNotSceneType(_sceneType, [
      SceneType.listPlayer,
    ]);
    return AliPlayerPlayControlWidget(
      autoHide: true,
      onVisibilityChanged: (bool isVisible) {
        _togglePlayControlVisibility(forceHide: !isVisible);
      },
      onDoubleTap: enableDoubleTap ? _onPlayerViewDoubleTap : null,
      onLongPressStart: enableLongPress ? _onPlayerViewLongPress : null,
      onLongPressEnd: enableLongPress ? _onPlayerViewLongPressEnd : null,
      onHorizontalDragUpdate:
          enableDrag ? _onPlayerViewHorizontalDragUpdate : null,
      onHorizontalDragEnd: enableDrag ? _onPlayerViewHorizontalDragEnd : null,
      onLeftVerticalDragUpdate:
          enableVerticalGestures ? _onPlayerViewLeftVerticalDragUpdate : null,
      onLeftVerticalDragEnd:
          enableVerticalGestures ? _onPlayerViewLeftVerticalDragEnd : null,
      onRightVerticalDragUpdate:
          enableVerticalGestures ? _onPlayerViewRightVerticalDragUpdate : null,
      onRightVerticalDragEnd:
          enableVerticalGestures ? _onPlayerViewRightVerticalDragEnd : null,
    );
  }

  /// 切换播放控制视图的可见性
  void _togglePlayControlVisibility({bool forceHide = false}) {
    if (forceHide) {
      // 强制隐藏时，如果正在拖拽则不执行
      if (_isDraggingNotifier.value) {
        return;
      }
      _animationManager.hide();
    } else {
      // 切换显示/隐藏
      if (_animationManager.isVisible) {
        _animationManager.hide();
      } else {
        _animationManager.show();
      }
    }
  }

  /// 构建顶部栏控件
  Widget _buildTopBarWidget() {
    // 启用下载功能
    bool enableDownloadPress = _isDownloadEnable();

    // 检查是否有自定义 settingMenu slotBuilder
    final hasCustomSettingMenu = widget.slotBuilders.containsKey(SlotType.settingMenu);

    Listenable listenable = Listenable.merge([
      _playController.downloadStateNotifier,
    ]);
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        final downloadState = _playController.downloadStateNotifier.value;
        return AliPlayerTopBarWidget(
          animationManager: _animationManager,
          title: _playController._widgetData?.videoTitle ?? "",
          onBackPressed: _handleBackPress,
          onSettingsPressed: () {
            // 统一通过 notifier 触发，slot 系统负责处理
            if (hasCustomSettingMenu) {
              // 自定义实现：通知用户监听的 notifier
              _playController.settingsPanelRequestNotifier.value = true;
            } else {
              // 默认实现：通知内部 notifier，由 _buildSettingsPanelSlot 处理
              _settingsPanelRequestNotifier.value = true;
            }
          },
          isDownload: downloadState is DownloadCompletedState,
          onDownloadPressed: enableDownloadPress ? _onDownloadPressed : null,
          onSnapshotPressed: _onSnapshotPressed,
          onPIPPressed: null, // TODO: 暂不支持
        );
      },
    );
  }

  /// 构建设置面板插槽
  ///
  /// 设置面板的显示由边缘触发监听器 [_handleSettingsPanelRequestEdge] 处理，
  /// SettingsPanel 是"事件",与其他 UI模型不同
  /// 此插槽仅作为占位组件存在。
  Widget _buildSettingsPanelSlot() {
    return const SizedBox.shrink();
  }

  /// 处理设置面板请求的边缘触发
  ///
  /// 仅在 _settingsPanelRequestNotifier 从 false 变为 true 时触发弹窗，
  /// 避免 Widget 重建时因状态丢失而重复弹窗。
  void _handleSettingsPanelRequestEdge() {
    final currentValue = _settingsPanelRequestNotifier.value;

    // 边缘触发：仅当值从 false 变为 true 时执行
    if (currentValue && !_previousSettingsPanelRequestValue) {
      _previousSettingsPanelRequestValue = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 检查 mounted 确保组件仍然存在
        if (!mounted) return;

        AliPlayerSettingsPanelManager.showSettingsPanel(
          context: context,
          controller: _playController,
          sceneType: _sceneType,
          hiddenSlotElements: widget.hiddenSlotElements,
          isShowExternalSubtitle: _playController.showExternalSubtitleNotifier,
        ).whenComplete(() {
          // 弹窗关闭后重置状态，确保下次点击能再次触发
          _previousSettingsPanelRequestValue = false;
          _settingsPanelRequestNotifier.value = false;
        });
      });
    }
  }

  /// 返回事件处理
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

  /// 下载按钮点击回调
  void _onDownloadPressed(bool value) {
    _playController.startVideoDownload();
  }

  /// 截图按钮点击回调
  void _onSnapshotPressed() {
    // 获取截图文件名
    String snapshotFileName = "${DateTime.now().millisecondsSinceEpoch}.png";
    if (Platform.isIOS) {
      _playController.snapshot(snapshotFileName);
    } else if (Platform.isAndroid) {
      // android needs absolute path
      final filePath =
          FileManager.getDownloadFilePath(snapshotFileName) ?? snapshotFileName;
      _playController.snapshot(filePath);
    }
  }

  /// 检测是否支持下载
  bool _isDownloadEnable() {
    // 直播场景不支持下载
    if (isSceneType(_sceneType, [
      SceneType.live,
    ])) {
      return false;
    }

    // 仅 VID 视频源支持下载
    return _playController.isVideoSourceVid();
  }

  /// 构建底部栏控件
  Widget _buildBottomBarWidget() {
    // 拖动控制
    bool enableDrag = isNotSceneType(_sceneType, [
      SceneType.live,
      SceneType.restricted,
    ]);
    // seek 控制
    bool enableSeek = isNotSceneType(_sceneType, [
      SceneType.live,
      SceneType.restricted,
    ]);
    // 监听播放状态、当前播放位置、缓冲位置、总时长等
    Listenable listenable = Listenable.merge([
      _playController.playStateNotifier,
      _playController.currentPositionNotifier,
      _playController.bufferedPositionNotifier,
      _playController.totalDurationNotifier,
      _playController.externalSubtitleAvailableNotifier,
    ]);
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        // 获取播放状态
        final playState = _playController.playStateNotifier.value;
        // 获取当前播放位置、缓冲位置、总时长
        final currentPosition = _playController.currentPositionNotifier.value;
        final bufferedPosition = _playController.bufferedPositionNotifier.value;
        final totalDuration = _playController.totalDurationNotifier.value;
        return AliPlayerBottomBarWidget(
          animationManager: _animationManager,
          controller: _playController,
          sceneType: _sceneType,
          orientation: MediaQuery.of(context).orientation,
          isPlaying: playState == FlutterAvpdef.started,
          currentPosition: currentPosition,
          bufferedPosition: bufferedPosition,
          totalDuration: totalDuration,
          onPlayIconPressed: _onPlayerViewTap,
          onReplayIconPressed: _onReplayIconTap,
          onFullScreenPressed: _onFullScreenPressed,
          onSubtitlePressed: _toggleSubtitleShow,
          onDragUpdate: enableDrag ? _onDragUpdate : null,
          onDragEnd: enableDrag ? _onDragEnd : null,
          onSeekEnd: enableSeek ? _onSeekEnd : null,
          isShowExternalSubtitle:
              _playController.showExternalSubtitleNotifier.value,
          isShowExternalSubtitleBtn:
              _playController.externalSubtitleAvailableNotifier.value,
        );
      },
    );
  }

  /// 外挂字幕显示
  Future<void> _toggleSubtitleShow() async {
    _playController.showExternalSubtitleNotifier.value =
        !_playController.showExternalSubtitleNotifier.value;

    PlayStateShowUtil.show(
      context,
      widgetStatus: PlayStatus.info,
      statusMessage: PlayerI18n.t(
        _playController.showExternalSubtitleNotifier.value
            ? PlayerI18nKeys.subtitleOn
            : PlayerI18nKeys.subtitleOff,
      ),
    );
  }

  /// 全屏状态切换
  ///
  /// 进入和退出全屏均通过 toggleFullscreen 触发 _fullScreenListener 统一处理。
  void _onFullScreenPressed() {
    _playController.toggleFullscreen();
  }

  /// 拖拽进度更新回调
  void _onDragUpdate(Duration duration) {
    _playController.requestThumbnailBitmap(duration);

    // 记录拖拽开始位置
    _dragStartPosition ??= _playController.currentPositionNotifier.value;

    _isDraggingNotifier.value = true;
    _currentSeekTimeNotifier.value = duration;
  }

  /// 拖拽进度结束回调
  void _onDragEnd(Duration duration) {
    final startPosition = _dragStartPosition ?? Duration.zero;
    final dragDistance = (duration - startPosition).abs();

    _isDraggingNotifier.value = false;
    _currentSeekTimeNotifier.value = Duration.zero;
    _dragStartPosition = null;

    // 只有拖拽距离超过阈值时间, 才认为是真正的拖拽操作
    const threshold = Duration(seconds: 1);
    if (dragDistance > threshold && _animationManager.isVisible) {
      // 延迟隐藏，给用户查看时间
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isDraggingNotifier.value && _animationManager.isVisible) {
          _animationManager.hide();
        }
      });
    }
  }

  /// 拖拽进度结束回调
  void _onSeekEnd(Duration duration) {
    _playController.seek(duration);
  }

  /// 构建 seek 缩略图控件
  Widget _buildSeekThumbnailWidget() {
    // 监听播放进度、总时长、是否正在拖拽、当前拖拽进度等
    Listenable listener = Listenable.merge([
      _playController.totalDurationNotifier,
      _playController.thumbnailNotifier,
      _isDraggingNotifier,
      _currentSeekTimeNotifier,
      _playController.videoSizeNotifier,
    ]);
    return ListenableBuilder(
      listenable: listener,
      builder: (context, _) {
        final totalDuration = _playController.totalDurationNotifier.value;
        final thumbnail = _playController.thumbnailNotifier.value;
        final isDragging = _isDraggingNotifier.value;
        final currentSeekTime = _currentSeekTimeNotifier.value;
        final videoWidthHeight = _playController.videoSizeNotifier.value;

        return AliPlayerSeekThumbnailWidget(
          isVisible: isDragging,
          currentSeekTime: currentSeekTime,
          totalDuration: totalDuration,
          thumbnail: thumbnail,
          orientation: MediaQuery.of(context).orientation,
          videoSize: videoWidthHeight,
          hasBottomMargin: _animationManager.isVisible,
        );
      },
    );
  }

  /// 构建外挂字幕组件
  Widget _buildSubtitleWidget() {
    return ValueListenableBuilder<bool>(
      valueListenable: _playController.showExternalSubtitleNotifier,
      builder: (context, show, _) {
        if (!show) {
          return const SizedBox.shrink();
        }

        return _buildSubtitleContent();
      },
    );
  }

  /// 外挂字幕内容
  Widget _buildSubtitleContent() {
    // 监听播放进度、总时长、是否正在拖拽、当前拖拽进度等
    Listenable listener = Listenable.merge([
      _playController.subtitleNotifier,
      _playController.subtitleTrackIndexNotifier,
      _playController.isSubtitleVisibleNotifier,
      _currentSeekTimeNotifier,
    ]);
    return ListenableBuilder(
      listenable: listener,
      builder: (context, _) {
        Subtitles? subtitles = _playController.subtitleNotifier.value;
        int? trackIndex = _playController.subtitleTrackIndexNotifier.value;
        final isSubtitleVisible =
            _playController.isSubtitleVisibleNotifier.value;
        return AliPlayerSubtitleWidget(
          subtitleOn: isSubtitleVisible,
          subtitles: subtitles,
          trackIndex: trackIndex,
          subtitleBuilder: _playController.subtitleBuilder,
          config: _playController.subtitleConfig,
        );
      },
    );
  }

  /// 构建播放速度显示视图
  Widget _buildSpeedDisplayView() {
    return SizedBox(
      height: PlayerStyles.kControlWidgetHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: PlayerStyles.kControlVerticalInsets,
          horizontal: PlayerStyles.kControlHorizontalInsets,
        ),
        child: Row(
          children: [
            const CustomIconButton(
              iconName: PlayerIcons.speedControl,
              iconSize: Size.square(PlayerStyles.iconSizeTopBar),
            ),
            const SizedBox(
              width: PlayerStyles.kSpeedDisplayIconTextSpacing,
            ),
            Text(
              PlayerI18n.t(PlayerI18nKeys.speedFastForward),
              style: const TextStyle(
                color: Colors.white,
                fontSize: PlayerStyles.kSpeedDisplayFontSize,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  /// 构建声音滑块控件
  Widget _buildVolumeSlider() {
    // 监听音量状态
    return ValueListenableBuilder(
      valueListenable: _playController.volumeNotifier,
      builder: (builder, volume, __) {
        return AliPlayerControlSliderWidget(
          text: PlayerI18n.t(PlayerI18nKeys.volume),
          startIconName: PlayerIcons.volume,
          initialValue: volume,
          isInteractive: false,
        );
      },
    );
  }

  /// 构建亮度滑块控件
  Widget _buildBrightnessSlider() {
    // 监听亮度状态
    return ValueListenableBuilder(
      valueListenable: _playController.brightnessNotifier,
      builder: (context, brightness, __) {
        return AliPlayerControlSliderWidget(
          text: PlayerI18n.t(PlayerI18nKeys.brightness),
          startIconName: PlayerIcons.brightness,
          initialValue: brightness,
          isInteractive: false,
        );
      },
    );
  }

  /// 构建中心显示控件
  Widget _buildCenterDisplayWidget() {
    // 获取 centerDisplay 插槽的隐藏元素配置
    final hiddenElements = widget.hiddenSlotElements[SlotType.centerDisplay];

    // 监听播放状态显示视图的内容类型
    return ValueListenableBuilder(
      valueListenable: _contentViewTypeNotifier,
      builder: (context, contentViewType, __) {
        // 如果不显示任何内容，则返回空组件
        if (contentViewType == ContentViewType.none) {
          return const SizedBox.shrink();
        }

        // 检查当前内容类型是否被隐藏
        final contentWidget = _buildCenterDisplayContentWidget(
          contentViewType,
          hiddenElements,
        );

        // 如果内容被隐藏，返回空组件
        if (contentWidget == null) {
          return const SizedBox.shrink();
        }

        return AliPlayerCenterDisplayWidget(
          contentWidget: contentWidget,
        );
      },
    );
  }

  /// 根据 _centerDisplayViewContentType 获取对应的内容组件
  ///
  /// [hiddenElements] 为需要隐藏的元素 key 集合，若当前类型被隐藏则返回 null
  Widget? _buildCenterDisplayContentWidget(
    ContentViewType contentViewType,
    Set<String>? hiddenElements,
  ) {
    switch (contentViewType) {
      // TODO 亮度组件，使用时自行开启
      case ContentViewType.brightness:
        return hiddenElements.isElementVisible(CenterDisplayElements.brightness)
            ? _buildBrightnessSlider()
            : null;
      case ContentViewType.volume:
        return hiddenElements.isElementVisible(CenterDisplayElements.volume)
            ? _buildVolumeSlider()
            : null;
      case ContentViewType.speed:
        return hiddenElements.isElementVisible(CenterDisplayElements.speed)
            ? _buildSpeedDisplayView()
            : null;
      default:
        return null;
    }
  }

  /// 切换显示内容类型
  void _toggleCenterDisplayContentType(ContentViewType contentType) {
    _contentViewTypeNotifier.value = contentType;
  }

  /// 播放器视图点击回调
  void _onPlayerViewTap() {
    // 如果正在拖拽，则不处理点击事件
    if (_isDraggingNotifier.value) {
      return;
    }

    // 切换控制面板显示状态
    _togglePlayControlVisibility();
    _playController.togglePlayState();
  }

  /// 刷新按钮点击回调
  void _onReplayIconTap() {
    _playController.replay();
  }

  /// 播放器视图双击回调
  void _onPlayerViewDoubleTap() {
    _playController.togglePlayState();
  }

  /// 播放器视图长按回调
  void _onPlayerViewLongPress() {
    // 触发设备振动
    VibrationUtil.vibrate(duration: 100);

    // 设置显示内容类型为倍速
    _toggleCenterDisplayContentType(ContentViewType.speed);

    _playController.setSpeed(speed: 2.0);
  }

  /// 播放器视图长按结束回调
  void _onPlayerViewLongPressEnd() {
    // 触发设备振动
    VibrationUtil.vibrate(duration: 50);

    // 设置显示内容类型为空
    _toggleCenterDisplayContentType(ContentViewType.none);

    _playController.setSpeed();
  }

  /// 播放器视图水平拖动回调
  void _onPlayerViewHorizontalDragUpdate(double delta) {
    // 轻量级触觉反馈，避免高频 drag update 产生 Future 积压
    VibrationUtil.selectionFeedback();

    // Update dragging state.
    _isDraggingNotifier.value = true;

    // Calculate based on delta and total duration.
    final totalDuration = _playController.totalDurationNotifier.value;
    final currentPosition = _playController.currentPositionNotifier.value;
    Duration seekDuration = currentPosition + totalDuration * delta;
    // Clamp the value within valid range.
    int seekMills = seekDuration.inMilliseconds.clamp(
      0,
      totalDuration.inMilliseconds,
    );

    // Update current seek time.
    var seekTimeDuration = Duration(milliseconds: seekMills);
    _currentSeekTimeNotifier.value = seekTimeDuration;

    // Request thumbnail update.
    _playController.requestThumbnailBitmap(seekTimeDuration);
  }

  /// 播放器视图水平拖动结束回调
  void _onPlayerViewHorizontalDragEnd(double delta) {
    // 触发设备振动
    VibrationUtil.vibrate(duration: 100);

    // Seek to the current seek time.
    final currentSeekTime = _currentSeekTimeNotifier.value;
    _playController.seek(currentSeekTime);

    // Reset dragging state.
    _isDraggingNotifier.value = false;
    _currentSeekTimeNotifier.value = Duration.zero;
  }

  /// 播放器视图左垂直拖动回调
  void _onPlayerViewLeftVerticalDragUpdate(double delta) {
    // 触发设备振动
    VibrationUtil.vibrate(duration: 50);

    // 设置显示内容类型为亮度
    _toggleCenterDisplayContentType(ContentViewType.brightness);

    _playController.setBrightnessWithDelta(delta);
  }

  /// 播放器视图左垂直拖动结束回调
  void _onPlayerViewLeftVerticalDragEnd(double delta) {
    // 触发设备振动
    VibrationUtil.vibrate(duration: 100);

    // 设置显示内容类型为空
    _toggleCenterDisplayContentType(ContentViewType.none);
  }

  /// 播放器视图右垂直拖动回调
  void _onPlayerViewRightVerticalDragUpdate(double delta) {
    // 触发设备振动
    VibrationUtil.vibrate(duration: 50);

    // 设置显示内容类型为声音
    _toggleCenterDisplayContentType(ContentViewType.volume);

    _playController.setVolumeWithDelta(delta);
  }

  /// 播放器视图右垂直拖动结束回调
  void _onPlayerViewRightVerticalDragEnd(double delta) {
    // 触发设备振动
    VibrationUtil.vibrate(duration: 100);

    // 设置显示内容类型为空
    _toggleCenterDisplayContentType(ContentViewType.none);
  }

  /// 构建播放状态视图
  Widget _buildPlayStateView() {
    // 监听播放状态、错误码、错误信息等变化
    Listenable listenable = Listenable.merge([
      _playController.playStateNotifier,
      _playController.playErrorNotifier,
      _playController.isLoadingStateNotifier,
    ]);
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        // 获取播放状态
        final playState = _playController.playStateNotifier.value;
        final isLoadingState = _playController.isLoadingStateNotifier.value;

        if (!playState.shouldBuildErrorWidget) {
          if (isLoadingState) {
            return AliPlayerPlayStateWidget(
              widgetStatus: PlayStatus.loading,
              statusCode: PlayerI18n.t(PlayerI18nKeys.statusLoading),
            );
          } else {
            // 如果不需要构建播放状态视图，则返回空组件
            return const SizedBox.shrink();
          }
        }

        // 获取错误码和错误信息
        final playError = _playController.playErrorNotifier.value;
        final errorCode = playError?.keys.firstOrNull;
        final errorMsg = playError?.values.firstOrNull;

        return AliPlayerPlayStateWidget(
          widgetStatus: PlayStatus.error,
          statusCode: "$errorCode",
          statusMessage: errorMsg,
        );
      },
    );
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

    /// 初始化共享动画管理器
    _animationManager = SharedAnimationManager(this);

    /// 初始化场景类型
    _sceneType = _playController._widgetData?.sceneType ?? SceneType.vod;

    /// 缓存插槽渲染顺序
    _resolvedSlotOrder = _resolveSlotOrder();

    /// 添加观察者
    WidgetsBinding.instance.addObserver(this);

    /// 仅在非全屏上下文中注册全屏监听，防止全屏路由中的 AliPlayerWidget 再次 push
    if (!_playController.isFullScreenNotifier.value) {
      _playController.isFullScreenNotifier.addListener(_fullScreenListener);
      _hasFullScreenListener = true;
    }

    /// 监听设置面板请求的边缘触发（false → true）
    _settingsPanelRequestNotifier.addListener(_handleSettingsPanelRequestEdge);
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
        return AliPlayerFullScreenWidget(
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
    // 坑点：由于 Flutter SDK 内部实现限制，需重新绑定原生播放器到竖屏的 AliPlayerView
    // 全屏期间，全屏的 AliPlayerView 调用了 _setPlayerView(fullscreenViewId)，覆盖了竖屏的绑定
    // 全屏 pop 后，全屏的 PlatformView 被销毁，需要将原生播放器重新指向竖屏仍然存活的 PlatformView
    if (mounted && _currentViewId != null) {
      _playController._setPlayerView(_currentViewId!);
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

    // 销毁 ValueNotifier
    _disposeValueNotifiers();

    // 移除全屏状态监听（仅在注册过时才移除）
    if (_hasFullScreenListener) {
      _playController.isFullScreenNotifier.removeListener(_fullScreenListener);
    }

    // 销毁共享动画管理器
    _animationManager.dispose();

    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// 销毁 ValueNotifier
  void _disposeValueNotifiers() {
    _contentViewTypeNotifier.dispose();

    _isDraggingNotifier.dispose();
    _currentSeekTimeNotifier.dispose();
    _settingsPanelRequestNotifier.dispose();
  }

  /// 状态更新回调
  /// 当 Widget 的状态被更新时，该方法被调用。
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    logi("[lifecycle] didUpdateWidget");

    // 如果控制器发生变化，则更新内部状态
    if (widget._controller != oldWidget._controller) {
      _playController = widget._controller;
      setState(() {});
    }

    // slotBuilders 变化时刷新插槽顺序缓存
    if (widget.slotBuilders != oldWidget.slotBuilders) {
      _resolvedSlotOrder = _resolveSlotOrder();
    }
  }

  /// 应用程序生命周期变化回调
  /// 当应用程序生命周期的状态发生变化时（如暂停、恢复），该方法被调用。
  /// TODO: 当前为日志占位实现，后续可添加实际逻辑（如后台自动暂停、前台自动恢复）
  ///
  /// Called when the application's lifecycle state changes (e.g., paused, resumed).
  /// TODO: Currently a logging placeholder. Add actual logic later (e.g., auto-pause on background).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        logi("App resumed");
        break;
      case AppLifecycleState.inactive:
        logi("App inactive");
        break;
      case AppLifecycleState.paused:
        logi("App paused");
        break;
      case AppLifecycleState.detached:
        logi("App detached");
        break;
      case AppLifecycleState.hidden:
        logi("App hidden");
        break;
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

// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/6
// Brief: Player Widget, used to play videos

part of 'aliplayer_widget_lib.dart';

/// 一个用于播放视频的 Widget，支持自定义控制器和覆盖层。
///
/// A widget for video playback that supports custom controllers and overlay layers.
late AliPlayerWidgetController _fullController;
bool isFullScreen = false;

class AliPlayerWidget extends StatefulWidget {
  /// 视频播放控制器，用于控制视频的播放、暂停等操作。
  ///
  /// The video player controller used to control playback, pause, etc.
  final AliPlayerWidgetController _controller;

  /// 自定义覆盖层，允许在视频上方显示额外的 UI 元素。
  ///
  /// Custom overlay layers that allow displaying additional UI elements above the video.
  final List<Widget> overlays;

  /// 构造函数，用于创建 [AliPlayerWidget] 实例。
  ///
  /// Constructor to create an instance of [AliPlayerWidget].
  ///
  /// 参数：
  /// - [_controller]：视频播放控制器，必须提供，用于管理视频播放逻辑。
  /// - [key]：可选参数，用于标识 Widget 的唯一性。
  /// - [overlays]：可选参数，默认为空列表，用于定义覆盖在视频上的 UI 元素。
  ///
  /// Parameters:
  /// - _controller: The video player controller, required to manage video playback logic.
  /// - key: Optional parameter used to identify the uniqueness of the widget.
  /// - overlays: Optional parameter, defaults to an empty list, used to define UI elements overlaid on the video.
  const AliPlayerWidget(
    this._controller, {
    super.key,
    this.overlays = const [],
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

  /// 共享动画控制器
  late SharedAnimationManager _animationManager;

  /// 当前播放场景类型
  late SceneType _sceneType;

  /// 播放状态显示视图的内容类型，默认为 none 不显示
  final SafeValueNotifier<ContentViewType> _contentViewTypeNotifier =
      SafeValueNotifier(ContentViewType.none);

  /// 是否展示设置菜单面板控件
  final SafeValueNotifier<bool> _isShowSettingMenuPanelNotifier =
      SafeValueNotifier(false);

  /// 是否正在拖动进度条
  final SafeValueNotifier<bool> _isDraggingNotifier = SafeValueNotifier(false);

  /// 当前拖动进度条的时间
  final SafeValueNotifier<Duration> _currentSeekTimeNotifier =
      SafeValueNotifier(Duration.zero);

  /// 构建播放器视图
  ///
  /// Builds the main player view.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool didPop) {
        if (didPop) return; // 如果已经处理了返回操作，则直接返回
        _handleBackPress();
      },
      child: _buildContentBody(),
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
          isFullScreenMode: FullScreenUtil.isFullScreen(),
        );

        logi("[build]: videoSize: $videoSize, playerViewSize: $playerViewSize");

        final double width = playerViewSize.width;
        final double height = playerViewSize.height;

        return ConstrainedBox(
          constraints: BoxConstraints.tight(playerViewSize),
          child: Stack(
            children: [
              _buildPlaySurfaceView(width, height),
              if (_playController._widgetData?.coverUrl.isNotEmpty ?? false)
                _buildPlayCoverView(width, height),
              _buildPlayControlView(),
              _buildTopBarWidget(),
              _buildBottomBarWidget(),
              if (isNotScene(_playController._widgetData, SceneType.live))
                _buildSeekThumbnailWidget(),
              _buildCenterDisplayWidget(),
              _buildPlayStateView(),
              // 添加浮层
              ..._buildOverlays(),
              _buildSettingMenuPanel(),
            ],
          ),
        );
      },
    );
  }

  /// 构建播放器视图
  ///
  /// build player view
  Widget _buildPlaySurfaceView(double width, double height) {
    return AliPlayerView(
      onCreated: (int viewId) => _playController._setPlayerView(viewId),
      x: 0,
      y: 0,
      width: width,
      height: height,
    );
  }

  /// 构建封面视图
  ///
  /// build cover view
  Widget _buildPlayCoverView(double width, double height) {
    // 监听播放器是否渲染完成，如果没有渲染完成，则显示封面图片
    return ValueListenableBuilder(
      valueListenable: _playController.isRenderedNotifier,
      builder: (context, isRendered, __) {
        // 如果播放器已经渲染完成，则不显示封面图片
        if (isRendered) {
          return const SizedBox.shrink();
        }

        // 获取封面图片的 URL
        var imageUrl = _playController._widgetData?.coverUrl ?? "";
        return AliPlayerCoverImageWidget(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  /// 构建播放控制视图
  Widget _buildPlayControlView() {
    // 长按控制
    bool enableLongPress = !_isSceneLive();
    // 拖动控制
    bool enableDrag = !_isSceneLive();
    // 竖向手势控制
    bool enableVerticalGestures = !_isSceneListPlayer();
    return AliPlayerPlayControlWidget(
      autoHide: true,
      onVisibilityChanged: (bool isVisible) {
        _togglePlayControlVisibility(forceHide: !isVisible);
      },
      onDoubleTap: _onPlayerViewDoubleTap,
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
    if (forceHide || _animationManager.isVisible) {
      _animationManager.hide(); // 隐藏
    } else {
      _animationManager.show(); // 显示
    }
  }

  /// 构建顶部栏控件
  Widget _buildTopBarWidget() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AliPlayerTopBarWidget(
        animationManager: _animationManager,
        title: _playController._widgetData?.videoTitle ?? "",
        onBackPressed: _handleBackPress,
        onSettingsPressed: _toggleSettingMenuPanel,
        // TODO keria; download feature to be implemented
        isDownload: false,
        onDownloadPressed: _isSceneLive() ? null : _onDownloadPressed,
        onSnapshotPressed: _isSceneLive() ? null : _onSnapshotPressed,
        onPIPPressed: _isSceneLive() ? null : _onPIPPressed,
      ),
    );
  }

  /// 返回事件处理
  bool _handleBackPress() {
    if (FullScreenUtil.isFullScreen()) {
      // 如果当前是全屏模式，退出全屏
      isFullScreen = false;
      exitFullScreen();
      return false; // 阻止默认的返回操作
    } else {
      // 如果不是全屏模式，执行正常的返回操作
      Navigator.of(context).pop();
      return true;
    }
  }

  /// 下载按钮点击回调
  void _onDownloadPressed(bool value) {
    // TODO keria; download feature to be implemented
    SnackBarUtil.warning(context, "download feature to be implemented");
  }

  /// 截图按钮点击回调
  void _onSnapshotPressed() {
    // TODO keria; snapshot feature to be implemented
    SnackBarUtil.warning(context, "snapshot feature to be implemented");
  }

  /// PIP 按钮点击回调
  void _onPIPPressed() {
    // TODO keria; PIP feature to be implemented
    SnackBarUtil.warning(context, "PIP feature to be implemented");
  }

  /// 构建底部栏控件
  Widget _buildBottomBarWidget() {
    // 拖动控制
    bool enableDrag = !_isSceneLive();
    // seek 控制
    bool enableSeek = !_isSceneLive();

    // 监听播放状态、当前播放位置、缓冲位置、总时长等
    Listenable listenable = Listenable.merge([
      _playController.playStateNotifier,
      _playController.currentPositionNotifier,
      _playController.bufferedPositionNotifier,
      _playController.totalDurationNotifier,
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
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AliPlayerBottomBarWidget(
            animationManager: _animationManager,
            isPlaying: playState == FlutterAvpdef.started,
            currentPosition: currentPosition,
            bufferedPosition: bufferedPosition,
            totalDuration: totalDuration,
            onPlayIconPressed: _onPlayerViewTap,
            onFullScreenPressed: _onFullScreenPressed,
            onDragUpdate: enableDrag ? _onDragUpdate : null,
            onDragEnd: enableDrag ? _onDragEnd : null,
            onSeekEnd: enableSeek ? _onSeekEnd : null,
          ),
        );
      },
    );
  }

  /// 全屏状态切换
  Future<void> _onFullScreenPressed() async {
    // 切换全屏
    if (!isFullScreen) {
      isFullScreen = true;
      _playController.getCurrentPosition().then((position) {
        enterFullScreen(position);
      });
    }
    // 退出全屏
    else {
      isFullScreen = false;
      await exitFullScreen();
    }
  }

  /// 播放器切换全屏
  Future<void> enterFullScreen(int currentPosition) async {
    final data = _playController._widgetData;
    if (data == null) return;
    data.startTime = currentPosition;

    // 进入全屏播放器
    AliPlayerWidgetData result = await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 100), // 动画持续时间
        pageBuilder: (context, animation, secondaryAnimation) {
          return AliPlayerFullScreenWidget(_playController, data);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 淡入淡出动画
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
    int fullScreenPosition = await result.startTime ?? 0;
    await _playController._aliPlayer
        .seekTo(fullScreenPosition, result.seekMode);
    _playController.play();
  }

  /// 播放器退出全屏
  Future<void> exitFullScreen() async {
    // 恢复状态栏和导航栏
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // 正常竖屏
      DeviceOrientation.portraitDown, // 倒置竖屏
    ]);

    final data = _fullController._widgetData;

    if (data == null) return;

    _fullController.getCurrentPosition().then((position) {
      data.startTime = position;
      // 先暂停播放器
      _fullController.stop();

      // 销毁全屏播放器
      _fullController.destroy();

      // 返回竖屏播放器
      Navigator.pop(context, data);
    });
  }

  /// 拖拽进度更新回调
  void _onDragUpdate(Duration duration) {
    _playController.requestThumbnailBitmap(duration);

    _isDraggingNotifier.value = true;
    _currentSeekTimeNotifier.value = duration;
  }

  /// 拖拽进度结束回调
  void _onDragEnd(Duration duration) {
    _isDraggingNotifier.value = false;
    _currentSeekTimeNotifier.value = Duration.zero;
  }

  /// 拖拽进度结束回调
  void _onSeekEnd(Duration duration) {
    _playController.seek(duration);
  }

  /// 构建设置菜单面板控件
  Widget _buildSettingMenuPanel() {
    // 监听设置面板的可见性
    return ValueListenableBuilder(
      valueListenable: _isShowSettingMenuPanelNotifier,
      builder: (context, visible, __) {
        return AliPlayerSettingMenuPanel(
          isVisible: visible,
          onVisibilityChanged: (bool isVisible) {
            _isShowSettingMenuPanelNotifier.value = isVisible;
          },
          settingItems: _buildSettingItems(),
        );
      },
    );
  }

  /// 构建设置菜单面板控件
  List<SettingItem> _buildSettingItems() {
    return [
      // 构建声音滑块控件
      SettingItem(
        type: SettingItemType.slider,
        text: "声音",
        startIcon: Icons.volume_down_rounded,
        endIcon: Icons.volume_up_rounded,
        initialValue: _playController.volumeNotifier.value,
        onChanged: (value) => _playController.setVolume(value),
      ),
      // 构建亮度滑块控件
      SettingItem(
        type: SettingItemType.slider,
        text: "亮度",
        startIcon: Icons.brightness_low_rounded,
        endIcon: Icons.brightness_high_rounded,
        initialValue: _playController.brightnessNotifier.value,
        onChanged: (value) => _playController.setBrightness(value),
      ),
      // 构建倍速选择控件
      if (!_isSceneLive())
        SettingItem(
          type: SettingItemType.selector,
          text: "倍速",
          startIcon: Icons.speed_rounded,
          options: SettingConstants.speedOptions,
          initialValue: _playController.speedNotifier.value,
          onChanged: (value) => _playController.setSpeed(speed: value),
          displayFormatter: (option) => "${option}x",
        ),
      // 构建清晰度选择控件
      if (!_isSceneLive())
        SettingItem(
          type: SettingItemType.selector,
          text: "清晰度",
          startIcon: Icons.hd_rounded,
          options: _playController.trackInfoListNotifier.value,
          initialValue: _playController.currentTrackInfoNotifier.value,
          onChanged: (value) => _playController.selectTrack(value),
          displayFormatter: (option) => TrackInfoUtil.getQuality(option),
        ),
      // 构建循环播放开关控件
      if (!_isSceneLive())
        SettingItem(
          type: SettingItemType.switcher,
          text: "循环播放",
          startIcon: Icons.loop_rounded,
          initialValue: _playController.isLoopNotifier.value,
          onChanged: (value) => _playController.setLoop(value),
        ),
      // 构建静音播放开关控件
      SettingItem(
        type: SettingItemType.switcher,
        text: "静音播放",
        startIcon: _playController.isMuteNotifier.value
            ? Icons.volume_off_rounded
            : Icons.volume_up_rounded,
        initialValue: _playController.isMuteNotifier.value,
        onChanged: (value) => _playController.setMute(value),
      ),
      // 构建镜像模式选择控件
      SettingItem(
        type: SettingItemType.selector,
        text: "镜像模式",
        startIcon: Icons.swap_horiz_rounded,
        options: SettingConstants.mirrorModeOptions,
        initialValue: _playController.mirrorModeNotifier.value,
        onChanged: (value) => _playController.setMirrorMode(value),
        displayFormatter: (option) => FormatUtil.formatMirrorMode(option),
      ),
      // 构建旋转模式选择控件
      SettingItem(
        type: SettingItemType.selector,
        text: "旋转模式",
        startIcon: Icons.crop_rotate_rounded,
        options: SettingConstants.rotateModeOptions,
        initialValue: _playController.rotateModeNotifier.value,
        onChanged: (value) => _playController.setRotateMode(value),
        displayFormatter: (option) => "$option°",
      ),
      // 构建渲染填充选择控件
      SettingItem(
        type: SettingItemType.selector,
        text: "渲染填充",
        startIcon: Icons.crop_rounded,
        options: SettingConstants.scaleModeOptions,
        initialValue: _playController.scaleModeNotifier.value,
        onChanged: (value) => _playController.setScaleMode(value),
        displayFormatter: (option) => FormatUtil.formatScaleMode(option),
      ),
    ];
  }

  /// 调起设置菜单面板控件
  void _toggleSettingMenuPanel() {
    _togglePlayControlVisibility(forceHide: true);
    _isShowSettingMenuPanelNotifier.value = true;
  }

  /// 构建 seek 缩略图控件
  Widget _buildSeekThumbnailWidget() {
    // 监听播放进度、总时长、是否正在拖拽、当前拖拽进度等
    Listenable listener = Listenable.merge([
      _playController.totalDurationNotifier,
      _playController.thumbnailNotifier,
      _isDraggingNotifier,
      _currentSeekTimeNotifier,
    ]);
    return ListenableBuilder(
      listenable: listener,
      builder: (context, _) {
        final totalDuration = _playController.totalDurationNotifier.value;
        final thumbnail = _playController.thumbnailNotifier.value;
        final isDragging = _isDraggingNotifier.value;
        final currentSeekTime = _currentSeekTimeNotifier.value;

        return Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: AliPlayerSeekThumbnailWidget(
            isVisible: isDragging,
            currentSeekTime: currentSeekTime,
            totalDuration: totalDuration,
            thumbnail: thumbnail,
          ),
        );
      },
    );
  }

  /// 构建播放速度显示视图
  Widget _buildSpeedDisplayView() {
    // 监听播放速度
    return ValueListenableBuilder(
      valueListenable: _playController.speedNotifier,
      builder: (context, speed, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          child: Text(
            '$speed倍速',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  /// 构建声音滑块控件
  Widget _buildVolumeSlider() {
    // 监听音量状态
    return ValueListenableBuilder(
      valueListenable: _playController.volumeNotifier,
      builder: (builder, volume, __) {
        return AliPlayerCustomSliderWidget(
          text: "声音",
          startIcon: Icons.volume_down_rounded,
          endIcon: Icons.volume_up_rounded,
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
        return AliPlayerCustomSliderWidget(
          text: "亮度",
          startIcon: Icons.brightness_low_rounded,
          endIcon: Icons.brightness_high_rounded,
          initialValue: brightness,
          isInteractive: false,
        );
      },
    );
  }

  /// 构建中心显示控件
  Widget _buildCenterDisplayWidget() {
    // 监听播放状态显示视图的内容类型
    return ValueListenableBuilder(
      valueListenable: _contentViewTypeNotifier,
      builder: (context, contentViewType, __) {
        // 如果不显示任何内容，则返回空组件
        if (contentViewType == ContentViewType.none) {
          return const SizedBox.shrink();
        }

        return AliPlayerCenterDisplayWidget(
          contentWidget: _buildCenterDisplayContentWidget(contentViewType),
        );
      },
    );
  }

  /// 根据 _centerDisplayViewContentType 获取对应的内容组件
  Widget _buildCenterDisplayContentWidget(ContentViewType contentViewType) {
    switch (contentViewType) {
      case ContentViewType.brightness:
        return _buildBrightnessSlider();
      case ContentViewType.volume:
        return _buildVolumeSlider();
      case ContentViewType.speed:
        return _buildSpeedDisplayView();
      default: // 不显示时返回空组件
        return const SizedBox.shrink();
    }
  }

  /// 切换显示内容类型
  void _toggleCenterDisplayContentType(ContentViewType contentType) {
    _contentViewTypeNotifier.value = contentType;
  }

  /// 播放器视图点击回调
  void _onPlayerViewTap() {
    _togglePlayControlVisibility(forceHide: true);
    _playController.togglePlayState();
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
    // 触发设备振动
    VibrationUtil.vibrate(duration: 50);

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
    ]);
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        // 获取播放状态
        final playState = _playController.playStateNotifier.value;

        // 如果不需要构建播放状态视图，则返回空组件
        if (!playState.shouldBuildWidget) {
          return const SizedBox.shrink();
        }

        // 获取错误码和错误信息
        final playError = _playController.playErrorNotifier.value;
        final errorCode = playError?.keys.firstOrNull;
        final errorMsg = playError?.values.firstOrNull;

        return AliPlayerPlayStateWidget(
          errorCode: errorCode,
          errorMsg: errorMsg,
        );
      },
    );
  }

  /// 构建浮层视图
  List<Widget> _buildOverlays() {
    return widget.overlays;
  }

  /// 判断当前场景是否为直播
  bool _isSceneLive() {
    return _sceneType == SceneType.live;
  }

  /// 判断当前场景是否为列表播放
  bool _isSceneListPlayer() {
    return _sceneType == SceneType.listPlayer;
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

    /// 初始化共享动画管理器
    _animationManager = SharedAnimationManager(this);

    /// 初始化场景类型
    _sceneType = _playController._widgetData?.sceneType ?? SceneType.vod;

    /// 添加观察者
    WidgetsBinding.instance.addObserver(this);
  }

  /// 清理资源
  /// 在 StatefulWidget 被从树中移除并销毁时调用的，这个方法用于清理资源。
  ///
  /// Called when the widget is removed from the tree permanently. Used to release resources.
  @override
  void dispose() {
    logi("[lifecycle] dispose");

    // 销毁 ValueNotifier
    _disposeValueNotifiers();

    // 销毁共享动画管理器
    _animationManager.dispose();

    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// 销毁 ValueNotifier
  void _disposeValueNotifiers() {
    _contentViewTypeNotifier.dispose();

    _isShowSettingMenuPanelNotifier.dispose();

    _isDraggingNotifier.dispose();
    _currentSeekTimeNotifier.dispose();
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
  }

  /// 应用程序生命周期变化回调
  /// 当应用程序生命周期的状态发生变化时（如暂停、恢复），该方法被调用。
  ///
  /// Called when the application's lifecycle state changes (e.g., paused, resumed).
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

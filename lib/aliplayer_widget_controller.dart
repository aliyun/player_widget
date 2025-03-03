// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/10
// Brief: Player widget controller, used to manage the initialization, playback, and destruction logic of Alibaba Cloud Player

part of 'aliplayer_widget_lib.dart';

/// 播放器组件控制器，用于管理阿里云播放器的初始化、播放和销毁逻辑
///
/// Player widget controller, used to manage the initialization, playback,
/// and destruction logic of Alibaba Cloud Player
class AliPlayerWidgetController {
  /// 日志标签
  static const _logTag = "AliPlayerWidgetController";

  final BuildContext _context;

  /// 播放器实例
  late FlutterAliplayer _aliPlayer;

  /// 是否已准备播放
  bool _isPrepared = false;

  /// 播放数据源准备开始时间
  int _prepareStartTime = 0;

  /// 渲染状态变化通知器
  ///
  /// Value notifier for rendering status
  final SafeValueNotifier<bool> isRenderedNotifier = SafeValueNotifier(false);

  /// 视频尺寸变化通知器
  ///
  /// Value notifier for video size
  final SafeValueNotifier<Size> videoSizeNotifier =
      SafeValueNotifier(Size.zero);

  /// 播放状态变化通知器
  ///
  /// Value notifier for playback status
  final SafeValueNotifier<int> playStateNotifier =
      SafeValueNotifier(FlutterAvpdef.unknow);

  /// 播放错误信息变化通知器
  ///
  /// Value notifier for playback error
  final SafeValueNotifier<Map<int?, String?>?> playErrorNotifier =
      SafeValueNotifier(null);

  /// 播放进度变化通知器
  ///
  /// Value notifier for current position
  final SafeValueNotifier<Duration> currentPositionNotifier =
      SafeValueNotifier(Duration.zero);

  /// 播放缓冲进度变化通知器
  ///
  /// Value notifier for buffered position
  final SafeValueNotifier<Duration> bufferedPositionNotifier =
      SafeValueNotifier(Duration.zero);

  /// 播放总时长变化通知器
  ///
  /// Value notifier for total duration
  final SafeValueNotifier<Duration> totalDurationNotifier =
      SafeValueNotifier(Duration.zero);

  /// 播放亮度变化通知器
  ///
  /// Value notifier for brightness
  final SafeValueNotifier<double> brightnessNotifier =
      SafeValueNotifier(SettingConstants.defaultBrightness);

  /// 播放音量变化通知器
  ///
  /// Value notifier for volume
  final SafeValueNotifier<double> volumeNotifier =
      SafeValueNotifier(SettingConstants.defaultVolume);

  /// 播放速度变化通知器
  ///
  /// Value notifier for speed
  final SafeValueNotifier<double> speedNotifier =
      SafeValueNotifier(SettingConstants.defaultSpeed);

  /// 循环播放变化通知器
  ///
  /// Value notifier for loop playback
  final SafeValueNotifier<bool> isLoopNotifier =
      SafeValueNotifier(SettingConstants.defaultIsLoop);

  /// 静音播放变化通知器
  ///
  /// Value notifier for mute playback
  final SafeValueNotifier<bool> isMuteNotifier =
      SafeValueNotifier(SettingConstants.defaultIsMute);

  /// 镜像模式变化通知器
  ///
  /// Value notifier for mirror mode
  final SafeValueNotifier<int> mirrorModeNotifier =
      SafeValueNotifier(SettingConstants.defaultMirrorMode);

  /// 旋转角度变化通知器
  ///
  /// Value notifier for rotate mode
  final SafeValueNotifier<int> rotateModeNotifier =
      SafeValueNotifier(SettingConstants.defaultRotateMode);

  /// 渲染模式变化通知器
  ///
  /// Value notifier for render mode
  final SafeValueNotifier<int> scaleModeNotifier =
      SafeValueNotifier(SettingConstants.defaultScaleMode);

  /// 播放清晰度变化通知器
  ///
  /// Value notifier for track info
  final SafeValueNotifier<AVPTrackInfo?> currentTrackInfoNotifier =
      SafeValueNotifier(null);

  /// 播放清晰度信息列表变化通知器
  ///
  /// Value notifier for track info list
  final SafeValueNotifier<List<AVPTrackInfo>?> trackInfoListNotifier =
      SafeValueNotifier(null);

  /// 缩略图变化通知器
  ///
  /// Value notifier for thumbnail
  final SafeValueNotifier<MemoryImage?> thumbnailNotifier =
      SafeValueNotifier(null);

  /// 缩略图是否获取成功
  bool _thumbnailSuccess = false;

  /// 播放数据源
  AliPlayerWidgetData? _widgetData;

  /// 播放器组件控制器构造函数，用于创建 [AliPlayerWidgetController] 实例。
  ///
  /// Constructor to create an instance of [AliPlayerWidgetController].
  ///
  /// 参数：
  /// - [_context]：当前 Widget 的上下文，必须提供，用于初始化控制器并与 UI 层交互。
  ///
  /// Parameters:
  /// - _context: The context of the current widget, required for initializing the controller and interacting with the UI layer.
  AliPlayerWidgetController(this._context) {
    logi("[lifecycle] construct", tag: _logTag);
    _init();
  }

  /// 初始化操作
  void _init() async {
    // 初始化全局配置
    AliPlayerWidgetGlobalSetting.setupConfig();

    // 初始化播放器实例
    _initializePlayer();

    // 设置默认值
    _batchLoadDefaultValues();
  }

  /// 销毁播放控制器
  ///
  /// Destroy the player controller
  void destroy() async {
    // 销毁播放器实例
    _destroyPlayer();

    // 销毁值监听器
    _disposeValueNotifiers();
  }

  /// 初始化播放器实例
  ///
  /// initialize the player
  void _initializePlayer() {
    logi("Initializing player");

    /// 1、创建播放器
    _aliPlayer = FlutterAliPlayerFactory.createAliPlayer();
    logi("[player][api][create]: ${_aliPlayer.hashCode}");

    /// 2、设置播放器事件回调
    // 设置播放器事件回调，准备完成事件
    _aliPlayer.setOnPrepared((String playerId) {
      _isPrepared = true;

      int cost = DateTime.now().millisecondsSinceEpoch - _prepareStartTime;
      logi("[player][cbk][onPrepared], costTime: $cost");

      // 创建清晰度信息
      _createTrackInfoWhenPrepared();

      // 创建缩略图（方式1）
      _createThumbnailWhenPrepared();
    });

    // 设置播放器事件回调，首帧显示事件
    _aliPlayer.setOnRenderingStart((String playerId) async {
      int cost = DateTime.now().millisecondsSinceEpoch - _prepareStartTime;
      logi("[player][cbk][renderingStart], costTime: $cost");

      // 更新渲染状态
      isRenderedNotifier.value = true;

      final totalDuration = await _aliPlayer.getDuration();

      if (totalDuration == 0) {
        return;
      }
      totalDurationNotifier.value = Duration(milliseconds: totalDuration);
    });

    // 设置播放器事件回调，播放完成事件
    _aliPlayer.setOnCompletion((String playerId) {
      _isPrepared = false;
      _prepareStartTime = 0;
    });

    // 设置视频大小变化回调
    _aliPlayer.setOnVideoSizeChanged((
      int width,
      int height,
      int? rotation,
      String playerId,
    ) async {
      logi("[player][cbk][videoSizeChanged]: $width, $height, $rotation");
      // 更新视频尺寸
      _updateVideoSize();
    });

    // 设置视频缓冲相关回调
    _aliPlayer.setOnLoadingStatusListener(
      // loadingBegin: 播放器事件回调，缓冲开始事件
      loadingBegin: (String playerId) {},
      // loadingProgress: 视频缓冲进度回调
      loadingProgress: (int percent, double? netSpeed, String playerId) {},
      // loadingEnd: 播放器事件回调，缓冲完成事件
      loadingEnd: (String playerId) {},
    );

    // 设置播放器事件回调，跳转完成事件
    _aliPlayer.setOnSeekComplete((String playerId) {});

    // 设置视频当前播放位置回调
    _aliPlayer.setOnInfo(
        (int? infoCode, int? extraValue, String? extraMsg, String playerId) {
      if (infoCode == 1) {
        // logi("[player][cbk][bufferedPosition], $extraValue, $extraMsg");

        final bufferedPosition = extraValue ?? 0;
        bufferedPositionNotifier.value =
            Duration(milliseconds: bufferedPosition);
      } else if (infoCode == 2) {
        // logi("[player][cbk][currentPosition], $extraValue, $extraMsg");

        final currentPosition = extraValue ?? 0;
        currentPositionNotifier.value = Duration(milliseconds: currentPosition);
      }
    });

    // 设置获取 track 信息回调
    _aliPlayer.setOnTrackReady((String playerId) async {
      logi("[player][cbk][setOnTrackReady]");

      // 更新视频尺寸
      _updateVideoSize();

      // 创建清晰度信息
      _createTrackInfoWhenPrepared();

      // 创建缩略图（方式2）
      _createThumbnailWhenTrackReady();
    });

    // 设置track切换完成回调
    _aliPlayer.setOnTrackChanged((dynamic value, String playerId) {
      final trackInfoList = trackInfoListNotifier.value;
      final selectedTrackInfo = TrackInfoUtil.getTrackInfoByIndex(
        trackInfoList,
        value["trackIndex"],
      );

      // 如果没有找到对应的清晰度信息，则不处理
      if (selectedTrackInfo == null) {
        return;
      }

      // 更新当前清晰度信息
      currentTrackInfoNotifier.value = selectedTrackInfo;

      // 显示提示信息
      String quality = TrackInfoUtil.getQuality(selectedTrackInfo);
      SnackBarUtil.success(_context, "selectTrack: $quality");
    });

    // 设置获取截图回调
    _aliPlayer.setOnSnapShot((String path, String playerId) {});

    // 设置错误代理回调
    _aliPlayer.setOnError((
      int errorCode,
      String? errorExtra,
      String? errorMsg,
      String playerId,
    ) {
      logi("[player][cbk][error], errorCode: $errorCode, errorMsg: $errorMsg");

      playErrorNotifier.value = {errorCode: errorMsg};
    });

    // 设置播放器状态改变回调
    _aliPlayer.setOnStateChanged((int newState, String playerId) {
      final oldState = playStateNotifier.value;
      logi("[player][cbk][stateChanged], state: $oldState->$newState");

      // Update play state
      playStateNotifier.value = newState;
    });

    // 设置缩略图代理回调
    _aliPlayer.setOnThumbnailPreparedListener(
      preparedSuccess: (playerId) {
        logi("[player][cbk][thumbnailPrepared]: preparedSuccess, $playerId");
        _thumbnailSuccess = true;
      },
      preparedFail: (playerId) {
        logi("[player][cbk][thumbnailPrepared]: preparedFail, $playerId");
        _thumbnailSuccess = false;
      },
    );

    // 设置缩略图获取代理回调
    _aliPlayer.setOnThumbnailGetListener(
      onThumbnailGetSuccess: (bitmap, range, playerId) {
        var provider = MemoryImage(bitmap);
        thumbnailNotifier.value = provider;
      },
      onThumbnailGetFail: (playerId) {},
    );

    /// 3. 其它配置
    // IPlayer.ScaleMode.SCALE_ASPECT_FILL
    _aliPlayer.setScalingMode(1);

    logi("Player initialization completed.");
  }

  /// 销毁播放器实例
  ///
  /// Destroy the player
  void _destroyPlayer() {
    logi("destroy player");

    // 暂停播放
    pause();
    // 停止播放
    stop();

    // 异步释放播放器
    logi("[player][api][releaseAsync]: ${_aliPlayer.hashCode}");
    _aliPlayer.releaseAsync();

    // 重置播放状态
    _isPrepared = false;
    _prepareStartTime = 0;

    // 重置渲染状态
    isRenderedNotifier.value = false;

    logi("Player destroyed.");
  }

  /// 销毁 ValueNotifier
  void _disposeValueNotifiers() {
    isRenderedNotifier.dispose();

    videoSizeNotifier.dispose();

    playStateNotifier.dispose();
    playErrorNotifier.dispose();

    currentPositionNotifier.dispose();
    bufferedPositionNotifier.dispose();
    totalDurationNotifier.dispose();

    brightnessNotifier.dispose();
    volumeNotifier.dispose();
    speedNotifier.dispose();
    isLoopNotifier.dispose();
    isMuteNotifier.dispose();

    mirrorModeNotifier.dispose();
    rotateModeNotifier.dispose();
    scaleModeNotifier.dispose();

    currentTrackInfoNotifier.dispose();
    trackInfoListNotifier.dispose();

    thumbnailNotifier.dispose();
  }

  /// 设置默认值
  Future<void> _batchLoadDefaultValues() async {
    // 核心任务
    // final coreResults = await Future.wait([]);

    // 非核心任务
    Future(() async {
      // TODO keria: brightness feature to be implemented
      double brightness = SettingConstants.defaultBrightness;
      brightnessNotifier.value = brightness;

      final nonCoreResults = await Future.wait([
        _aliPlayer.getVolume(),
        _aliPlayer.getRate(),
        _aliPlayer.isLoop(),
        _aliPlayer.isMuted(),
        _aliPlayer.getMirrorMode(),
        _aliPlayer.getRotateMode(),
        _aliPlayer.getScalingMode(),
      ]);

      volumeNotifier.value = nonCoreResults[0];
      speedNotifier.value = nonCoreResults[1];
      isLoopNotifier.value = nonCoreResults[2];
      isMuteNotifier.value = nonCoreResults[3];
      mirrorModeNotifier.value = nonCoreResults[4];
      rotateModeNotifier.value = nonCoreResults[5];
      scaleModeNotifier.value = nonCoreResults[6];
    });
  }

  /// 设置播放器视图
  ///
  /// Set the rendering view for the player.
  ///
  /// [playerViewId] The ID of the player view to be set.
  void _setPlayerView(int playerViewId) {
    logi("[player][api][setPlayerView]: ${_aliPlayer.hashCode}, $playerViewId");
    _aliPlayer.setPlayerView(playerViewId);
  }

  /// 配置播放控制器
  ///
  /// Configure the player controller with the given data.
  ///
  /// [data] The configuration data for the player, including video URL and other settings.
  void configure(AliPlayerWidgetData data) {
    if (data.videoUrl.isEmpty) {
      throw ArgumentError("Invalid video URL");
    }

    _widgetData = data;

    // 列表播放模式下，允许预渲染
    if (_widgetData?.sceneType == SceneType.listPlayer) {
      _aliPlayer.setOption(FlutterAvpdef.ALLOW_PRE_RENDER, 1);
    }

    _aliPlayer.setUrl(data.videoUrl);
    _aliPlayer.setStartTime(data.startTime, data.seekMode);
    _aliPlayer.setAutoPlay(data.autoPlay);

    // 准备播放
    prepare();
  }

  /// 准备播放
  ///
  /// Prepare the player for playback.
  void prepare() {
    logi("[player][api][prepare]: ${_aliPlayer.hashCode}");
    _aliPlayer.prepare();

    // 记录准备开始时间
    _prepareStartTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// 继续播放
  ///
  /// Start or resume playback of the player.
  void play() {
    logi("[player][api][play]: ${_aliPlayer.hashCode}");
    _aliPlayer.play();
  }

  /// 暂停播放
  ///
  /// Pause the player's playback.
  void pause() {
    logi("[player][api][pause]: ${_aliPlayer.hashCode}");
    _aliPlayer.pause();
  }

  /// 停止播放
  ///
  /// Stop the player's playback.
  void stop() {
    logi("[player][api][stop]: ${_aliPlayer.hashCode}");
    _aliPlayer.stop();
  }

  /// 切换播放状态
  ///
  /// Toggle between play and pause states.
  void togglePlayState() {
    final playState = playStateNotifier.value;
    logi("togglePlayState: $playState");

    if (playState == FlutterAvpdef.started) {
      pause();
    } else if (_isPrepared) {
      play();
    }
  }

  /// 重新播放
  ///
  /// Restart playback from the beginning.
  void replay() async {
    prepare();
    play();
  }

  /// 跳转播放位置
  ///
  /// Seek to a specific position in the video.
  ///
  /// [position] The target playback position.
  void seek(Duration position) {
    currentPositionNotifier.value = position;

    _aliPlayer.seekTo(
      position.inMilliseconds,
      _widgetData?.seekMode ?? FlutterAvpdef.ACCURATE,
    );
  }

  /// 设置播放速度
  ///
  /// Set the playback speed of the player.
  ///
  /// [speed] The target playback speed. Defaults to [SettingConstants.defaultSpeed].
  void setSpeed({double speed = SettingConstants.defaultSpeed}) async {
    // Validate the speed value.
    if (speed <= 0) {
      return;
    }

    await _aliPlayer.setRate(speed);

    speedNotifier.value = speed;
  }

  /// 设置亮度
  ///
  /// Set the brightness level of the player.
  ///
  /// [brightness] The target brightness value, clamped between 0 and 1.
  void setBrightness(double brightness) {
    final value = clampDouble(brightness, 0, 1);

    // TODO keria: brightness feature to be implemented
    logi("setBrightness: ${brightnessNotifier.value} -> $value");

    brightnessNotifier.value = value;
  }

  /// 设置亮度（增量）
  ///
  /// Adjust the brightness level by a delta value.
  ///
  /// [delta] The amount by which to adjust the brightness.
  void setBrightnessWithDelta(double delta) {
    final brightness = brightnessNotifier.value;
    final sum = brightness + delta;

    logi("setBrightnessWithDelta: $brightness, $delta, sum: $sum");

    setBrightness(sum);
  }

  /// 设置音量
  ///
  /// Set the volume level of the player.
  ///
  /// [volume] The target volume value, clamped between 0 and 1.
  void setVolume(double volume) async {
    final value = clampDouble(volume, 0, 1);

    await _aliPlayer.setVolume(value);
    double newValue = await _aliPlayer.getVolume();

    logi("setVolume: $volume, real: $newValue");

    volumeNotifier.value = newValue;
  }

  /// 设置音量（增量）
  ///
  /// Adjust the volume level by a delta value.
  ///
  /// [delta] The amount by which to adjust the volume.
  void setVolumeWithDelta(double delta) {
    final oldVolume = volumeNotifier.value;
    final sum = oldVolume + delta;

    logi("setVolumeWithDelta: $oldVolume, $delta, sum: $sum");

    setVolume(sum);
  }

  /// 设置循环播放
  ///
  /// Enable or disable loop playback.
  ///
  /// [loop] Whether to enable loop playback.
  Future<void> setLoop(bool loop) async {
    await _aliPlayer.setLoop(loop);
    bool newValue = await _aliPlayer.isLoop();

    logi("setLoop: $loop, real: $newValue");

    isLoopNotifier.value = newValue;
  }

  /// 设置静音
  ///
  /// Enable or disable mute mode.
  ///
  /// [mute] Whether to enable mute mode.
  Future<void> setMute(bool mute) async {
    await _aliPlayer.setMuted(mute);
    bool newValue = await _aliPlayer.isMuted();

    logi("setMute: $mute, real: $newValue");

    isMuteNotifier.value = newValue;
  }

  /// 设置镜像模式
  ///
  /// Set the mirror mode of the player.
  ///
  /// [mirrorMode] The target mirror mode.
  Future<void> setMirrorMode(int mirrorMode) async {
    await _aliPlayer.setMirrorMode(mirrorMode);
    int newValue = await _aliPlayer.getMirrorMode();

    logi("setMirrorMode: $mirrorMode, real: $newValue");

    mirrorModeNotifier.value = newValue;
  }

  /// 设置旋转角度
  ///
  /// Set the rotation angle of the player.
  ///
  /// [rotateMode] The target rotation angle.
  Future<void> setRotateMode(int rotateMode) async {
    await _aliPlayer.setRotateMode(rotateMode);
    int newValue = await _aliPlayer.getRotateMode();

    logi("setRotateMode: $rotateMode, real: $newValue");

    rotateModeNotifier.value = newValue;
  }

  /// 设置渲染填充模式
  ///
  /// Set the scaling mode of the player.
  ///
  /// [scaleMode] The target scaling mode.
  Future<void> setScaleMode(int scaleMode) async {
    await _aliPlayer.setScalingMode(scaleMode);
    int newValue = await _aliPlayer.getScalingMode();

    logi("setScaleMode: $scaleMode, real: $newValue");

    scaleModeNotifier.value = newValue;
  }

  /// 更新视频尺寸
  ///
  /// Update the video size based on the current media information.
  void _updateVideoSize() async {
    // 获取视频尺寸
    final videoWidth = await _aliPlayer.getVideoWidth() as int;
    final videoHeight = await _aliPlayer.getVideoHeight() as int;

    // 如果视频高度没有变化，则不更新视频尺寸
    final oldSize = videoSizeNotifier.value;
    if (videoHeight == oldSize.height && videoWidth == oldSize.width) {
      return;
    }

    // 如果视频尺寸发生变化，则更新视频尺寸
    final newSize = Size(
      videoWidth.toDouble(),
      videoHeight.toDouble(),
    );
    logi("_updateVideoSize: $oldSize -> $newSize");

    videoSizeNotifier.value = newSize;
  }

  /// 获取播放清晰度信息
  ///
  /// Retrieve and update the track information when the player is prepared.
  void _createTrackInfoWhenPrepared() async {
    // update track info list when player is prepared
    var mediaInfo = await _aliPlayer.getMediaInfo();
    var tracks = mediaInfo["tracks"];
    logi("_createTrackInfoWhenPrepared: $tracks");

    // 过滤出视频清晰度信息
    final trackInfoList = TrackInfoUtil.filterVideoTrackInfoList(tracks);
    final trackInfo = (trackInfoList.isNotEmpty) ? trackInfoList.first : null;

    // 更新当前清晰度信息
    trackInfoListNotifier.value = trackInfoList;
    currentTrackInfoNotifier.value = trackInfo;
  }

  /// 切换清晰度
  ///
  /// Switch to a specific track for playback.
  ///
  /// [trackInfo] The target track information.
  void selectTrack(AVPTrackInfo? trackInfo) {
    if (trackInfo == null || trackInfo.trackIndex == null) {
      return;
    }

    // 切换清晰度
    _aliPlayer.selectTrack(
      trackInfo.trackIndex!,
      accurate: 1,
    );

    // 显示清晰度信息
    String quality = TrackInfoUtil.getQuality(trackInfo);
    SnackBarUtil.show(_context, "selectTrack: $quality");
  }

  /// 创建缩略图（方式1）
  ///
  /// Create a thumbnail using method 1 (external URL).
  void _createThumbnailWhenPrepared() {
    // 如果外部配置了缩略图地址，则使用方式1创建缩略图
    if (_widgetData == null || _widgetData!.thumbnailUrl.isEmpty) {
      return;
    }

    // 创建缩略图
    _aliPlayer.createThumbnailHelper(_widgetData!.thumbnailUrl);
  }

  /// 创建缩略图（方式2）
  ///
  /// Create a thumbnail using method 2 (media info).
  void _createThumbnailWhenTrackReady() {
    if (_widgetData != null && _widgetData!.thumbnailUrl.isNotEmpty) {
      // 如果外部配置了缩略图地址，则使用方式1创建缩略图
      return;
    }
    _aliPlayer.getMediaInfo().then((value) {
      final thumbnails = value['thumbnails'];
      if (thumbnails?.isNotEmpty ?? false) {
        _aliPlayer.createThumbnailHelper(thumbnails[0]['url']);
      } else {
        _thumbnailSuccess = false;
      }
    });
  }

  /// 请求缩略图
  ///
  /// Request a thumbnail bitmap at a specific position.
  ///
  /// [position] The target playback position for the thumbnail.
  void requestThumbnailBitmap(Duration position) {
    if (_thumbnailSuccess) {
      _aliPlayer.requestBitmapAtPosition(position.inMilliseconds);
    }
  }

  /// Flutter Widget 版本号
  static const String _kWidgetVersion = '7.0.0';

  /// 获取 Flutter Widget 版本号
  ///
  /// Get Flutter Widget version
  static Future<String> getWidgetVersion() async {
    return _kWidgetVersion;
  }

  /// 清除 Widget 缓存
  ///
  /// Clear widget cache
  static Future<void> clearCaches() async {
    // 清除视频缓存
    await FlutterAliplayer.clearCaches();

    // 清除图片缓存
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}

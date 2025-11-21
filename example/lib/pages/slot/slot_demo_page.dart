// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/14
// Brief: 插槽系统演示页面

import 'package:aliplayer_widget_example/constants/demo_constants.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:aliplayer_widget_example/pages/link/link_constants.dart';
import 'package:aliplayer_widget_example/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

/// 插槽系统演示页面
///
/// 展示如何使用插槽系统自定义播放器界面
///
/// A demo page for using the slot system to customize the player interface.
class SlotDemoPage extends StatefulWidget {
  const SlotDemoPage({super.key});

  @override
  State<SlotDemoPage> createState() => _SlotDemoPageState();
}

/// 自定义UI样式类型
enum CustomUIStyle {
  /// 现代风格
  modern,

  /// 经典风格
  classic,

  /// 极简风格
  minimal
}

class _SlotDemoPageState extends State<SlotDemoPage>
    with TickerProviderStateMixin {
  /// 播放器组件控制器
  late AliPlayerWidgetController _controller;

  /// 是否使用自定义UI
  bool _useCustomUI = false;

  /// 自定义UI样式
  CustomUIStyle _uiStyle = CustomUIStyle.modern;

  /// 当前播放速度
  double _currentSpeed = 1.0;

  /// 初始化状态
  /// StatefulWidget 的状态类中第一个被调用的方法，用于初始化状态，可以执行一些一次性的初始化工作
  ///
  /// Called when the state is first created. Used for one-time initialization.
  @override
  void initState() {
    super.initState();

    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);

    // 获取保存的链接
    var savedLink = SPManager.instance.getString(LinkConstants.url);
    // 如果没有保存的链接，则使用默认链接
    if (savedLink == null || savedLink.isEmpty) {
      savedLink = DemoConstants.sampleVideoUrl;
    }

    // 设置播放器视频源
    final videoSource = VideoSourceFactory.createUrlSource(savedLink);
    // 设置播放器组件数据
    final data = AliPlayerWidgetData(
      videoSource: videoSource,
      videoTitle: "插槽系统演示视频",
    );
    _controller.configure(data);
  }

  /// 清理资源
  ///
  /// Called when the widget is removed from the tree permanently. Used to release resources.
  @override
  void dispose() {
    // 销毁播放控制器
    _controller.destroy();

    super.dispose();
  }

  /// 构建主体内容
  ///
  /// Builds the UI of the demo page, including an AppBar and the AliPlayer widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("插槽系统演示"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _useCustomUI ? _buildCustomPlayerWidget() : _buildDefaultPlayerWidget(),
        Expanded(
          flex: 1,
          child: _buildControlPanel(),
        ),
      ],
    );
  }

  /// 构建默认播放器组件
  Widget _buildDefaultPlayerWidget() {
    return AliPlayerWidget(
      _controller,
    );
  }

  /// 构建自定义播放器组件
  Widget _buildCustomPlayerWidget() {
    return AliPlayerWidget(
      _controller,
      slotBuilders: {
        // 自定义顶部栏
        SlotType.topBar: (context) => _buildCustomTopBar(),

        // 自定义底部栏
        SlotType.bottomBar: (context) => _buildCustomBottomBar(),

        // 自定义播放控制
        SlotType.playControl: (context) => _buildCustomPlayControl(),
      },
    );
  }

  /// 构建自定义顶部栏
  Widget _buildCustomTopBar() {
    switch (_uiStyle) {
      case CustomUIStyle.modern:
        return _buildModernTopBar();
      case CustomUIStyle.classic:
        return _buildClassicTopBar();
      case CustomUIStyle.minimal:
        return _buildMinimalTopBar();
    }
  }

  /// 现代风格顶部栏
  Widget _buildModernTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Text(
              "现代风格",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 经典风格顶部栏
  Widget _buildClassicTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Text(
              "经典风格",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 极简风格顶部栏
  Widget _buildMinimalTopBar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Text(
            "极简风格",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  /// 构建自定义底部栏
  Widget _buildCustomBottomBar() {
    switch (_uiStyle) {
      case CustomUIStyle.modern:
        return _buildModernBottomBar();
      case CustomUIStyle.classic:
        return _buildClassicBottomBar();
      case CustomUIStyle.minimal:
        return _buildMinimalBottomBar();
    }
  }

  /// 现代风格底部栏
  Widget _buildModernBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: _seekBackward,
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _controller.playStateNotifier,
                builder: (context, playState, child) {
                  return IconButton(
                    iconSize: 32,
                    icon: Icon(
                      playState == FlutterAvpdef.started
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _controller.togglePlayState,
                  );
                },
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: _seekForward,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 经典风格底部栏
  Widget _buildClassicBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: _controller.playStateNotifier,
          builder: (context, playState, child) {
            return Row(
              children: [
                // 播放/暂停按钮
                _buildControlButton(
                  icon: playState == FlutterAvpdef.started
                      ? Icons.pause
                      : Icons.play_arrow,
                  onPressed: _controller.togglePlayState,
                ),
                const SizedBox(width: 12),

                // 当前时间
                ValueListenableBuilder<Duration>(
                  valueListenable: _controller.currentPositionNotifier,
                  builder: (context, position, child) {
                    return Text(
                      _formatDuration(position),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
                const SizedBox(width: 12),

                // 进度条
                Expanded(child: _buildProgressSlider()),
                const SizedBox(width: 12),

                // 总时长
                ValueListenableBuilder<Duration>(
                  valueListenable: _controller.totalDurationNotifier,
                  builder: (context, duration, child) {
                    return Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressSlider() {
    return ValueListenableBuilder<Duration>(
      valueListenable: _controller.currentPositionNotifier,
      builder: (context, currentPosition, child) {
        return ValueListenableBuilder<Duration>(
          valueListenable: _controller.totalDurationNotifier,
          builder: (context, totalDuration, child) {
            final progress = totalDuration.inMilliseconds > 0
                ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
                : 0.0;

            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Colors.orangeAccent,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
                overlayColor: Colors.orangeAccent.withOpacity(0.2),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  final position = Duration(
                    milliseconds:
                        (totalDuration.inMilliseconds * value).toInt(),
                  );
                  _controller.seek(position);
                },
              ),
            );
          },
        );
      },
    );
  }

  /// 格式化时长显示
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 极简风格底部栏
  Widget _buildMinimalBottomBar() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: _controller.playStateNotifier,
              builder: (context, playState, child) {
                return IconButton(
                  icon: Icon(
                    playState == FlutterAvpdef.started
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _controller.togglePlayState,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建自定义播放控制
  Widget _buildCustomPlayControl() {
    return GestureDetector(
      onTap: _controller.togglePlayState,
      child: Container(
        color: Colors.transparent,
        child: const SizedBox.expand(),
      ),
    );
  }

  /// 设置为正常速度
  void _setNormalSpeed() {
    setState(() {
      _currentSpeed = 1.0;
      _controller.setSpeed();
    });
    ToastUtils.showMessage(context, '已恢复为正常速度');
  }

  /// 后退10秒
  void _seekBackward() {
    final currentPosition = _controller.currentPositionNotifier.value;
    final targetPosition = currentPosition - const Duration(seconds: 10);

    if (targetPosition.isNegative) {
      _controller.seek(Duration.zero);
    } else {
      _controller.seek(targetPosition);
    }

    ToastUtils.showMessage(context, '后退10秒');
  }

  /// 前进10秒
  void _seekForward() {
    final currentPosition = _controller.currentPositionNotifier.value;
    final totalDuration = _controller.totalDurationNotifier.value;
    final targetPosition = currentPosition + const Duration(seconds: 10);

    if (targetPosition > totalDuration) {
      _controller.seek(totalDuration);
    } else {
      _controller.seek(targetPosition);
    }

    ToastUtils.showMessage(context, '前进10秒');
  }

  /// 设置为二倍速
  void _setDoubleSpeed() {
    setState(() {
      _currentSpeed = 2.0;
      _controller.setSpeed(speed: 2.0);
    });

    ToastUtils.showMessage(context, '已设置为2倍速播放');
  }

  /// 切换UI样式
  void _switchUIStyle(CustomUIStyle style) {
    setState(() {
      _uiStyle = style;
      _useCustomUI = true; // 选择样式时自动启用自定义UI
    });
  }

  /// 构建控制面板
  Widget _buildControlPanel() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "插槽系统功能演示：",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "• 顶部栏、底部栏、播放控制等UI组件可完全自定义\n"
              "• 可以选择隐藏任意组件\n"
              "• 可以在Widget外部通过Notifier控制播放器",
            ),
            const SizedBox(height: 16),

            // UI样式选择（同时控制UI模式）
            const Text(
              "选择UI样式：",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('现代'),
                  selected: _uiStyle == CustomUIStyle.modern && _useCustomUI,
                  onSelected: (_) => _switchUIStyle(CustomUIStyle.modern),
                ),
                ChoiceChip(
                  label: const Text('经典'),
                  selected: _uiStyle == CustomUIStyle.classic && _useCustomUI,
                  onSelected: (_) => _switchUIStyle(CustomUIStyle.classic),
                ),
                ChoiceChip(
                  label: const Text('极简'),
                  selected: _uiStyle == CustomUIStyle.minimal && _useCustomUI,
                  onSelected: (_) => _switchUIStyle(CustomUIStyle.minimal),
                ),
                ChoiceChip(
                  label: const Text('默认'),
                  selected: !_useCustomUI,
                  onSelected: (_) {
                    setState(() {
                      _useCustomUI = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 控制按钮
            const Text(
              "播放控制：",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: _controller.togglePlayState,
                  icon: ValueListenableBuilder<int>(
                    valueListenable: _controller.playStateNotifier,
                    builder: (context, playState, child) {
                      return Icon(
                        playState == FlutterAvpdef.started
                            ? Icons.pause
                            : Icons.play_arrow,
                      );
                    },
                  ),
                  label: const Text("播放/暂停"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.replay();
                  },
                  child: const Text("重新播放"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 倍速控制按钮（分开展示）
            const Text(
              "播放速度控制：",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: _setNormalSpeed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentSpeed == 1.0
                        ? Colors.orangeAccent
                        : Colors.grey[300],
                  ),
                  child: const Text("正常速度"),
                ),
                ElevatedButton(
                  onPressed: _setDoubleSpeed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentSpeed == 2.0
                        ? Colors.orangeAccent
                        : Colors.grey[300],
                  ),
                  child: const Text("二倍速"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              "当前模式：",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_useCustomUI ? "自定义UI模式 ($_uiStyle)" : "默认UI模式"),
            Text("当前速度: ${_currentSpeed}x"),
          ],
        ),
      ),
    );
  }
}

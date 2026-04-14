// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/14
// Brief: 插槽系统演示页面

import 'package:aliplayer_widget/slot/slot_elements.dart';
import 'package:aliplayer_widget/utils/full_screen_util.dart';
import 'package:aliplayer_widget_example/constants/demo_constants.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:aliplayer_widget_example/pages/link/link_constants.dart';
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

  /// 细粒度控制（支持按需隐藏默认插槽中的 UI 元素）
  fineGrained,
}

class _SlotDemoPageState extends State<SlotDemoPage>
    with TickerProviderStateMixin {
  /// 播放器组件控制器
  ///
  /// 用于页面生命周期管理（初始化、销毁）。
  /// 注意：slotBuilder 内部的播放控制应使用传入的 controller 参数，而非此控制器。
  ///
  /// Page-level controller for lifecycle management.
  /// Note: Use the controller parameter passed to slotBuilders for playback controls.
  late AliPlayerWidgetController _controller;

  /// 是否使用自定义UI
  bool _useCustomUI = false;

  /// 自定义UI样式
  CustomUIStyle _uiStyle = CustomUIStyle.modern;

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
        _buildPlayerWidgetByStyle(),
        Expanded(
          flex: 1,
          child: _buildControlPanel(),
        ),
      ],
    );
  }

  /// 根据样式构建播放器组件
  Widget _buildPlayerWidgetByStyle() {
    // 如果不使用自定义UI，则返回默认播放器组件
    if (!_useCustomUI) {
      return _buildDefaultPlayerWidget();
    }
    // 如果使用细粒度控制，则返回细粒度控制的播放器组件
    if (_uiStyle == CustomUIStyle.fineGrained) {
      return _buildFineGrainedPlayerWidget();
    }
    // 否则返回自定义播放器组件
    return _buildCustomPlayerWidget();
  }

  /// 构建默认播放器组件
  Widget _buildDefaultPlayerWidget() {
    return AliPlayerWidget(
      _controller,
    );
  }

  /// 构建细粒度控制的播放器组件
  Widget _buildFineGrainedPlayerWidget() {
    return AliPlayerWidget(
      _controller,
      hiddenSlotElements: const {
        // 演示：隐藏顶部栏插槽中的 UI 元素
        SlotType.topBar: {
          TopBarElements.download,
          TopBarElements.snapshot,
        },
        // 演示：隐藏底部栏插槽的 UI 元素
        SlotType.bottomBar: {
          BottomBarElements.progress,
        },
        // 演示：隐藏设置菜单插槽的 UI 元素
        SlotType.settingMenu: {
          SettingMenuElements.speed,
          SettingMenuElements.mute,
        },
        // 演示：禁用播放控制插槽的手势交互
        SlotType.playControl: {
          PlayControlElements.doubleTap,
          PlayControlElements.leftVerticalDrag,
          PlayControlElements.rightVerticalDrag,
        },
      },
    );
  }

  /// 构建自定义播放器组件
  ///
  /// 重要：slotBuilder 接收 controller 参数，用于全屏模式兼容。
  /// 在 slotBuilder 内部必须使用传入的 controller，而非 _controller。
  Widget _buildCustomPlayerWidget() {
    return AliPlayerWidget(
      _controller,
      slotBuilders: _getSlotBuilders(),
    );
  }

  // ============================================================
  // slotBuilder 相关方法 - 必须使用传入的 controller 参数
  // ============================================================

  /// 构建自定义顶部栏
  Widget _buildCustomTopBar(AliPlayerWidgetController controller) {
    switch (_uiStyle) {
      case CustomUIStyle.modern:
        return _buildModernTopBar(controller);
      case CustomUIStyle.classic:
        return _buildClassicTopBar(controller);
      case CustomUIStyle.fineGrained:
        return const SizedBox.shrink(); // 不会被调用
    }
  }

  /// 现代风格顶部栏
  Widget _buildModernTopBar(AliPlayerWidgetController controller) {
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
                onPressed: () => _onBackPressed(controller),
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
  Widget _buildClassicTopBar(AliPlayerWidgetController controller) {
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
              onPressed: () => _onBackPressed(controller),
            ),
          ),
          const Text(
            "经典风格",
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
  Widget _buildCustomBottomBar(AliPlayerWidgetController controller) {
    switch (_uiStyle) {
      case CustomUIStyle.modern:
        return _buildModernBottomBar(controller);
      case CustomUIStyle.classic:
        return _buildClassicBottomBar(controller);
      case CustomUIStyle.fineGrained:
        return const SizedBox.shrink(); // 不会被调用
    }
  }

  /// 现代风格底部栏
  ///
  /// 播放控制逻辑直接写在 slotBuilder 内部，使用传入的 controller。
  /// 这确保了全屏模式下控制正常工作。
  Widget _buildModernBottomBar(AliPlayerWidgetController controller) {
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
            // 后退10秒按钮
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () {
                  final pos = controller.currentPositionNotifier.value;
                  final target = pos - const Duration(seconds: 10);
                  controller.seek(target.isNegative ? Duration.zero : target);
                },
              ),
            ),
            // 播放/暂停按钮
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
                valueListenable: controller.playStateNotifier,
                builder: (context, playState, child) {
                  return IconButton(
                    iconSize: 32,
                    icon: Icon(
                      playState == FlutterAvpdef.started
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: controller.togglePlayState,
                  );
                },
              ),
            ),
            // 前进10秒按钮
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () {
                  final pos = controller.currentPositionNotifier.value;
                  final total = controller.totalDurationNotifier.value;
                  final target = pos + const Duration(seconds: 10);
                  controller.seek(target > total ? total : target);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 经典风格底部栏
  Widget _buildClassicBottomBar(AliPlayerWidgetController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: controller.playStateNotifier,
          builder: (context, playState, child) {
            return Row(
              children: [
                // 播放/暂停按钮
                _buildClassicControlButton(
                  icon: playState == FlutterAvpdef.started
                      ? Icons.pause
                      : Icons.play_arrow,
                  onPressed: controller.togglePlayState,
                ),
                const SizedBox(width: 8),

                // 当前时间
                ValueListenableBuilder<Duration>(
                  valueListenable: controller.currentPositionNotifier,
                  builder: (context, position, child) {
                    return Text(
                      _formatDuration(position),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // 进度条
                Expanded(child: _buildClassicProgressSlider(controller)),
                const SizedBox(width: 8),

                // 总时长
                ValueListenableBuilder<Duration>(
                  valueListenable: controller.totalDurationNotifier,
                  builder: (context, duration, child) {
                    return Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // 全屏按钮
                _buildClassicControlButton(
                  icon: Icons.fullscreen,
                  onPressed: () => controller.toggleFullscreen(
                    slotBuilders: _getSlotBuilders(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建经典风格控制按钮
  Widget _buildClassicControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// 构建经典风格进度条
  Widget _buildClassicProgressSlider(AliPlayerWidgetController controller) {
    return ValueListenableBuilder<Duration>(
      valueListenable: controller.currentPositionNotifier,
      builder: (context, currentPosition, child) {
        return ValueListenableBuilder<Duration>(
          valueListenable: controller.totalDurationNotifier,
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
                  controller.seek(position);
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

  /// 构建自定义播放控制
  Widget _buildCustomPlayControl(AliPlayerWidgetController controller) {
    return GestureDetector(
      onTap: controller.togglePlayState,
      child: Container(
        color: Colors.transparent,
        child: const SizedBox.expand(),
      ),
    );
  }

  /// 处理返回按钮点击
  ///
  /// 全屏模式下退出全屏，非全屏模式下退出页面
  void _onBackPressed(AliPlayerWidgetController controller) {
    if (FullScreenUtil.isFullScreen()) {
      // 全屏模式：退出全屏
      controller.exitFullScreen();
    } else {
      // 非全屏模式：退出页面
      Navigator.of(context).pop();
    }
  }

  /// 获取当前样式的 slotBuilders 配置
  Map<SlotType, Function?> _getSlotBuilders() {
    return {
      SlotType.topBar: (context, ctrl) => _buildCustomTopBar(ctrl),
      SlotType.bottomBar: (context, ctrl) => _buildCustomBottomBar(ctrl),
      SlotType.playControl: (context, ctrl) => _buildCustomPlayControl(ctrl),
    };
  }

  // ============================================================
  // 页面级方法 - UI 样式切换等非播放控制功能
  // ============================================================

  /// 切换UI样式
  void _switchUIStyle(CustomUIStyle style) {
    setState(() {
      _uiStyle = style;
      _useCustomUI = true; // 选择样式时自动启用自定义UI
    });
  }

  /// 构建控制面板
  ///
  /// 注意：此面板在非全屏时显示。
  /// 所有播放控制（play/pause/seek）应放在 slotBuilder 内部，
  /// 这样全屏时才能正常工作。
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
              "• 插槽化设计：播放器界面拆分为多个可组合区域\n"
              "• 灵活自定义：顶部栏、底部栏等插槽支持完全自定义\n"
              "• 细粒度控制：支持按需隐藏默认插槽中的 UI 元素\n"
              "• 全屏兼容：slotBuilder 使用 controller 参数确保全屏模式正常",
            ),
            const SizedBox(height: 16),

            // UI样式选择
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
                  label: const Text('细粒度控制'),
                  selected:
                      _uiStyle == CustomUIStyle.fineGrained && _useCustomUI,
                  onSelected: (_) => _switchUIStyle(CustomUIStyle.fineGrained),
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

            const Text(
              "当前模式：",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_useCustomUI ? "自定义UI模式 ($_uiStyle)" : "默认UI模式"),

            const SizedBox(height: 16),

            // 使用说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "重要提示",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "在 slotBuilder 中进行播放控制时，请务必使用传入的 controller 参数，以确保在全屏模式下能够正常工作。\n"
                    "请避免使用外部捕获的 controller。",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

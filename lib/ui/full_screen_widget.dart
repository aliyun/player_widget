// Copyright © 2025 Alibaba Cloud. All rights reserved.

// @author junHuiYe
// @date 2025/6/4 17:59
// @brief 全屏模式UI控件

part of 'package:aliplayer_widget/aliplayer_widget_lib.dart';

/// 播放器全屏视图
///
/// 纯全屏壳：只负责全屏特有逻辑（屏幕方向、系统 UI、返回键处理）。
/// 不关心内容物的参数，由调用方组装 [child]。
/// 不创建新控制器、不 configure、不销毁控制器（控制器归 AliPlayerWidget 管理）。
///
/// Fullscreen shell widget that handles orientation, system UI, and back button.
/// Content is provided via [child] by the caller.
class FullScreenWidget extends StatefulWidget {
  /// 共享的播放器控制器（用于退出全屏状态切换）
  final AliPlayerWidgetController controller;

  /// 全屏显示的内容
  final Widget child;

  const FullScreenWidget({
    required this.controller,
    required this.child,
    super.key,
  });

  @override
  State<FullScreenWidget> createState() => FullScreenWidgetState();
}

class FullScreenWidgetState extends State<FullScreenWidget> {
  @override
  void initState() {
    super.initState();
    // using FullScreenUtil to handle full-screen system UI settings (orientation, system UI)
    FullScreenUtil.enterFullScreen();
  }

  @override
  void dispose() {
    // 不在 dispose 中恢复屏幕方向
    // 屏幕方向恢复由 AliPlayerWidget._pushFullScreenWidget() 在 pop 返回后处理
    // 避免异步操作与 Navigator.pop 和 Widget 重建的竞态条件
    logi("[lifecycle] dispose");
    super.dispose();
  }

  /// 处理返回按钮事件（路由 pop 由竖屏 listener 统一处理）
  void _handleBackPress() {
    widget.controller.exitFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return; // 如果已经处理了返回操作，则直接返回
        }
        // 处理返回事件：退出全屏并同步状态
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: OrientationBuilder(
          builder: (context, orientation) {
            // 降级策略：设备未旋转（仍为竖屏）时，手动旋转内容
            // 适用于 iPhone 7P 等 setPreferredOrientations 不可靠的旧设备
            //
            // 重要：始终保持相同的 widget 树结构（RotatedBox > SizedBox > MediaQuery > child），
            // 避免方向切换时 if/else 分支导致 child 在树中位置变化，
            // 引起 AliPlayerWidget State 重建和 PlatformView 重新创建。
            final needsRotation = orientation == Orientation.portrait;
            final size = MediaQuery.of(context).size;
            final effectiveSize =
                needsRotation ? Size(size.height, size.width) : size;
            return Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: RotatedBox(
                quarterTurns: needsRotation ? 1 : 0,
                child: SizedBox(
                  width: effectiveSize.width,
                  height: effectiveSize.height,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(size: effectiveSize),
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

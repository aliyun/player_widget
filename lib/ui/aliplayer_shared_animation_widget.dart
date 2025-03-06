// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/18
// Brief: 共享动画组件

import 'package:aliplayer_widget/manager/shared_animation_manager.dart';
import 'package:flutter/material.dart';

/// 共享动画组件
///
/// Abstract base class for creating widgets with shared animations.
abstract class AliPlayerSharedAnimationWidget extends StatefulWidget {
  /// 共享动画控制器
  final SharedAnimationManager animationManager;

  /// 构造函数
  const AliPlayerSharedAnimationWidget({
    super.key,
    required this.animationManager,
  });

  /// 子类需要实现的方法：构建主体内容
  Widget buildContent(BuildContext context);

  @override
  State<AliPlayerSharedAnimationWidget> createState() =>
      _AliPlayerSharedAnimationWidgetState();
}

class _AliPlayerSharedAnimationWidgetState
    extends State<AliPlayerSharedAnimationWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildAnimatedContent(context);
  }

  /// 构建带有透明度动画的内容
  ///
  /// Build content with optimized fade-in/fade-out animation.
  Widget _buildAnimatedContent(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationManager.opacityAnimation,
      builder: (context, child) {
        final opacity = widget.animationManager.opacityAnimation.value;

        // 如果完全隐藏，则不构建子组件
        if (opacity == 0.0) {
          return const SizedBox.shrink();
        }

        // 使用 FadeTransition 实现渐隐渐显效果
        return FadeTransition(
          opacity: AlwaysStoppedAnimation(opacity), // 使用固定的透明度值
          child: IgnorePointer(
            ignoring: !widget.animationManager.isVisible,
            child: child,
          ),
        );
      },
      child: widget.buildContent(context),
    );
  }
}

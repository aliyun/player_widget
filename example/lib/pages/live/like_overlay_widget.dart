// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/5/8
// Brief: 点赞覆盖层组件

import 'dart:math';

import 'package:flutter/material.dart';

/// 点赞覆盖层组件（自管理状态，不依赖父组件 rebuild）
///
/// 使用 [Listener] 在指针层级检测连击，不参与手势竞争，
/// 不影响下层播放器控制栏的正常交互。
class LikeOverlayWidget extends StatefulWidget {
  const LikeOverlayWidget({super.key});

  @override
  State<LikeOverlayWidget> createState() => _LikeOverlayWidgetState();
}

class _LikeOverlayWidgetState extends State<LikeOverlayWidget> {
  final List<_LikeAnimationItem> _likeAnimations = [];
  DateTime? _lastTapTime;

  /// 同时存在的最大动画数量上限
  static const int _maxConcurrentAnimations = 15;

  /// 单调递增 ID，避免时间戳碰撞
  int _idCounter = 0;

  /// 连击检测阈值
  static const int _doubleTapThresholdMs = 300;

  /// 连击检测：两次按下间隔 < 阈值即触发点赞
  void _onPointerDown() {
    final now = DateTime.now();
    final lastTap = _lastTapTime;
    _lastTapTime = now;

    if (lastTap != null &&
        now.difference(lastTap).inMilliseconds < _doubleTapThresholdMs) {
      _triggerLike();
    }
  }

  void _triggerLike() {
    if (_likeAnimations.length >= _maxConcurrentAnimations) return;
    setState(() {
      _likeAnimations.add(_LikeAnimationItem(
        id: _idCounter++,
        offsetX: Random().nextDouble() * 60 - 30,
      ));
    });
  }

  void _removeLikeAnimation(int id) {
    setState(() {
      _likeAnimations.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onPointerDown(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const SizedBox.expand(),
          ..._likeAnimations.map(
            (item) => _LikeAnimationWidget(
              key: ValueKey(item.id),
              item: item,
              onComplete: () => _removeLikeAnimation(item.id),
            ),
          ),
        ],
      ),
    );
  }
}

/// 点赞动画数据项
class _LikeAnimationItem {
  final int id;
  final double offsetX;

  _LikeAnimationItem({required this.id, required this.offsetX});
}

/// 点赞动画组件（上浮 + 缩放 + 渐隐）
class _LikeAnimationWidget extends StatefulWidget {
  final _LikeAnimationItem item;
  final VoidCallback onComplete;

  const _LikeAnimationWidget({
    super.key,
    required this.item,
    required this.onComplete,
  });

  @override
  State<_LikeAnimationWidget> createState() => _LikeAnimationWidgetState();
}

class _LikeAnimationWidgetState extends State<_LikeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
    _positionAnimation = Tween<double>(begin: 0.0, end: -150.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment.bottomRight,
          child: Transform.translate(
            offset: Offset(
              -(40 + widget.item.offsetX),
              -80 + _positionAnimation.value,
            ),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: const Icon(
        Icons.favorite,
        color: Colors.redAccent,
        size: 40,
      ),
    );
  }
}

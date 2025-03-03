// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/14
// Brief: 共享动画控制器管理类

import 'package:flutter/material.dart';

/// 共享动画控制器管理类
class SharedAnimationManager with ChangeNotifier {
  /// 透明度动画持续时间，单位为毫秒
  static const int _opacityAnimationDuration = 300;

  /// 动画控制器
  late AnimationController _animationController;

  /// 透明度动画
  late Animation<double> _opacityAnimation;

  /// 构造函数，初始化动画控制器和透明度动画。
  ///
  /// Constructor to initialize the animation controller and opacity animation.
  ///
  /// 参数：
  /// - [vsync]：TickerProvider，用于同步动画帧，通常由 State 对象提供。
  ///
  /// Parameters:
  /// - vsync: TickerProvider used to synchronize animation frames, typically provided by a State object.
  SharedAnimationManager(TickerProvider vsync) {
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: _opacityAnimationDuration),
    );

    // 初始化透明度动画
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  /// 获取透明度动画
  ///
  /// Get opacity animation.
  Animation<double> get opacityAnimation => _opacityAnimation;

  /// 显示动画
  ///
  /// Show animation.
  void show() {
    if (!_animationController.isCompleted) {
      _animationController.forward();
      notifyListeners(); // 通知监听者
    }
  }

  /// 隐藏动画
  ///
  /// Hide animation.
  void hide() {
    if (!_animationController.isDismissed) {
      _animationController.reverse();
      notifyListeners(); // 通知监听者
    }
  }

  /// 是否可见
  ///
  /// Whether visible or not.
  bool get isVisible => _animationController.value > 0.0;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

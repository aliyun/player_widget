// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/5/8
// Brief: First frame timing strategy

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/utils/log_util.dart';

/// 首帧耗时统计策略
///
/// 监听 prepare/prepared/rendered 事件，统计关键节点耗时：
/// - prepare → prepared：数据源准备耗时，通过 [onPrepared] 回调
/// - prepare → rendered：首帧渲染总耗时，通过 [onFirstFrame] 回调
///
/// First frame timing strategy.
///
/// Monitors prepare/prepared/rendered events to measure key timing:
/// - prepare → prepared: data source preparation cost, via [onPrepared]
/// - prepare → rendered: total first frame cost, via [onFirstFrame]
class FirstFrameStrategy extends BasePlayerStrategy {
  /// 数据源准备完成回调
  ///
  /// Called when player prepared, with elapsed duration from prepare() call.
  final void Function(Duration cost)? onPrepared;

  /// 首帧渲染完成回调
  ///
  /// Called when the first frame is rendered, with elapsed duration from prepare() call.
  final void Function(Duration cost)? onFirstFrame;

  /// 内部状态
  int _prepareStartTime = 0;
  bool _preparedCompleted = false;
  bool _firstFrameCompleted = false;

  /// 创建首帧耗时统计策略
  ///
  /// [onPrepared] Optional callback invoked when player is prepared.
  /// [onFirstFrame] Optional callback invoked when the first frame is rendered.
  FirstFrameStrategy({this.onPrepared, this.onFirstFrame});

  @override
  String get name => 'FirstFrameStrategy';

  @override
  void onStart(AliPlayerWidgetController controller) {
    // 监听 prepare 事件，自行记录时间戳
    listen<int>(controller.prepareNotifier, (_) {
      _prepareStartTime = DateTime.now().millisecondsSinceEpoch;
      _preparedCompleted = false;
      _firstFrameCompleted = false;
    });

    // 监听 prepared 状态，统计数据源准备耗时
    listen<bool>(controller.isPreparedNotifier, (isPrepared) {
      if (isPrepared && !_preparedCompleted && _prepareStartTime > 0) {
        _preparedCompleted = true;
        final now = DateTime.now().millisecondsSinceEpoch;
        final cost = Duration(milliseconds: now - _prepareStartTime);
        logi('Player prepared, cost: ${cost.inMilliseconds}ms', tag: name);
        onPrepared?.call(cost);
      }
    });

    // 监听渲染状态，捕获首帧时刻
    listen<bool>(controller.isRenderedNotifier, (isRendered) {
      if (isRendered && !_firstFrameCompleted && _prepareStartTime > 0) {
        _firstFrameCompleted = true;
        final now = DateTime.now().millisecondsSinceEpoch;
        final cost = Duration(milliseconds: now - _prepareStartTime);
        logi('First frame rendered, cost: ${cost.inMilliseconds}ms', tag: name);
        onFirstFrame?.call(cost);
      }
    });
  }

  @override
  void onReset() {
    _prepareStartTime = 0;
    _preparedCompleted = false;
    _firstFrameCompleted = false;
  }
}

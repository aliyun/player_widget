// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// @author junHuiYe
// @date 2025/7/15 10:29
// Brief: 播放器字幕插槽组件

import 'package:flutter/material.dart';
import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

/// 外挂字幕插槽组件
///
/// [SubtitleWidget] is a widget that displays external subtitles.
class SubtitleWidget extends StatefulWidget {
  /// 外挂字幕显示
  final bool subtitleOn;
  final Subtitles? subtitles;
  final int? trackIndex;

  /// 字幕配置
  final SubtitleConfig config;

  /// 字幕构建器
  final SubtitleBuilder? subtitleBuilder;

  const SubtitleWidget({
    super.key,
    required this.subtitleOn,
    required this.subtitles,
    required this.trackIndex,
    this.config = const SubtitleConfig(),
    this.subtitleBuilder,
  });

  @override
  State<SubtitleWidget> createState() => _SubtitleWidgetState();
}

class _SubtitleWidgetState extends State<SubtitleWidget> {
  late SubtitleBuilder _effectiveBuilder;

  @override
  void initState() {
    super.initState();
    _initializeBuilder();
  }

  @override
  void didUpdateWidget(SubtitleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtitleBuilder != widget.subtitleBuilder) {
      _initializeBuilder();
    }
  }

  void _initializeBuilder() {
    if (widget.subtitleBuilder != null) {
      _effectiveBuilder = widget.subtitleBuilder!;
    } else {
      _effectiveBuilder = DefaultSubtitleBuilder();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.subtitleOn) {
      return const SizedBox.shrink();
    }

    if (widget.trackIndex == null || widget.trackIndex! < 0) {
      return const SizedBox.shrink();
    }

    final currentSubtitles =
        widget.subtitles?.getByTrackIndex(widget.trackIndex!);

    if (currentSubtitles == null || currentSubtitles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: widget.config.position.bottom,
      left: widget.config.position.left,
      right: widget.config.position.right,
      child: _buildAllSubtitles(currentSubtitles),
    );
  }

  /// 构建所有字幕的显示
  Widget _buildAllSubtitles(List<Subtitle> subtitles) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: subtitles
            .map((subtitle) => _buildSingleSubtitle(subtitle))
            .toList(),
      ),
    );
  }

  /// 构建单个字幕
  Widget _buildSingleSubtitle(Subtitle subtitle) {
    return _effectiveBuilder.build(
      context,
      subtitle,
      widget.config,
    );
  }
}

/// 构建外挂字幕插槽的默认实现。
/// Builds the default subtitle slot content.
///
/// 监听外挂字幕显示状态，当开启时委托给 [_SubtitleSlotWidget] 构建字幕 UI。
/// Listens to external subtitle visibility; delegates to
/// [_SubtitleSlotWidget] when enabled.
Widget buildSubtitleSlot(
  SlotBuildContext ctx,
  double width,
  double height,
) {
  return _SubtitleSlotWidget(ctx: ctx);
}

/// 字幕插槽状态组件
///
/// 缓存 [Listenable.merge] 结果，避免在 builder 回调中重复创建合并监听器。
class _SubtitleSlotWidget extends StatefulWidget {
  final SlotBuildContext ctx;

  const _SubtitleSlotWidget({required this.ctx});

  @override
  State<_SubtitleSlotWidget> createState() => _SubtitleSlotWidgetState();
}

class _SubtitleSlotWidgetState extends State<_SubtitleSlotWidget> {
  late Listenable _merged;

  @override
  void initState() {
    super.initState();
    _merged = _createMergedListenable();
  }

  @override
  void didUpdateWidget(covariant _SubtitleSlotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ctx.controller != widget.ctx.controller) {
      _merged = _createMergedListenable();
    }
  }

  Listenable _createMergedListenable() {
    return Listenable.merge([
      widget.ctx.controller.subtitleNotifier,
      widget.ctx.controller.subtitleTrackIndexNotifier,
      widget.ctx.controller.isSubtitleVisibleNotifier,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.ctx.controller.showExternalSubtitleNotifier,
      builder: (context, show, _) {
        if (!show) {
          return const SizedBox.shrink();
        }

        return ListenableBuilder(
          listenable: _merged,
          builder: (context, _) {
            final subtitles = widget.ctx.controller.subtitleNotifier.value;
            final trackIndex =
                widget.ctx.controller.subtitleTrackIndexNotifier.value;
            final isSubtitleVisible =
                widget.ctx.controller.isSubtitleVisibleNotifier.value;
            return SubtitleWidget(
              subtitleOn: isSubtitleVisible,
              subtitles: subtitles,
              trackIndex: trackIndex,
              subtitleBuilder: widget.ctx.controller.subtitleBuilder,
              config: widget.ctx.controller.subtitleConfig,
            );
          },
        );
      },
    );
  }
}

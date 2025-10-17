import 'package:flutter/material.dart';
import 'package:aliplayer_widget/constants/subtitle_model.dart';
import 'package:aliplayer_widget/utils/subtitle_builder_utils.dart';
import 'package:aliplayer_widget/utils/subtitle_config_utils.dart';

class AliPlayerSubtitleWidget extends StatefulWidget {
  /// 外挂字幕显示
  final bool subtitleOn;
  final Subtitles? subtitles;
  final int? trackIndex;

  /// 字幕配置
  final SubtitleConfig config;

  /// 字幕构建器
  final SubtitleBuilder? subtitleBuilder;

  const AliPlayerSubtitleWidget({
    super.key,
    required this.subtitleOn,
    required this.subtitles,
    required this.trackIndex,
    this.config = const SubtitleConfig(),
    this.subtitleBuilder,
  });

  @override
  State<AliPlayerSubtitleWidget> createState() =>
      _AliPlayerSubtitleWidgetState();
}

class _AliPlayerSubtitleWidgetState extends State<AliPlayerSubtitleWidget> {
  late SubtitleBuilder _effectiveBuilder;

  @override
  void initState() {
    super.initState();
    _initializeBuilder();
  }

  @override
  void didUpdateWidget(AliPlayerSubtitleWidget oldWidget) {
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
      return const SizedBox();
    }

    if (widget.trackIndex == null || widget.trackIndex! < 0) {
      return const SizedBox();
    }

    final currentSubtitles =
        widget.subtitles?.getByTrackIndex(widget.trackIndex!);

    if (currentSubtitles == null || currentSubtitles.isEmpty) {
      return const SizedBox();
    }

    return _buildAllSubtitles(currentSubtitles);
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

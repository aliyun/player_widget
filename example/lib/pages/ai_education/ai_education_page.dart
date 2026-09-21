// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: Aqi
// Date: 2026/9/2
// Brief: AI 教育场景播放示例页面

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/pages/ai_education/ai_constants.dart';
import 'package:aliplayer_widget_example/pages/ai_education/data/ai_content_loader.dart';
import 'package:aliplayer_widget_example/pages/ai_education/data/ai_content_view_model.dart';
import 'package:aliplayer_widget_example/pages/ai_education/chapter_content_panel_widget.dart';
import 'package:aliplayer_widget_example/pages/ai_education/chapter_button_widget.dart';
import 'package:aliplayer_widget_example/utils/toast_utils.dart';
import 'package:flutter/material.dart';

/// AI 教育场景播放示例页面
///
/// 演示如何在 AI 教育场景下使用 AliPlayerWidget 的 AI 章节功能。
/// 通过 [AiContentLoader] 链式加载 PlayAuth 与 AI 内容分析结果，
/// 并将章节数据传入 [AliPlayerWidgetData] 驱动底部栏章节标记与列表。
class AiEducationPage extends StatefulWidget {
  const AiEducationPage({super.key});

  @override
  State<StatefulWidget> createState() => _AiEducationPageState();
}

class _AiEducationPageState extends State<AiEducationPage> {
  static const String _tag = 'AiEducationPage';

  late final AliPlayerWidgetController _controller;

  /// AI 内容加载器，页面销毁时需取消进行中的任务
  AiContentLoader? _contentLoader;

  /// 章节/AI 解析面板是否正在显示
  bool _isChapterContentPanelShowing = false;

  /// AI 内容展示 ViewModel，由 AI 分析响应组装而来
  AiContentViewModel _content = const AiContentViewModel(
    chapters: [],
    knowledgeItems: [],
  );

  static const _slotTypeChapterShow = SlotType(
    'chapterShowButton',
    defaultOrder: 55,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 教育场景'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _buildPlayWidget(),
    );
  }

  Widget _buildPlayWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: AliPlayerWidget(
        _controller,
        slotBuilders: _getChapterSlotBuilders(),
      ),
    );
  }

  Map<SlotType, SlotWidgetBuilder?> _getChapterSlotBuilders() {
    return {
      _slotTypeChapterShow: (context) => _buildChapterShowWidget(),
    };
  }

  @override
  void initState() {
    super.initState();

    _controller = AliPlayerWidgetController();

    const vid = AiContentConstants.defaultMediaId;

    // 异步链式加载（PlayAuth → AI 内容 → 配置播放器）
    final loader = AiContentLoader();
    _contentLoader = loader;

    loader.loadPlayAuth(vid, (playAuth) {
      if (!mounted) return;

      // PlayAuth 获取失败，提示用户并退出页面，避免停留在黑屏页面
      if (playAuth == null || playAuth.isEmpty) {
        debugPrint('【$_tag】Failed to get PlayAuth');
        ToastUtils.showMessage(context, '服务端暂不可用，请检查网络或配置');
        Navigator.of(context).pop();
        return;
      }

      debugPrint('【$_tag】PlayAuth loaded');

      loader.loadAiAnalysis(vid, (response) {
        if (!mounted) return;

        if (response == null) {
          // AI 内容加载失败不影响播放，仅提示用户知情
          ToastUtils.showMessage(context, 'AI 内容加载失败');
        }

        if (response != null) {
          _content = AiContentAssembler.buildViewModel(response);
        }
        _configData(vid, playAuth);
      });
    });
  }

  /// 配置播放器（在 PlayAuth 和 AI 内容加载完成后调用）
  void _configData(
    String vid,
    String playAuth,
  ) {
    final chapters = _content.chapters;
    debugPrint("[_configData] [${chapters.length}] $chapters");

    final source = VideoSourceFactory.createVidAuthSource(
      vid: vid,
      playAuth: playAuth,
    );

    final data = AliPlayerWidgetData(
      videoSource: source,
      sceneType: SceneType.aiVod,
      chapters: chapters,
    );

    _controller.configure(data);
  }

  Widget _buildChapterShowWidget() {
    return ChapterButtonWidget(
      controller: _controller,
      onTap: () {
        if (_isChapterContentPanelShowing || !_content.hasAnyContent) return;
        setState(() {
          _isChapterContentPanelShowing = true;
        });
        _showChapterContentPanel(context);
      },
    );
  }

  /// 显示章节与 AI 解析组合面板
  void _showChapterContentPanel(BuildContext context) {
    final currentPosition = _controller.currentPositionNotifier.value;
    final currentIndex = ChapterInfo.findIndexByPosition(
      _content.chapters,
      currentPosition.inMilliseconds,
    );

    showChapterContentPanel(
      context: context,
      content: _content,
      currentIndex: currentIndex,
      onChapterSelected: (index) {
        final chapter = _content.chapters[index];
        _controller.seek(Duration(milliseconds: chapter.startMs));
      },
      onSegmentSelected: (startMs) {
        _controller.seek(Duration(milliseconds: startMs));
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isChapterContentPanelShowing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // 取消进行中的 AI 内容加载任务，避免无效回调
    _contentLoader?.cancel();
    _contentLoader = null;

    // 释放播放器控制器资源
    _controller.destroy();

    super.dispose();
  }
}

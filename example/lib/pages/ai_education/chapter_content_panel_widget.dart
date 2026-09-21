// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: aqi
// Date: 2026/09/10
// Brief: Chapter content panel for AI education scene

import 'package:aliplayer_widget/data/chapter_info.dart';
import 'package:aliplayer_widget/theme/player_styles.dart';
import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:aliplayer_widget_example/pages/ai_education/data/ai_content_view_model.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

/// AI 内容 Tab 类型
///
/// 对应 Android 端 [AiContentType]。
enum _AiContentType {
  /// 仅章节列表
  chaptersOnly,

  /// 文字分析（知识点列表）
  textAnalysis,

  /// 图解分析（摘要 + 标签 + Markdown）
  graphicAnalysis,
}

/// AI 教育场景章节与 AI 解析组合面板
///
/// 底部弹出的全屏面板，根据数据动态决定 Tab 结构：
/// - 章节 + 摘要：「章节」+「AI解析」（图解模式）
/// - 仅章节：「章节」+「AI解析」（文字模式）
/// - 仅摘要：无 Tab，直接展示 AI 解析（图解模式）
///
/// 对应 Android 端 [ChapterContentDialogFragment]。
class ChapterContentPanelWidget extends StatefulWidget {
  /// AI 内容 ViewModel
  final AiContentViewModel content;

  /// 当前播放位置对应的章节索引
  final int currentIndex;

  /// 章节选中回调
  final ValueChanged<int> onChapterSelected;

  /// 知识点/分段时间点击回调（跳转播放位置）
  final ValueChanged<int>? onSegmentSelected;

  const ChapterContentPanelWidget({
    super.key,
    required this.content,
    required this.currentIndex,
    required this.onChapterSelected,
    this.onSegmentSelected,
  });

  @override
  State<ChapterContentPanelWidget> createState() =>
      _ChapterContentPanelWidgetState();
}

class _ChapterContentPanelWidgetState extends State<ChapterContentPanelWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final _AiContentType _tab0Type;
  late final _AiContentType _tab1Type;
  late final bool _showTabs;
  late final List<_AiAnalysisRow> _graphicRows;

  int _currentSegmentIndex = -1;

  @override
  void initState() {
    super.initState();
    _deriveTabTypes();
    _graphicRows = _buildGraphicRows();
    _tabController = TabController(
      length: _showTabs ? 2 : 1,
      vsync: this,
    );
    if (_showTabs) {
      _tabController.addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    if (_showTabs) {
      _tabController.removeListener(_onTabChanged);
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1E),
              Color(0xFF0F1012),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_showTabs) _buildTabBar(),
            Expanded(
              child: _showTabs
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTabContent(_tab0Type),
                        _buildTabContent(_tab1Type),
                      ],
                    )
                  : _buildTabContent(_tab0Type),
            ),
          ],
        ),
      ),
    );
  }

  /// 推导 Tab 类型与可见性
  void _deriveTabTypes() {
    final hasChapter = widget.content.hasChapterData;
    final hasSummary = widget.content.hasSummaryData;

    if (hasChapter && hasSummary) {
      _tab0Type = _AiContentType.chaptersOnly;
      _tab1Type = _AiContentType.graphicAnalysis;
      _showTabs = true;
    } else if (hasChapter) {
      _tab0Type = _AiContentType.chaptersOnly;
      _tab1Type = _AiContentType.textAnalysis;
      _showTabs = true;
    } else {
      _tab0Type = _AiContentType.graphicAnalysis;
      _tab1Type = _AiContentType.graphicAnalysis;
      _showTabs = false;
    }
  }

  /// 预计算图解模式行结构
  List<_AiAnalysisRow> _buildGraphicRows() {
    final rows = <_AiAnalysisRow>[];
    final summary = widget.content.summaryInfo;
    if (summary == null) return rows;

    final hasHeader = (summary.paragraphSummary != null &&
            summary.paragraphSummary!.isNotEmpty) ||
        (summary.mindMapTitles != null && summary.mindMapTitles!.isNotEmpty);
    if (hasHeader) {
      rows.add(const _AiAnalysisRow.header());
    }
    if (summary.markdownContent != null &&
        summary.markdownContent!.isNotEmpty) {
      rows.add(const _AiAnalysisRow.markdown());
    }
    return rows;
  }

  /// 构建面板头部
  Widget _buildHeader() {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _headerTitle(),
              style: const TextStyle(
                color: PlayerStyles.colorOnPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  color: PlayerStyles.colorOnPrimary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tab 切换完成后刷新头部标题
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return; // 仅在切换完成后刷新一次
    setState(() {});
  }

  /// 头部标题（双 Tab 模式下跟随当前选中的 Tab）
  String _headerTitle() {
    final currentType = _showTabs
        ? (_tabController.index == 0 ? _tab0Type : _tab1Type)
        : _tab0Type;
    if (currentType == _AiContentType.chaptersOnly) {
      return '章节 共${widget.content.chapters.length}段';
    }
    return 'AI解析';
  }

  /// 构建 Tab 栏
  Widget _buildTabBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: PlayerStyles.colorOnPrimary,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: PlayerStyles.colorOnPrimary,
        unselectedLabelColor: const Color(0xFF999999),
        labelStyle: const TextStyle(
          fontSize: PlayerStyles.commonTextSize,
          fontWeight: PlayerStyles.fontWeightTitle,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: PlayerStyles.commonTextSize,
        ),
        tabs: [
          Tab(text: _titleForType(_tab0Type)),
          Tab(text: _titleForType(_tab1Type)),
        ],
      ),
    );
  }

  /// 返回指定内容类型对应的 Tab 标题
  String _titleForType(_AiContentType type) {
    switch (type) {
      case _AiContentType.chaptersOnly:
        return '章节';
      case _AiContentType.textAnalysis:
      case _AiContentType.graphicAnalysis:
        return 'AI 解析';
    }
  }

  /// 根据类型构建 Tab 内容
  Widget _buildTabContent(_AiContentType type) {
    switch (type) {
      case _AiContentType.chaptersOnly:
        return _buildChapterTab();
      case _AiContentType.textAnalysis:
        return _buildTextAnalysisTab();
      case _AiContentType.graphicAnalysis:
        return _buildGraphicAnalysisTab();
    }
  }

  /// 构建章节 Tab
  Widget _buildChapterTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: widget.content.chapters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final chapter = widget.content.chapters[index];
        final isSelected = index == widget.currentIndex;
        return _buildChapterItem(
          chapter: chapter,
          isSelected: isSelected,
          onTap: () {
            widget.onChapterSelected(index);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  /// 构建单个章节项
  Widget _buildChapterItem({
    required ChapterInfo chapter,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final timeText = FormatUtil.formatDuration(
      Duration(milliseconds: chapter.startMs),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? PlayerStyles.kChaptersPanelItemSelectedBackground
              : PlayerStyles.kChaptersPanelItemBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildThumbnail(chapter.thumbnailUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: TextStyle(
                      color: PlayerStyles.colorOnPrimary,
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeText,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isSelected ? Colors.white : Colors.white54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建章节缩略图
  Widget _buildThumbnail(String? thumbnailUrl) {
    final borderRadius = BorderRadius.circular(6);
    const width = 80.0;
    const height = 50.0;

    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: borderRadius,
        ),
        child: const Icon(
          Icons.image,
          color: Colors.white38,
          size: 20,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        thumbnailUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: borderRadius,
            ),
            child: const Icon(
              Icons.broken_image,
              color: Colors.white38,
              size: 20,
            ),
          );
        },
      ),
    );
  }

  /// 构建文字分析 Tab（知识点列表）
  Widget _buildTextAnalysisTab() {
    final items = widget.content.knowledgeItems;
    if (items.isEmpty) {
      return _buildEmptyView('暂无 AI 解析内容');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isCurrent = index == _currentSegmentIndex;
        return _buildKnowledgeItem(
          item: item,
          isCurrent: isCurrent,
          onTimeTap: () {
            widget.onSegmentSelected?.call(item.startMs);
            setState(() {
              _currentSegmentIndex = index;
            });
          },
        );
      },
    );
  }

  /// 构建单个知识点条目
  Widget _buildKnowledgeItem({
    required KnowledgeInfo item,
    required bool isCurrent,
    required VoidCallback onTimeTap,
  }) {
    final timeText = FormatUtil.formatDuration(
      Duration(milliseconds: item.startMs),
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: PlayerStyles.colorOnPrimary,
                    fontSize: PlayerStyles.commonTextSize,
                    fontWeight: PlayerStyles.fontWeightTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTimeTap,
                child: Text(
                  timeText,
                  style: TextStyle(
                    color: isCurrent
                        ? PlayerStyles.colorOnPrimary
                        : Colors.white70,
                    fontSize: PlayerStyles.commonTextSize,
                  ),
                ),
              ),
            ],
          ),
          if (item.contentMarkdown != null &&
              item.contentMarkdown!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildMarkdownBody(item.contentMarkdown!),
          ],
        ],
      ),
    );
  }

  /// 构建图解分析 Tab（摘要 + 标签 + Markdown）
  Widget _buildGraphicAnalysisTab() {
    final summary = widget.content.summaryInfo;
    if (summary == null || _graphicRows.isEmpty) {
      return _buildEmptyView('暂无 AI 解析内容');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: _graphicRows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final row = _graphicRows[index];
        return row.map(
          header: (_) => _buildGraphicHeader(summary),
          markdown: (_) => _buildGraphicMarkdown(summary),
        );
      },
    );
  }

  /// 构建图解头部（段落摘要 + 思维导图徽章）
  Widget _buildGraphicHeader(SummaryInfo summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.paragraphSummary != null &&
            summary.paragraphSummary!.isNotEmpty)
          Text(
            summary.paragraphSummary!,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: PlayerStyles.commonTextSize,
              height: 1.6,
            ),
          ),
        if (summary.mindMapTitles != null &&
            summary.mindMapTitles!.isNotEmpty) ...[
          if (summary.paragraphSummary != null &&
              summary.paragraphSummary!.isNotEmpty)
            const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: summary.mindMapTitles!
                .map((title) => _buildTagChip(title))
                .toList(),
          ),
        ],
      ],
    );
  }

  /// 构建图解 Markdown 正文
  Widget _buildGraphicMarkdown(SummaryInfo summary) {
    final markdown = summary.markdownContent ?? '';
    return _buildMarkdownBody(markdown);
  }

  /// 构建 Markdown 内容区域
  Widget _buildMarkdownBody(String data) {
    final document = md.Document();
    final nodes = document.parse(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nodes.map(_buildMarkdownBlock).whereType<Widget>().toList(),
    );
  }

  Widget? _buildMarkdownBlock(md.Node node) {
    if (node is md.Text) {
      final text = node.text.trim();
      return text.isEmpty ? null : _buildMarkdownParagraphFromText(text);
    }
    if (node is md.Element) {
      switch (node.tag) {
        case 'p':
          return _buildMarkdownParagraph(node);
        case 'h1':
          return _buildMarkdownHeading(
            node,
            PlayerStyles.fontSizeTitle,
          );
        case 'h2':
          return _buildMarkdownHeading(node, 16);
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          return _buildMarkdownHeading(
            node,
            PlayerStyles.commonTextSize,
          );
        case 'ul':
          return _buildMarkdownList(node, ordered: false);
        case 'ol':
          return _buildMarkdownList(node, ordered: true);
        case 'pre':
          return _buildMarkdownCodeBlock(node);
        case 'blockquote':
          return _buildMarkdownBlockquote(node);
        case 'hr':
          return const Divider(color: Colors.white12);
      }
    }
    return null;
  }

  Widget _buildMarkdownParagraphFromText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: PlayerStyles.commonTextSize,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildMarkdownParagraph(md.Element element) {
    final spans = _buildInlineSpans(element.children);
    if (spans.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(children: spans),
        style: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: PlayerStyles.commonTextSize,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildMarkdownHeading(md.Element element, double fontSize) {
    final spans = _buildInlineSpans(element.children);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text.rich(
        TextSpan(children: spans),
        style: TextStyle(
          color: PlayerStyles.colorOnPrimary,
          fontSize: fontSize,
          fontWeight: PlayerStyles.fontWeightTitle,
        ),
      ),
    );
  }

  Widget _buildMarkdownList(md.Element element, {required bool ordered}) {
    final items = element.children?.whereType<md.Element>().where(
          (child) => child.tag == 'li',
        );
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    var index = 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          final prefix = ordered ? '$index. ' : '• ';
          index++;
          final spans = _buildInlineSpans(item.children);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: prefix,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: PlayerStyles.commonTextSize,
                    ),
                  ),
                  ...spans,
                ],
              ),
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: PlayerStyles.commonTextSize,
                height: 1.6,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMarkdownCodeBlock(md.Element element) {
    final code = _extractTextFromNodes(element.children);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: PlayerStyles.colorOnPrimary,
          fontSize: 12,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildMarkdownBlockquote(md.Element element) {
    final spans = _buildInlineSpans(element.children);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text.rich(
        TextSpan(children: spans),
        style: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: PlayerStyles.commonTextSize,
          height: 1.6,
        ),
      ),
    );
  }

  List<InlineSpan> _buildInlineSpans(List<md.Node>? nodes) {
    if (nodes == null) return [];
    return nodes.map<InlineSpan>(_buildInlineSpan).toList();
  }

  InlineSpan _buildInlineSpan(md.Node node) {
    if (node is md.Text) {
      return TextSpan(text: node.text);
    }
    if (node is md.Element) {
      switch (node.tag) {
        case 'br':
          return const TextSpan(text: '\n');
        case 'p':
          return TextSpan(children: _buildInlineSpans(node.children));
        case 'em':
          return TextSpan(
            children: _buildInlineSpans(node.children),
            style: const TextStyle(fontStyle: FontStyle.italic),
          );
        case 'strong':
          return TextSpan(
            children: _buildInlineSpans(node.children),
            style: const TextStyle(
              color: PlayerStyles.colorOnPrimary,
              fontWeight: PlayerStyles.fontWeightTitle,
            ),
          );
        case 'code':
          return TextSpan(
            text: _extractTextFromNodes(node.children),
            style: const TextStyle(
              color: PlayerStyles.colorOnPrimary,
              fontFamily: 'monospace',
              backgroundColor: Colors.white12,
            ),
          );
        case 'a':
          return TextSpan(
            children: _buildInlineSpans(node.children),
            style: const TextStyle(color: Colors.lightBlueAccent),
          );
      }
    }
    return const TextSpan();
  }

  String _extractTextFromNodes(List<md.Node>? nodes) {
    if (nodes == null) return '';
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is md.Text) {
        buffer.write(node.text);
      } else if (node is md.Element) {
        buffer.write(_extractTextFromNodes(node.children));
      }
    }
    return buffer.toString();
  }

  /// 构建标签 Chip
  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: PlayerStyles.colorOnPrimary,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 构建空视图
  Widget _buildEmptyView(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: PlayerStyles.commonTextSize,
        ),
      ),
    );
  }
}

/// 图解分析行类型
@immutable
class _AiAnalysisRow {
  final _AiAnalysisRowType type;

  const _AiAnalysisRow.header() : type = _AiAnalysisRowType.header;

  const _AiAnalysisRow.markdown() : type = _AiAnalysisRowType.markdown;

  T map<T>({
    required T Function(_AiAnalysisRow) header,
    required T Function(_AiAnalysisRow) markdown,
  }) {
    switch (type) {
      case _AiAnalysisRowType.header:
        return header(this);
      case _AiAnalysisRowType.markdown:
        return markdown(this);
    }
  }
}

enum _AiAnalysisRowType { header, markdown }

/// 显示 AI 教育场景章节与 AI 解析组合面板
Future<void> showChapterContentPanel({
  required BuildContext context,
  required AiContentViewModel content,
  required int currentIndex,
  required ValueChanged<int> onChapterSelected,
  ValueChanged<int>? onSegmentSelected,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 5 / 8,
        child: ChapterContentPanelWidget(
          content: content,
          currentIndex: currentIndex,
          onChapterSelected: onChapterSelected,
          onSegmentSelected: onSegmentSelected,
        ),
      );
    },
  );
}

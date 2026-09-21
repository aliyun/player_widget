// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: aqi
// Date: 2026/09/10
// Brief: AI 教育场景内容展示模型与数据组装器

import 'package:aliplayer_widget/data/chapter_info.dart';
import 'package:aliplayer_widget_example/pages/ai_education/ai_constants.dart';
import 'package:aliplayer_widget_example/pages/ai_education/data/ai_analysis_response.dart';

/// AI 内容展示 ViewModel
///
/// 对应 Android 端 [AiContentViewModel]，将服务端 DTO 转换为 UI 可直接消费的模型。
class AiContentViewModel {
  /// 章节列表（ChaptersOnly 样式）
  final List<ChapterInfo> chapters;

  /// 知识点列表（TextAnalysis 样式）
  final List<KnowledgeInfo> knowledgeItems;

  /// 摘要信息（GraphicAnalysis 样式）
  final SummaryInfo? summaryInfo;

  const AiContentViewModel({
    required this.chapters,
    required this.knowledgeItems,
    this.summaryInfo,
  });

  /// 是否有章节数据
  bool get hasChapterData => chapters.isNotEmpty;

  /// 是否有摘要数据
  bool get hasSummaryData =>
      summaryInfo != null &&
      (summaryInfo!.hasContent ||
          (summaryInfo!.mindMapTitles != null &&
              summaryInfo!.mindMapTitles!.isNotEmpty));

  /// 是否有任何有效内容
  bool get hasAnyContent => hasChapterData || hasSummaryData;
}

/// 知识点信息
///
/// 对应 Android 端 [KnowledgeInfo]，用于 TextAnalysis 模式下的列表项。
class KnowledgeInfo {
  /// 知识点标题
  final String title;

  /// 起始时间（毫秒）
  final int startMs;

  /// 结束时间（毫秒）
  final int endMs;

  /// Markdown 格式详情，可能为 null
  final String? contentMarkdown;

  const KnowledgeInfo({
    required this.title,
    required this.startMs,
    required this.endMs,
    this.contentMarkdown,
  });
}

/// 视频摘要信息
///
/// 对应 Android 端 [SummaryInfo]，用于 GraphicAnalysis 模式。
class SummaryInfo {
  /// 段落摘要
  final String? paragraphSummary;

  /// 思维导图标题列表（徽章标签）
  final List<String>? mindMapTitles;

  /// Markdown 格式详细内容
  final String? markdownContent;

  const SummaryInfo({
    this.paragraphSummary,
    this.mindMapTitles,
    this.markdownContent,
  });

  /// 是否有有效内容
  bool get hasContent =>
      (paragraphSummary != null && paragraphSummary!.isNotEmpty) ||
      (markdownContent != null && markdownContent!.isNotEmpty);
}

/// AI 内容数据组装器
///
/// 对应 Android 端 [AiContentAssembler]，纯静态工具类。
class AiContentAssembler {
  AiContentAssembler._();

  /// 一次性组装完整 ViewModel
  static AiContentViewModel buildViewModel(AiAnalysisResponse response) {
    return AiContentViewModel(
      chapters: _buildChapters(response),
      knowledgeItems: _buildKnowledgeItems(response),
      summaryInfo: _buildSummaryInfo(response),
    );
  }

  /// 组装章节列表
  static List<ChapterInfo> _buildChapters(AiAnalysisResponse response) {
    final chapterResult = _findResultByType(
      response,
      AiContentConstants.resultTypeChapter,
    );
    final items = chapterResult?.chapterContentItems;
    if (items == null || items.isEmpty) return const [];

    return items.map((item) {
      return ChapterInfo(
        id: item.chapterId?.toString(),
        startMs: item.startTime ?? 0,
        endMs: item.endTime ?? 0,
        title: item.chapterTitle ?? '',
        thumbnailUrl: item.thumbnailUrl,
      );
    }).toList();
  }

  /// 组装知识点列表
  static List<KnowledgeInfo> _buildKnowledgeItems(AiAnalysisResponse response) {
    final chapterResult = _findResultByType(
      response,
      AiContentConstants.resultTypeChapter,
    );
    final items = chapterResult?.chapterContentItems;
    if (items == null || items.isEmpty) return const [];

    return items.map((item) {
      return KnowledgeInfo(
        title: item.chapterTitle ?? '',
        startMs: item.startTime ?? 0,
        endMs: item.endTime ?? 0,
        contentMarkdown: _buildContentMarkdown(item),
      );
    }).toList();
  }

  /// 组装摘要信息
  static SummaryInfo? _buildSummaryInfo(AiAnalysisResponse response) {
    final summaryResult = _findResultByType(
      response,
      AiContentConstants.resultTypeSummary,
    );
    final content = summaryResult?.summaryContent;
    if (content == null) return null;

    final mindMap = content.mindMapSummary;
    List<String>? mindMapTitles;
    if (mindMap != null && mindMap.isNotEmpty) {
      mindMapTitles = mindMap
          .map((item) => item.title)
          .where((title) => title != null && title.isNotEmpty)
          .cast<String>()
          .toList();
      if (mindMapTitles.isEmpty) mindMapTitles = null;
    }

    return SummaryInfo(
      paragraphSummary: content.paragraphSummary,
      mindMapTitles: mindMapTitles,
      markdownContent: content.markdownContent,
    );
  }

  /// 三级降级生成 markdown 内容
  static String? _buildContentMarkdown(AiChapterContentItem item) {
    // 1. knowledgePoints 非空 → 拼接 markdown
    final points = item.knowledgePoints;
    if (points != null && points.isNotEmpty) {
      final buffer = StringBuffer();
      for (final point in points) {
        final name = point.point;
        final description = point.description;
        if (name == null || name.isEmpty) continue;
        if (description != null && description.isNotEmpty) {
          buffer.write('- **$name**：$description\n');
        } else {
          // 仅有名称时也输出该知识点，避免内容缺失
          buffer.write('- **$name**\n');
        }
      }
      if (buffer.isNotEmpty) return buffer.toString();
      // buffer 为空则继续降级到 summary
    }

    // 2. summary 非空 → 直接用作 markdown
    final summary = item.summary;
    if (summary != null && summary.isNotEmpty) return summary;

    // 3. 都为空 → null
    return null;
  }

  /// 按 resultType 筛选单个 AI 分析结果项
  static AiAnalysisResultItem? _findResultByType(
    AiAnalysisResponse response,
    String resultType,
  ) {
    final results = response.aiAnalysisResult;
    if (results == null) return null;

    for (final item in results) {
      if (item.resultType == resultType) {
        return item;
      }
    }
    return null;
  }
}

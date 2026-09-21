// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: wyq
// Date: 2026/9/2
// Brief: App Server AI 内容分析响应 DTO

/// App Server AI 内容分析响应 DTO
///
/// 对应 App Server 返回的 JSON 结构。
/// 由 [AiContentAssembler] 组装为客户端展示模型。
class AiAnalysisResponse {
  /// AI 分析结果列表
  final List<AiAnalysisResultItem>? aiAnalysisResult;

  AiAnalysisResponse({this.aiAnalysisResult});

  factory AiAnalysisResponse.fromJson(Map<String, dynamic> json) {
    final list = json['AiAnalysisResult'] as List<dynamic>?;
    return AiAnalysisResponse(
      aiAnalysisResult: list
          ?.map((e) => AiAnalysisResultItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AiAnalysisResult': aiAnalysisResult?.map((e) => e.toJson()).toList(),
    };
  }
}

/// 单个 AI 分析结果项
///
/// 对应 JSON 中 "AiAnalysisResult" 数组中的每一项，
/// 包含结果类型（如 "Chapter"/"Summary"）、标题、额外信息和内容列表。
class AiAnalysisResultItem {
  /// 结果类型（如 "Chapter"、"Summary"）
  final String? resultType;

  /// 视频标题
  final String? title;

  /// 额外信息（JSON 字符串，包含整体摘要等）
  final String? extra;

  /// 摘要内容（ResultType 为 Summary 时存在）
  final AiSummaryContent? summaryContent;

  /// 章节内容列表（ResultType 为 Chapter 时存在）
  final List<AiChapterContentItem>? chapterContentItems;

  AiAnalysisResultItem({
    this.resultType,
    this.title,
    this.extra,
    this.summaryContent,
    this.chapterContentItems,
  });

  factory AiAnalysisResultItem.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResultItem(
      resultType: json['ResultType'] as String?,
      title: json['Title'] as String?,
      extra: json['Extra'] as String?,
      summaryContent: json['summaryContent'] == null
          ? null
          : AiSummaryContent.fromJson(
              json['summaryContent'] as Map<String, dynamic>),
      chapterContentItems: (json['chapterContentItems'] as List<dynamic>?)
          ?.map((e) => AiChapterContentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ResultType': resultType,
      'Title': title,
      'Extra': extra,
      'summaryContent': summaryContent?.toJson(),
      'chapterContentItems':
          chapterContentItems?.map((e) => e.toJson()).toList(),
    };
  }
}

/// 摘要内容
///
/// 对应 JSON 中的 "summaryContent" 字段，包含段落摘要、MindMap 和 Markdown 内容。
class AiSummaryContent {
  /// 段落摘要文本
  final String? paragraphSummary;

  /// Markdown 格式内容
  final String? markdownContent;

  /// 思维导图摘要列表
  final List<AiMindMapItem>? mindMapSummary;

  AiSummaryContent({
    this.paragraphSummary,
    this.markdownContent,
    this.mindMapSummary,
  });

  factory AiSummaryContent.fromJson(Map<String, dynamic> json) {
    return AiSummaryContent(
      paragraphSummary: json['ParagraphSummary'] as String?,
      markdownContent: json['MarkdownContent'] as String?,
      mindMapSummary: (json['MindMapSummary'] as List<dynamic>?)
          ?.map((e) => AiMindMapItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ParagraphSummary': paragraphSummary,
      'MarkdownContent': markdownContent,
      'MindMapSummary': mindMapSummary?.map((e) => e.toJson()).toList(),
    };
  }
}

/// 章节内容项
///
/// 对应 JSON 中 "chapterContentItems" 数组中的每一项，
/// 包含章节的时间范围、标题、摘要、缩略图和知识点列表。
class AiChapterContentItem {
  /// 章节 ID
  final int? chapterId;

  /// 章节开始时间（毫秒）
  final int? startTime;

  /// 章节结束时间（毫秒）
  final int? endTime;

  /// 章节标题
  final String? chapterTitle;

  /// 章节摘要
  final String? summary;

  /// 章节缩略图 URL
  final String? thumbnailUrl;

  /// 知识点列表
  final List<AiKnowledgePointItem>? knowledgePoints;

  AiChapterContentItem({
    this.chapterId,
    this.startTime,
    this.endTime,
    this.chapterTitle,
    this.summary,
    this.thumbnailUrl,
    this.knowledgePoints,
  });

  factory AiChapterContentItem.fromJson(Map<String, dynamic> json) {
    return AiChapterContentItem(
      chapterId: json['ChapterId'] as int?,
      startTime: json['StartTime'] as int?,
      endTime: json['EndTime'] as int?,
      chapterTitle: json['ChapterTitle'] as String?,
      summary: json['Summary'] as String?,
      thumbnailUrl: json['ThumbnailUrl'] as String?,
      knowledgePoints: (json['KnowledgePoints'] as List<dynamic>?)
          ?.map((e) => AiKnowledgePointItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ChapterId': chapterId,
      'StartTime': startTime,
      'EndTime': endTime,
      'ChapterTitle': chapterTitle,
      'Summary': summary,
      'ThumbnailUrl': thumbnailUrl,
      'KnowledgePoints': knowledgePoints?.map((e) => e.toJson()).toList(),
    };
  }
}

/// 知识点项
///
/// 对应 JSON 中 "KnowledgePoints" 数组中的每一项，
/// 包含知识点 ID、名称和描述。
class AiKnowledgePointItem {
  /// 知识点 ID
  final int? pointId;

  /// 知识点名称
  final String? point;

  /// 知识点描述
  final String? description;

  AiKnowledgePointItem({this.pointId, this.point, this.description});

  factory AiKnowledgePointItem.fromJson(Map<String, dynamic> json) {
    return AiKnowledgePointItem(
      pointId: json['PointId'] as int?,
      point: json['Point'] as String?,
      description: json['Description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PointId': pointId,
      'Point': point,
      'Description': description,
    };
  }
}

/// 思维导图项
///
/// 对应 JSON 中 "MindMapSummary" 数组中的每一项，
/// 包含标题和子话题列表（递归结构）。
class AiMindMapItem {
  /// 思维导图节点标题
  final String? title;

  /// 子话题列表（递归结构，每个子话题也是 AiMindMapItem）
  final List<AiMindMapItem>? topics;

  AiMindMapItem({this.title, this.topics});

  factory AiMindMapItem.fromJson(Map<String, dynamic> json) {
    return AiMindMapItem(
      title: json['Title'] as String?,
      topics: (json['Topics'] as List<dynamic>?)
          ?.map((e) => AiMindMapItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Topics': topics?.map((e) => e.toJson()).toList(),
    };
  }
}

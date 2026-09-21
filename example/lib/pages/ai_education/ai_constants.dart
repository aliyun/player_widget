// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: wyq
// Date: 2026/9/2
// Brief: AI 教育场景内容分析相关常量

/// AI 内容相关常量。
///
/// AI content related constants.
///
/// 本类集中管理"AI 教育"场景所需的配置项、接口地址、请求参数及结果类型常量，
/// 主要用于：
/// This class centralizes the configuration, API endpoints, request parameters and result type
/// constants required by the "AI education" scene. It is mainly used for:
///   - 获取视频播放凭证（PlayAuth） / Fetching video play auth
///   - 获取 AI 分析结果（章节、摘要等） / Fetching AI analysis results (chapters, summary, etc.)
///
/// 集成前必读 / Before You Integrate
/// 接入本模块前，请先完成以下两项必要配置：
/// Before integrating this module, please complete the following two required configurations:
///   1. [appServerBaseUrl] —— 替换为您自己部署的 App Server 地址；
///       Replace with the address of your own deployed App Server.
///   2. [defaultMediaId] —— 替换为您自己账号下的媒体 ID；
///       Replace with a media ID from your own account.
/// 详细说明请参见对应字段上的注释。
/// See the comments on each field for details.
abstract final class AiContentConstants {
  AiContentConstants._();

  /// AI 内容分析服务的 App Server 基础地址。
  ///
  /// App Server base URL for AI content analysis.
  ///
  /// 快速开始 / Quick Start
  /// 将此地址替换为您自己部署的 App Server 地址，即可完成端侧运行。集成时需要修改的配置共两项，
  /// 除本地址外，还需要将 [defaultMediaId] 替换为您自己账号下的媒体 ID。
  /// Replace this with the address of your own deployed App Server to get the client up and
  /// running. There are two configurations you need to modify for integration: besides this
  /// address, you also need to replace [defaultMediaId] with a media ID from your own account.
  ///
  /// 地址格式 / URL Format
  /// `http://<您的服务器IP或域名>:<端口>`，末尾不要带 `/`，例如 `http://192.168.1.100:9000`。
  /// `http://<your-server-ip-or-domain>:<port>`, without a trailing `/`,
  /// e.g. `http://192.168.1.100:9000`.
  ///
  /// 依赖接口 / Required APIs
  /// 本模块会请求该服务的以下两个接口：
  /// This module calls the following two APIs on the server:
  ///   - `/appServer/GetVideoPlayAuth` —— 获取播放凭证 / Get video play auth
  ///   - `/GetMediaAiAnalysisByResultType` —— 获取 AI 分析内容 / Get AI analysis content
  ///
  /// App Server 开源地址 / Open Source
  /// App Server 已开源，项目地址：
  /// The App Server is open source and available at:
  /// https://github.com/MediaBox-Demos/VodAppServer
  ///
  /// 运行时覆盖 / Runtime Override
  /// Demo 设置页（链接设置）中配置的 App Server 地址优先级高于此常量，仅用于调试，集成时无需关心。
  /// The App Server address configured in the demo settings page (Link Settings) takes
  /// precedence over this constant. It is for debugging only and can be ignored for integration.
  static const String appServerBaseUrl =
      'https://vodappserver-gwzwacvbyf.cn-shanghai.fcapp.run';

  // ==================== Default Values ====================

  /// 默认播放媒体 ID。
  ///
  /// Default media ID used for playback.
  ///
  /// 快速开始 / Quick Start
  /// 与 [appServerBaseUrl] 一样，这是集成时需要修改的两项配置之一。请将此值替换为您自己账号下
  /// 已上传至阿里云视频点播（VOD）的媒体 ID，且该媒体必须能够被上面配置的 [appServerBaseUrl]
  /// 对应的 App Server 查询到（即两者要属于同一套点播服务/同一个阿里云账号）。
  /// Just like [appServerBaseUrl], this is one of the two configurations you need to
  /// modify for integration. Replace this value with a media ID that has already been uploaded
  /// to your own Alibaba Cloud VOD (Video on Demand) account, and make sure it can be queried by
  /// the App Server configured via [appServerBaseUrl] (i.e. they must belong to the same
  /// VOD service / same Alibaba Cloud account).
  ///
  /// 获取方式 / How to Obtain
  /// 登录阿里云视频点播控制台，在媒体管理中找到已上传视频对应的媒体 ID（MediaId），
  /// 或调用点播上传/查询接口获取。
  /// Log in to the Alibaba Cloud VOD console, locate the MediaId of an uploaded video under
  /// media management, or obtain it via the VOD upload/query APIs.
  ///
  /// 使用场景 / Usage
  /// 该 MediaId 会作为默认值传入播放器及 AI 内容分析接口
  /// （`/appServer/GetVideoPlayAuth` 和 `/GetMediaAiAnalysisByResultType`），
  /// 用于获取播放凭证与 AI 分析结果（章节、摘要等）。
  /// This MediaId is passed as the default value to the player and to the AI content analysis
  /// APIs (`/appServer/GetVideoPlayAuth` and `/GetMediaAiAnalysisByResultType`) to
  /// fetch the play auth and AI analysis results (chapters, summary, etc.).
  ///
  /// 运行时覆盖 / Runtime Override
  /// Demo 中若通过入口页面或设置页手动传入了具体的 MediaId，则优先使用传入值，此常量仅作为默认兜底值，
  /// 集成时可根据实际业务场景动态传入真实 MediaId。
  /// If a specific MediaId is manually provided via the entry page or settings page in the demo,
  /// that value takes precedence. This constant only serves as a default fallback value; in
  /// real integration, you should dynamically pass the actual MediaId based on your business
  /// scenario.
  static const String defaultMediaId = '2042d63ea5c771f19a6b4531859c0102';

  // ==================== API Endpoints ====================

  /// 视频内容分析接口
  ///
  /// API endpoint for getting media AI analysis results by result type.
  static const String apiGetMediaAiAnalysis =
      '$appServerBaseUrl/GetMediaAiAnalysisByResultType';

  /// 获取视频播放凭证接口
  ///
  /// API endpoint for getting video play auth.
  static const String apiGetVideoPlayAuth =
      '$appServerBaseUrl/appServer/GetVideoPlayAuth';

  // ==================== Query Parameters ====================

  /// 请求参数：媒体 ID
  ///
  /// Query parameter: MediaId
  static const String paramMediaId = 'MediaId';

  /// 请求参数：视频 ID
  ///
  /// Query parameter: videoId
  static const String paramVideoId = 'videoId';

  /// 请求参数：结果类型（可选，不传则返回所有类型）
  ///
  /// Query parameter: ResultType (optional, returns all types if omitted)
  static const String paramResultType = 'ResultType';

  // ==================== Result Types ====================

  /// AI 分析结果类型：章节
  ///
  /// AI analysis result type: Chapter
  static const String resultTypeChapter = 'Chapter';

  /// AI 分析结果类型：摘要
  ///
  /// AI analysis result type: Summary
  static const String resultTypeSummary = 'Summary';

  // ==================== URL Builder ====================

  /// 构建 AI 内容分析 API 请求 URI
  ///
  /// Build API request URI for AI content analysis.
  ///
  /// [mediaId] 媒体 ID（必填）
  /// [resultType] 结果类型（可选，传 null 或空字符串则不带 ResultType 参数，返回所有类型）
  /// 返回构造好的 [Uri]
  static Uri buildApiUri(String mediaId, {String? resultType}) {
    final id = mediaId.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(mediaId, 'mediaId', '不能为空');
    }

    final type = resultType?.trim();

    return Uri.parse(apiGetMediaAiAnalysis).replace(
      queryParameters: {
        paramMediaId: id,
        if (type != null && type.isNotEmpty) paramResultType: type,
      },
    );
  }

  /// 构建 PlayAuth 请求 URL
  ///
  /// Build PlayAuth request URL.
  ///
  /// [videoId] 视频 ID（必填）
  /// 返回构造好的 URL 字符串
  static String buildPlayAuthUrl(String videoId) {
    final id = videoId.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(videoId, 'videoId', '不能为空');
    }

    return Uri.parse(apiGetVideoPlayAuth)
        .replace(queryParameters: {paramVideoId: id}).toString();
  }
}

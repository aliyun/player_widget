// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: Aqi
// Date: 2026/4/28
// Brief: 播放状态控件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/ui/custom/custom_icon_button.dart';
import 'package:flutter/material.dart';

/// 播放状态
enum PlayStatus {
  loading,
  error,
  success,
  info,
}

/// 播放状态控件
class PlayStateWidget extends StatelessWidget {
  final PlayStatus widgetStatus;
  final String? statusMessage;
  final String? statusCode;

  const PlayStateWidget({
    super.key,
    required this.widgetStatus,
    this.statusCode,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        decoration: BoxDecoration(
          color: PlayerStyles.kControlWidgetColor,
          borderRadius: BorderRadius.circular(
            PlayerStyles.kStatusWidgetRadius,
          ),
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PlayerStyles.kStatusWidgetPadding,
              vertical: PlayerStyles.kStatusWidgetPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomIconButton(
                  iconName: _getIconName(),
                ),
                Column(
                  children: [
                    if (statusCode != null)
                      Text(
                        _getStatusCode() ?? "",
                        textAlign: TextAlign.center,
                        style: _textStyle,
                      ),
                    if (statusMessage != null)
                      Text(
                        _getStatusMsg() ?? "",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: _textStyle,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 获取状态码
  String? _getStatusCode() {
    String? result = statusCode;
    if (widgetStatus == PlayStatus.error && statusCode != null) {
      result = "${PlayerI18n.t(PlayerI18nKeys.statusErrorCode)} $statusCode";
    }

    return result;
  }

  /// 获取状态信息
  String? _getStatusMsg() {
    String? result = statusMessage;
    if (widgetStatus == PlayStatus.error && statusMessage != null) {
      result = "${PlayerI18n.t(PlayerI18nKeys.statusErrorMsg)} $statusMessage";
    }
    return result;
  }

  /// 通用文字样式
  TextStyle get _textStyle => const TextStyle(
        fontSize: PlayerStyles.commonTextSize,
        fontWeight: FontWeight.normal,
        color: PlayerStyles.colorOnPrimary,
      );

  /// 根据状态获取图标
  String _getIconName() {
    switch (widgetStatus) {
      case PlayStatus.loading:
        return PlayerIcons.statusLoading;
      case PlayStatus.error:
        return PlayerIcons.statusError;
      case PlayStatus.success:
        return PlayerIcons.statusSuccess;
      case PlayStatus.info:
        return PlayerIcons.statusInfo;
    }
  }
}

/// 播放状态扩展
///
/// Play state extension
extension PlayStateHelper on int {
  /// 扩展方法：判断是否需要构建 Widget
  ///
  /// Extension method: determine whether to build the widget
  bool get shouldBuildErrorWidget => this == FlutterAvpdef.error;
}

/// 构建播放状态插槽的默认实现。
/// Builds the default play state slot content.
///
/// 监听播放状态、加载状态和错误信息，显示加载中或错误状态的 UI。
/// Listens to play state, loading state, and error info;
/// displays loading or error state UI.
Widget buildPlayStateSlot(
  SlotBuildContext ctx,
  double width,
  double height,
) {
  // 监听播放状态、错误码、错误信息等变化
  Listenable listenable = Listenable.merge([
    ctx.controller.playStateNotifier,
    ctx.controller.playErrorNotifier,
    ctx.controller.isLoadingStateNotifier,
  ]);
  return ListenableBuilder(
    listenable: listenable,
    builder: (context, _) {
      // 获取播放状态
      final playState = ctx.controller.playStateNotifier.value;
      final isLoadingState = ctx.controller.isLoadingStateNotifier.value;

      if (!playState.shouldBuildErrorWidget) {
        if (isLoadingState) {
          return PlayStateWidget(
            widgetStatus: PlayStatus.loading,
            statusCode: PlayerI18n.t(PlayerI18nKeys.statusLoading),
          );
        } else {
          // 如果不需要构建播放状态视图，则返回空组件
          return const SizedBox.shrink();
        }
      }

      // 获取错误码和错误信息
      final playError = ctx.controller.playErrorNotifier.value;
      final errorCode = playError?.keys.firstOrNull;
      final errorMsg = playError?.values.firstOrNull;

      return PlayStateWidget(
        widgetStatus: PlayStatus.error,
        statusCode: errorCode?.toString(),
        statusMessage: errorMsg,
      );
    },
  );
}

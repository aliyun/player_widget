// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: Aqi
// Date: 2026/4/28
// Brief: 播放状态控件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/theme/player_icons.dart';
import 'package:aliplayer_widget/theme/player_styles.dart';
import 'package:aliplayer_widget/ui/aliplayer_custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 播放状态
enum PlayStatus {
  loading,
  error,
  success,
  info,
}

class AliPlayerPlayStateWidget extends StatefulWidget {
  final PlayStatus widgetStatus;
  final String? statusMessage;
  final String? statusCode;

  const AliPlayerPlayStateWidget(
      {super.key,
      required this.widgetStatus,
      this.statusCode,
      this.statusMessage});

  @override
  State<StatefulWidget> createState() {
    return _AliPlayerPlayStateWidgetState();
  }
}

class _AliPlayerPlayStateWidgetState extends State<AliPlayerPlayStateWidget> {
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
                      if (widget.statusCode != null)
                        Text(
                          _getStatusCode() ?? "",
                          textAlign: TextAlign.center,
                          style: _textStyle, // 引用下方的静态样式
                        ),
                      if (widget.statusMessage != null)
                        Text(
                          _getStatusMsg() ?? "",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2, // 建议限制最大行数，配合 ellipsis 使用
                          style: _textStyle, // 引用下方的静态样式
                        ),
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }

  /// 获取状态码
  String? _getStatusCode() {
    String? result = widget.statusCode;
    if (widget.widgetStatus == PlayStatus.error && widget.statusCode != null) {
      result =
          "${PlayerI18n.t(PlayerI18nKeys.statusErrorCode)} ${widget.statusCode}";
    }

    return result;
  }

  /// 获取状态信息
  String? _getStatusMsg() {
    String? result = widget.statusMessage;
    if (widget.widgetStatus == PlayStatus.error &&
        widget.statusMessage != null) {
      result =
          "${PlayerI18n.t(PlayerI18nKeys.statusErrorMsg)} ${widget.statusMessage}";
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
    switch (widget.widgetStatus) {
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

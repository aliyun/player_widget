// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/20
// Brief: 自定义封面显示图 Widget

import 'package:flutter/material.dart';

/// 自定义封面显示图 Widget
class AliPlayerCoverImageWidget extends StatefulWidget {
  /// 图片 URL
  final String imageUrl;

  /// 是否显示封面图
  final bool isVisible;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 图片适配方式
  final BoxFit? fit;

  /// 对齐方式
  final AlignmentGeometry alignment;

  const AliPlayerCoverImageWidget({
    super.key,
    required this.imageUrl,
    this.isVisible = true,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
  });

  @override
  State<AliPlayerCoverImageWidget> createState() =>
      _AliPlayerCoverImageWidgetState();
}

class _AliPlayerCoverImageWidgetState extends State<AliPlayerCoverImageWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }
          return const SizedBox.shrink();
        },
        errorBuilder: (
          BuildContext context,
          Object exception,
          StackTrace? stackTrace,
        ) {
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// 状态更新回调
  /// 当 Widget 的状态被更新时，该方法被调用。
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerCoverImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger rebuild if properties changes
    if (widget.isVisible != oldWidget.isVisible) {
      setState(() {});
    }
  }
}

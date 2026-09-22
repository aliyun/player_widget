// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/20
// Brief: 自定义封面显示图 Widget

import 'package:flutter/material.dart';

import 'package:aliplayer_widget/slot/slot_build_context.dart';

/// 自定义封面显示图 Widget
class CoverImageWidget extends StatelessWidget {
  /// 图片 URL
  final String imageUrl;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 图片适配方式
  final BoxFit? fit;

  /// 对齐方式
  final AlignmentGeometry alignment;

  const CoverImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadImage(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image(
            image: snapshot.data as ImageProvider,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// 预加载图片并返回 ImageProvider
  Future<ImageProvider> _loadImage(BuildContext context) async {
    final imageProvider = NetworkImage(imageUrl);
    await precacheImage(imageProvider, context); // 预加载图片
    return imageProvider;
  }
}

/// 构建封面图插槽的默认实现。
/// Builds the default cover image slot content.
///
/// 监听封面 URL 和渲染状态，在播放器首帧渲染完成前显示封面图。
/// Listens to cover URL and render state; displays the cover image
/// until the player has rendered its first frame.
Widget buildCoverImageSlot(
  SlotBuildContext ctx,
  double width,
  double height,
) {
  return ListenableBuilder(
    listenable: Listenable.merge([
      ctx.controller.coverURLNotifier,
      ctx.controller.isRenderedNotifier,
    ]),
    builder: (buildContext, widget) {
      final coverUrl = ctx.controller.coverURLNotifier.value;
      final isRendered = ctx.controller.isRenderedNotifier.value;

      // 已渲染完成，或者没有封面，都不显示封面
      if (isRendered || coverUrl == null || coverUrl.isEmpty) {
        return const SizedBox.shrink();
      }

      return CoverImageWidget(
        imageUrl: coverUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    },
  );
}

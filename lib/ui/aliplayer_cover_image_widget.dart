// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/20
// Brief: 自定义封面显示图 Widget

import 'package:flutter/material.dart';

/// 自定义封面显示图 Widget
class AliPlayerCoverImageWidget extends StatelessWidget {
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

  const AliPlayerCoverImageWidget({
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

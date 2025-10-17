// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2025/7/15
// Brief: 外挂字幕示例

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/utils/subtitle_builder_utils.dart';
import 'package:aliplayer_widget/utils/subtitle_config_utils.dart';
import 'package:aliplayer_widget_example/constants/demo_constants.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:aliplayer_widget_example/pages/link/link_constants.dart';
import 'package:aliplayer_widget_example/utils/toast_utils.dart';
import 'package:flutter/material.dart';

class ExternalSubtitlePage extends StatefulWidget {
  const ExternalSubtitlePage({super.key});

  @override
  State<StatefulWidget> createState() => _ExternalSubtitlePage();
}

class _ExternalSubtitlePage extends State<ExternalSubtitlePage> {
  /// 播放器组件控制器
  late AliPlayerWidgetController _controller;

  /// 播放器数据
  late AliPlayerWidgetData _playerData;

  // 可选（非必需）：播放起始位置，单位为毫秒
  static const int _videoDurationMills = 8 * 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('外挂字幕'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        children: [
          // 播放器区域
          _buildPlayWidget(),
          // 控制按钮区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: _buildControlButtons(),
          ),
        ],
      ),
    );
  }

  /// 构建播放器组件
  Widget _buildPlayWidget() {
    return AliPlayerWidget(_controller);
  }

  /// 构建控制按钮区域
  Widget _buildControlButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '字幕样式控制',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        // 第一行按钮
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleMenuSelection('config'),
                icon: const Icon(Icons.palette, size: 18),
                label: const Text('配置样式'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleMenuSelection('builder'),
                icon: const Icon(Icons.build, size: 18),
                label: const Text('自定义构建器'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 第二行按钮
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleMenuSelection('style'),
                icon: const Icon(Icons.text_fields, size: 18),
                label: const Text('简单样式'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleMenuSelection('position'),
                icon: const Icon(Icons.place, size: 18),
                label: const Text('改变位置'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 重置按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleMenuSelection('reset'),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('重置为默认样式'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AliPlayerWidgetController(context);

    // 获取保存的链接
    var savedLink = SPManager.instance.getString(LinkConstants.shortVideo);
    // 如果没有保存的链接，则使用默认链接
    if (savedLink == null || savedLink.isEmpty) {
      savedLink = DemoConstants.sampleVideoUrl;
    }

    // 获取保存的外挂字幕链接
    var savedSubtitleLink =
        SPManager.instance.getString(LinkConstants.externalSubtitle);
    // 如果没有保存的外挂字幕链接，则使用默认链接
    if (savedSubtitleLink == null || savedSubtitleLink.isEmpty) {
      savedSubtitleLink = DemoConstants.defaultExternalSubtitleUrl;
    }

    // 设置播放器组件数据 - 不设置 subtitleConfig，使用默认配置
    final videoSource = VideoSourceFactory.createUrlSource(savedLink);
    _playerData = AliPlayerWidgetData(
      videoSource: videoSource,
      externalSubtitleUrl: savedSubtitleLink,
      videoTitle: "外挂字幕",
      startTime: _videoDurationMills,
      subtitlePositionConfig: const SubtitlePositionConfig(
        bottom: 0,
        left: 0,
        right: 0,
      ),
      // 注释掉自定义配置，使用默认配置
      // subtitleConfig: _createDefaultSubtitleConfig(),
      // subtitleBuilder: _createDefaultSubtitleBuilder(),
    );

    _controller.configure(_playerData);
  }

  /// 创建默认字幕配置
  SubtitleConfig _createDefaultSubtitleConfig() {
    return const SubtitleConfig(
      styleConfig: SubtitleStyleConfig(
        textStyle: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.normal,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black,
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      enableAnimation: true,
    );
  }

  /// 创建默认字幕构建器
  SubtitleBuilder _createDefaultSubtitleBuilder() {
    return DefaultSubtitleBuilder();
  }

  /// 处理菜单选择
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'config':
        _setupSubtitleByConfig();
        break;
      case 'builder':
        _setupSubtitleBuilder();
        break;
      case 'style':
        _changeSubtitleStyle();
        break;
      case 'position':
        _changeSubtitlePosition();
        break;
      case 'reset':
        _resetToDefault();
        break;
    }
  }

  // 重置为默认样式
  void _resetToDefault() {
    // 重新创建播放器数据，不设置自定义配置
    final videoSource = VideoSourceFactory.createUrlSource(
        SPManager.instance.getString(LinkConstants.shortVideo) ??
            DemoConstants.sampleVideoUrl);

    _controller.getCurrentPosition().then((currentPosition) {
      _playerData = AliPlayerWidgetData(
        videoSource: videoSource,
        externalSubtitleUrl:
            SPManager.instance.getString(LinkConstants.externalSubtitle) ??
                DemoConstants.defaultExternalSubtitleUrl,
        videoTitle: "外挂字幕",
        startTime: currentPosition,
        // 不设置 subtitleConfig，使用默认配置
      );

      _controller.configure(_playerData);

      // 显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已重置为默认字幕样式'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // 方式1：使用配置对象自定义样式
  void _setupSubtitleByConfig() {
    final customConfig = SubtitleConfig(
      styleConfig: SubtitleStyleConfig(
        textStyle: const TextStyle(
          fontSize: 14,
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black,
            ),
          ],
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.8),
              Colors.purple.withOpacity(0.8)
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      enableAnimation: true,
    );

    // 更新播放器数据中的字幕配置
    _controller.setSubtitleConfig(customConfig);

    // 重新配置播放器以应用新的字幕设置
    _reconfigurePlayer();

    ToastUtils.showMessage(context, '已应用配置样式');
  }

  // 方式2：使用自定义构建器
  void _setupSubtitleBuilder() {
    final customBuilder = CustomSubtitleBuilder(
      customBuilder: (context, subtitle, config) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.subtitles, color: Colors.white, size: 16),
              const SizedBox(height: 4),
              Text(
                subtitle.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    // 更新播放器数据中的字幕构建器
    _controller.setSubtitleBuilder(customBuilder);

    // 重新配置播放器以应用新的字幕设置
    _reconfigurePlayer();

    ToastUtils.showMessage(context, '已应用自定义构建器');
  }

  // 简单的样式配置
  void _changeSubtitleStyle() {
    _controller.updateSubtitleStyle(
      SubtitleStyleConfig(
        textStyle: const TextStyle(fontSize: 18, color: Colors.red),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );

    // 重新配置播放器以应用新的字幕设置
    _reconfigurePlayer();

    ToastUtils.showMessage(context, '已应用简单样式');
  }

  // 动态改变字幕位置
  void _changeSubtitlePosition() {
    _controller.updateSubtitlePosition(
      const SubtitlePositionConfig(
        bottom: 0,
        left: 100,
        right: 0,
      ),
    );

    // 重新配置播放器以应用新的字幕设置
    _reconfigurePlayer();

    ToastUtils.showMessage(context, '已改变字幕位置到中心');
  }

  /// 重新配置播放器以应用新的设置
  void _reconfigurePlayer() {
    _controller.getCurrentPosition().then((currentPosition) {
      // 更新起始时间为当前位置
      _playerData.startTime = currentPosition;

      // 重新配置播放器
      _controller.configure(_playerData);
    });

    setState(() {
      // 触发界面重建
    });
  }

  @override
  void dispose() {
    // 销毁播放器组件
    _controller.destroy();
    super.dispose();
  }
}

// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/5/8
// Brief: Strategy system demo page

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/constants/demo_constants.dart';
import 'package:aliplayer_widget_example/pages/strategy/strategies/resume_play_strategy.dart';
import 'package:flutter/material.dart';

/// 策略系统演示页面
///
/// 展示如何使用策略系统的差异化能力：
/// - 内置策略的自动运行和数据展示
/// - 自定义策略（记忆播放）的注册与使用
///
/// Strategy system demo page.
class StrategyDemoPage extends StatefulWidget {
  const StrategyDemoPage({super.key});

  @override
  State<StrategyDemoPage> createState() => _StrategyDemoPageState();
}

class _StrategyDemoPageState extends State<StrategyDemoPage> {
  late AliPlayerWidgetController _controller;

  /// 策略原始数据
  int? _prepareCostMs;
  int? _firstFrameCostMs;
  StutterInfo? _stutterInfo;
  int? _savedPositionMs;

  @override
  void initState() {
    super.initState();

    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController();

    // 注册带回调的策略实例，替换内置默认版本 + 添加自定义策略
    _controller.strategyManager
      ..register(FirstFrameStrategy(
        onPrepared: (cost) {
          setState(() {
            _prepareCostMs = cost.inMilliseconds;
          });
        },
        onFirstFrame: (cost) {
          setState(() {
            _firstFrameCostMs = cost.inMilliseconds;
          });
        },
      ))
      ..register(StutterDetectStrategy(
        onStutterDetected: (info) {
          setState(() {
            _stutterInfo = info;
          });
        },
      ))
      ..register(ResumePlayStrategy(
        onPositionSaved: (position) {
          setState(() {
            _savedPositionMs = position.inMilliseconds;
          });
        },
      ));

    // 设置播放器视频源
    final videoSource = VideoSourceFactory.createVidAuthSource(
      vid: DemoConstants.sampleVid,
      playAuth: DemoConstants.samplePlayAuth,
    );

    // 设置播放器组件数据
    final resumePosition = ResumePlayStrategy.getResumePosition(videoSource);
    final data = AliPlayerWidgetData(
      videoSource: videoSource,
      startTime: resumePosition,
    );
    _controller.configure(data);
  }

  @override
  void dispose() {
    // 销毁播放控制器
    _controller.destroy();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('策略系统演示'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        children: [
          // 播放器
          AliPlayerWidget(_controller),
          // 策略数据展示
          Expanded(
            child: _buildStrategyInfoPanel(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  /// 构建策略信息面板
  Widget _buildStrategyInfoPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('策略系统状态'),
          _buildInfoCard(
            icon: Icons.speed,
            title: '首帧统计 (FirstFrameStrategy)',
            content: _formatFirstFrameInfo(),
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            icon: Icons.warning_amber,
            title: '卡顿检测 (StutterDetectStrategy)',
            content: _formatStutterInfo(),
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            icon: Icons.history,
            title: '记忆播放 (ResumePlayStrategy)',
            content: _formatResumeInfo(),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('已注册策略'),
          ..._controller.strategyManager.strategies.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(s.name, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 组合首帧统计展示文本
  String _formatFirstFrameInfo() {
    final parts = <String>[];
    if (_prepareCostMs != null) {
      parts.add('Prepare 耗时: ${_prepareCostMs}ms');
    }
    if (_firstFrameCostMs != null) {
      parts.add('首帧耗时: ${_firstFrameCostMs}ms');
    }
    return parts.isEmpty ? '等待首帧...' : parts.join(' | ');
  }

  /// 组合卡顿检测展示文本
  String _formatStutterInfo() {
    final info = _stutterInfo;
    if (info == null) return '暂无卡顿';
    return '卡顿 ${info.stutterCount}次 | '
        '总时长 ${info.totalStutterDuration.inMilliseconds}ms | '
        '卡顿率 ${(info.stutterRate * 100).toStringAsFixed(1)}%';
  }

  /// 组合续播信息展示文本
  String _formatResumeInfo() {
    final ms = _savedPositionMs;
    if (ms == null) return '暂无续播记录';
    return '已保存进度: ${Duration(milliseconds: ms).inSeconds}s';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.orangeAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

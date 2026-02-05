// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器自定义底部栏组件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/utils/scene_util.dart';
import 'package:flutter/material.dart';

import 'aliplayer_shared_animation_widget.dart';
import 'aliplayer_video_slider.dart';

/// 播放器自定义底部栏组件
class AliPlayerBottomBarWidget extends AliPlayerSharedAnimationWidget {
  /// 播放器场景类型
  final SceneType sceneType;

  /// 播放/暂停按钮的状态
  final bool isPlaying;

  /// 外挂字幕的显示状态
  final bool isShowExternalSubtitle;

  /// 外挂字幕按钮显示状态
  final bool isShowExternalSubtitleBtn;

  /// 播放/暂停按钮点击回调
  final VoidCallback? onPlayIconPressed;

  /// 全屏切换按钮点击回调
  final VoidCallback? onFullScreenPressed;

  /// 刷新按钮点击回调
  final VoidCallback? onReplayIconPressed;

  /// 外挂字幕显示回调
  final VoidCallback? onSubtitlePressed;

  /// 当前播放位置
  final Duration currentPosition;

  /// 视频总时长
  final Duration totalDuration;

  /// 已缓冲的位置
  final Duration bufferedPosition;

  /// 拖拽过程中触发的回调
  final ValueChanged<Duration>? onDragUpdate;

  /// 拖拽结束时触发的回调
  final ValueChanged<Duration>? onDragEnd;

  /// seek 结束时触发的回调
  final ValueChanged<Duration>? onSeekEnd;

  /// 构造函数
  const AliPlayerBottomBarWidget({
    super.key,
    required super.animationManager,
    required this.sceneType,
    required this.isPlaying,
    required this.isShowExternalSubtitle,
    required this.currentPosition,
    required this.totalDuration,
    required this.bufferedPosition,
    required this.onSubtitlePressed,
    this.onPlayIconPressed,
    this.onReplayIconPressed,
    this.onFullScreenPressed,
    this.onDragUpdate,
    this.onDragEnd,
    this.onSeekEnd,
    required this.isShowExternalSubtitleBtn,
  });

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      height: kBottomNavigationBarHeight,
      color: Colors.black.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 左边：播放/暂停按钮
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
            onPressed: onPlayIconPressed,
          ),
          // 中间：刷新按钮（可选：直播场景）
          if (isSceneType(sceneType, [
            SceneType.live,
          ]))
            IconButton(
              onPressed: onReplayIconPressed,
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 30,
              ),
            ),
          // 中间：自定义进度条组件
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AliPlayerVideoSlider(
                currentPosition: currentPosition,
                totalDuration: totalDuration,
                bufferedPosition: bufferedPosition,
                onDragUpdate: onDragUpdate,
                onDragEnd: onDragEnd,
                onSeekEnd: onSeekEnd,
              ),
            ),
          ),

          // 右边: 外挂字幕显示控制
          if (isShowExternalSubtitleBtn)
            IconButton(
              icon: Icon(
                isShowExternalSubtitle ? Icons.subtitles : Icons.subtitles_off,
                color: Colors.white,
                size: 30,
              ),
              onPressed: onSubtitlePressed,
            ),

          // 右边：全屏切换按钮
          IconButton(
            icon: const Icon(
              Icons.fullscreen,
              color: Colors.white,
              size: 30,
            ),
            onPressed: onFullScreenPressed,
          ),
        ],
      ),
    );
  }
}

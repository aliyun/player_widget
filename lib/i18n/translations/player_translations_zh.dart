// Copyright 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/4/7
// Brief: Chinese translations for player widget

import 'dart:ui' show Locale;

import '../player_translations.dart';

/// 中文翻译
///
/// Chinese translations for the player widget.
class PlayerTranslationsZh with PlayerTranslationsMixin {
  @override
  Locale get locale => const Locale('zh');

  @override
  Map<String, dynamic> get translations => {
        'player': {
          'settings': {
            'volume': '声音',
            'brightness': '亮度',
            'subtitle': '字幕',
            'speed': '倍速',
            'quality': '清晰度',
            'loop': '循环播放',
            'mute': '静音播放',
            'mirrorMode': '镜像模式',
            'rotateMode': '旋转模式',
            'scaleMode': '渲染填充',
          },
          'error': {
            'code': '错误码',
            'message': '错误信息',
            'occurred': '发生错误',
            'unknown': '未知错误',
          },
          'prompt': {
            'emptyOption': '暂无可选项',
          },
          'mirror': {
            'none': '无',
            'horizontal': '水平镜像',
            'vertical': '垂直镜像',
          },
          'speed': {'format': '{speed}X', 'speedFastForward': '倍速播放中'},
          'quality': {
            'auto': '自动',
            'unknown': '未知',
          },
          'scale': {
            'fill': '填充',
            'fit': '适应',
            'crop': '裁剪',
          },
          'tip': {
            'downloaded': '已下载',
            'downloading': '正在下载',
            'downloadFailed': '下载失败',
            'downloadStoragePathNotSet':
                '请先调用 AliPlayerWidgetGlobalSetting.setStoragePaths 设置存储路径。',
            'downloadAlreadySaved': '该视频已下载。保存路径: {path}',
            'downloadProgress': '下载进度 ：{progress} %',
            'downloadStart': '开始下载',
          },
          'rotate': {
            'format': '{degree}°',
          },
          'status': {
            'loading': '视频加载中',
            'errorCode': '错误码:',
            'errorMsg': '错误信息:',
            'netSpeed': '网速:',
            'snapSaved': '截图已保存',
            'quality': '画质选择',
            'subtitleOn': '字幕功能：开',
            'subtitleOff': '字幕功能：关',
          },
        },
      };
}

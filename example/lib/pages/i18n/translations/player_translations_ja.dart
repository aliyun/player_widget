// Copyright 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/4/13
// Brief: Japanese translations for player widget (demo)

import 'dart:ui' show Locale;

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

/// 日语翻译
///
/// Japanese translations for the player widget.
class PlayerTranslationsJa with PlayerTranslationsMixin {
  @override
  Locale get locale => const Locale('ja');

  @override
  Map<String, dynamic> get translations => {
        'player': {
          'settings': {
            'volume': '音量',
            'brightness': '明るさ',
            'speed': '再生速度',
            'quality': '画質',
            'loop': 'ループ再生',
            'mute': 'ミュート再生',
            'mirrorMode': 'ミラーモード',
            'rotateMode': '回転モード',
            'scaleMode': '表示モード',
          },
          'error': {
            'code': 'エラーコード',
            'message': 'エラーメッセージ',
            'occurred': 'エラーが発生しました',
            'unknown': '不明なエラー',
          },
          'mirror': {
            'none': 'なし',
            'horizontal': '水平反転',
            'vertical': '垂直反転',
          },
          'speed': {
            'format': '{speed}倍',
          },
          'quality': {
            'auto': '自動',
            'unknown': '不明',
          },
          'scale': {
            'fill': 'フィル',
            'fit': 'フィット',
            'crop': 'クロップ',
          },
          'tip': {
            'downloaded': 'ダウンロード済み',
            'downloading': 'ダウンロード中',
            'downloadFailed': 'ダウンロードに失敗しました',
          },
          'rotate': {
            'format': '{degree}°',
          },
        },
      };
}

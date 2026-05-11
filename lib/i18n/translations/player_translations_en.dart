// Copyright 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/4/7
// Brief: English translations for player widget

import 'dart:ui' show Locale;

import '../player_translations.dart';

/// 英文翻译
///
/// English translations for the player widget.
class PlayerTranslationsEn with PlayerTranslationsMixin {
  @override
  Locale get locale => const Locale('en');

  @override
  Map<String, dynamic> get translations => {
        'player': {
          'settings': {
            'volume': 'Volume',
            'brightness': 'Brightness',
            'subtitle': 'Subtitle',
            'speed': 'Speed',
            'quality': 'Quality',
            'loop': 'Loop',
            'mute': 'Mute',
            'mirrorMode': 'Mirror Mode',
            'rotateMode': 'Rotation',
            'scaleMode': 'Scale Mode',
          },
          'error': {
            'code': 'Error Code',
            'message': 'Error Message',
            'occurred': 'An error occurred',
            'unknown': 'Unknown error',
          },
          'prompt': {
            'emptyOption': 'No Options Available',
          },
          'mirror': {
            'none': 'None',
            'horizontal': 'Horizontal',
            'vertical': 'Vertical',
          },
          'speed': {
            'format': '{speed}X',
            'speedFastForward': 'Playback Speed',
          },
          'quality': {
            'auto': 'Auto',
            'unknown': 'Unknown',
          },
          'scale': {
            'fill': 'Fill',
            'fit': 'Fit',
            'crop': 'Crop',
          },
          'tip': {
            'downloaded': 'Downloaded',
            'downloading': 'Downloading',
            'downloadFailed': 'Download Failed',
            'downloadStoragePathNotSet':
                'Please call AliPlayerWidgetGlobalSetting.setStoragePaths to set storage paths first.',
            'downloadAlreadySaved':
                'This video has already been downloaded. Save path: {path}',
          },
          'rotate': {
            'format': '{degree}°',
          },
          'status': {
            'loading': 'Video Loading',
            'errorCode': 'Error Code:',
            'errorMsg': 'Error Message:',
            'netSpeed': 'Net Speed:',
            'snapSaved': 'Screenshot saved',
            'quality': 'Video Quality',
            'subtitleOn': 'Subtitle: On',
            'subtitleOff': 'Subtitle: Off',
          },
        },
      };
}

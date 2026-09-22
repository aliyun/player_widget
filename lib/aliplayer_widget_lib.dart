// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/10
// Brief: AliPlayer Widget Library

/// AliPlayer Widget Library
///
/// A powerful and flexible vod component for Flutter applications.
/// It integrates with flutter_aliplayer to provide high-quality video playback,
/// seamless streaming, and a rich set of features for both live and on-demand video content.
/// Whether you are building a video playback solution for education, entertainment,
/// or any other application, it makes it easy to deliver an engaging video experience.

library aliplayer_widget_lib;

// 导出核心依赖
export 'package:flutter_aliplayer/flutter_avpdef.dart';
export 'package:flutter_aliplayer/flutter_aliplayer.dart';
export 'package:flutter_aliplayer/flutter_aliplayer_global_setting.dart';
export 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';

// 导出 i18n 模块
export 'i18n/i18n.dart';

// 导出插槽模块
export 'slot/slot.dart';

// 导出字幕模块
export 'subtitle/subtitle.dart';

// 导出策略模块
export 'strategy/strategy.dart';

// 导出主题模块
export 'theme/theme.dart';

// 导出数据模型
export 'data/data.dart';

// 导出下载模块
export 'download/download.dart';

// 导出工具类
export 'utils/privacy_util.dart';

// 导入必要的依赖
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:aliplayer_widget/constants/setting_constants.dart';
import 'package:aliplayer_widget/ui/common/content_view_type.dart';
import 'package:aliplayer_widget/base/safe_value_notifier.dart';
import 'package:aliplayer_widget/i18n/i18n.dart';
import 'package:aliplayer_widget/subtitle/subtitle.dart';
import 'package:aliplayer_widget/manager/file_manager.dart';
import 'package:aliplayer_widget/ui/common/shared_animation_manager.dart';
import 'package:aliplayer_widget/manager/storage_path_manager.dart';
import 'package:aliplayer_widget/data/data.dart';
import 'package:aliplayer_widget/download/download.dart';
import 'package:aliplayer_widget/slot/slot.dart';
import 'package:aliplayer_widget/theme/theme.dart';
import 'package:aliplayer_widget/ui/play_state_overlay.dart';
import 'package:aliplayer_widget/utils/scene_util.dart';
import 'package:aliplayer_widget/utils/screen_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_global_setting.dart';
import 'package:flutter_aliplayer/flutter_alidownloader.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'manager/scenario_manager.dart';
import 'ui/setting/setting_panel_manager.dart';
import 'strategy/strategy.dart';
import 'utils/log_util.dart';
import 'utils/track_info_util.dart';
import 'utils/full_screen_util.dart';

// 引入 AliPlayer Widget 的实现
part 'aliplayer_widget.dart';

part 'ui/full_screen_widget.dart';

part 'aliplayer_widget_controller.dart';

part 'aliplayer_widget_data.dart';

part 'aliplayer_widget_global_setting.dart';

part 'download/download_manager.dart';

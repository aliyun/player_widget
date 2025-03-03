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

// 导入必要的依赖
import 'dart:ui';

import 'package:aliplayer_widget/constants/setting_constants.dart';
import 'package:aliplayer_widget/base/safe_value_notifier.dart';
import 'package:aliplayer_widget/manager/shared_animation_manager.dart';
import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:aliplayer_widget/utils/scene_util.dart';
import 'package:aliplayer_widget/utils/screen_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_global_setting.dart';

import 'ui/aliplayer_center_display_widget.dart';
import 'ui/aliplayer_cover_image_widget.dart';
import 'ui/aliplayer_custom_slider_widget.dart';
import 'ui/aliplayer_top_bar_widget.dart';
import 'ui/aliplayer_bottom_bar_widget.dart';
import 'ui/aliplayer_play_control_widget.dart';
import 'ui/aliplayer_play_state_widget.dart';
import 'ui/aliplayer_seek_thumbnail_widget.dart';
import 'ui/aliplayer_setting_menu_panel.dart';
import 'utils/log_util.dart';
import 'utils/snack_bar_util.dart';
import 'utils/track_info_util.dart';
import 'utils/vibration_util.dart';
import 'utils/full_screen_util.dart';

// 引入 AliPlayer Widget 的实现
part 'aliplayer_widget.dart';

part 'aliplayer_widget_controller.dart';

part 'aliplayer_widget_data.dart';

part 'aliplayer_widget_global_setting.dart';

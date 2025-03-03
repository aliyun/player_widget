// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/25
// Brief: A safe implementation of ChangeNotifier that prevents errors after disposal.

import 'package:flutter/foundation.dart';

import 'safe_notifier_mixin.dart';

/// A safe implementation of ChangeNotifier that prevents errors after disposal.
///
/// ChangeNotifier 的安全实现，防止在释放后发生错误
class SafeChangeNotifier extends ChangeNotifier with SafeNotifierMixin {}

// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/25
// Brief: A safe implementation of ValueNotifier that prevents errors after disposal.

import 'package:flutter/foundation.dart';

import 'safe_notifier_mixin.dart';

/// A safe implementation of ValueNotifier that prevents errors after disposal.
///
/// ValueNotifier 的安全实现，防止在释放后出错。
class SafeValueNotifier<T> extends ValueNotifier<T> with SafeNotifierMixin {
  SafeValueNotifier(super.value);
}

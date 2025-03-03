// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/28
// Brief: 滑动窗口模版类

/// A generic class that manages sliding window loading and cancellation for a collection of items.
///
/// 一个滑动窗口的功能，用于管理和处理待执行的数据操作。
class AliSlidingWindow<T> {
  /// Function to execute an item.
  ///
  /// 执行项目的回调函数
  final void Function(T item) execute;

  /// Function to cancel an item.
  ///
  /// 取消项目的回调函数，可选
  final void Function(T item)? cancel;

  /// Function to check if an item is valid.
  ///
  /// 检查项目是否有效的回调函数
  final bool Function(T item) isValid;

  /// The extra information used to identify the source of data.
  ///
  /// 额外信息，用于标识数据来源
  final String extra;

  /// The window range for managing sliding window loading and cancellation.
  ///
  /// 滑动窗口的范围
  final List<int> _windowItems;

  /// The list of items to be managed.
  ///
  /// 待管理的项目列表
  final List<T> _itemList = [];

  /// The set of items that have been executed.
  ///
  /// 已执行的项目集合
  final Set<T> _executedItemSets = {};

  /// The current index in the item list.
  ///
  /// 当前项目列表中的索引
  int _currentIndex = -1;

  /// Constructor for SlidingWindowManager with specified left and right window sizes.
  ///
  /// 构造函数，指定左右窗口大小
  AliSlidingWindow.withWindowSize(
    int leftWindowSize,
    int rightWindowSize,
    this.execute,
    this.cancel, {
    bool Function(T)? isValid,
    this.extra = '',
  })  : assert(leftWindowSize >= 0),
        assert(rightWindowSize >= 0),
        isValid = isValid ?? _defaultIsValid<T>(),
        _windowItems = _getWindowRange(leftWindowSize, rightWindowSize);

  /// Constructor for SlidingWindowManager with custom window items.
  ///
  /// 构造函数，指定自定义窗口范围
  AliSlidingWindow.withCustomItems(
    List<int> items,
    this.execute,
    this.cancel, {
    bool Function(T)? isValid,
    this.extra = '',
  })  : isValid = isValid ?? _defaultIsValid<T>(),
        _windowItems = List.from(items);

  /// Default implementation for isValid.
  ///
  /// 默认的 isValid 实现。
  static bool Function(T) _defaultIsValid<T>() {
    return (T item) => true;
  }

  /// Set the items to be managed.
  ///
  /// 设置需要管理的项目列表
  void setItems(List<T> items) {
    cancelAll();
    _itemList.clear();
    for (var item in items) {
      if (isValid(item)) {
        _itemList.add(item);
      }
    }
  }

  /// Add new items to the existing item list.
  ///
  /// 向现有项目列表中添加新项目
  void addItems(List<T> items) {
    for (var item in items) {
      if (isValid(item)) {
        _itemList.add(item);
      }
    }
  }

  /// Move to a specified position in the item list and execute new items.
  ///
  /// 移动到指定位置并执行新项目
  void moveTo(int position) {
    if (position < 0 || position >= _itemList.length) return;
    if (_currentIndex == position) return;

    final currentWindow = getWindowIndices(position);
    if (currentWindow.isEmpty) return;

    final previousWindow = getWindowIndices(_currentIndex);
    final toLoad = _difference(currentWindow, previousWindow);
    final toCancel = _difference(previousWindow, currentWindow);

    _processItems(toCancel, _cancelItem);
    _processItems(toLoad, _executeItem);

    _currentIndex = position;
  }

  /// Process a list of items using the provided processor function.
  ///
  /// 使用提供的处理器函数处理项目列表
  void _processItems(List<T> items, void Function(T item) processor) {
    for (var item in items) {
      if (item != null) processor(item);
    }
  }

  /// Cancel an item.
  ///
  /// 取消单个项目
  void _cancelItem(T item) {
    if (_executedItemSets.contains(item)) {
      _executedItemSets.remove(item);
      cancel?.call(item);
    }
  }

  /// Execute an item.
  ///
  /// 执行单个项目
  void _executeItem(T item) {
    if (!_executedItemSets.contains(item)) {
      _executedItemSets.add(item);
      execute(item);
    }
  }

  /// Get items within the sliding window based on the current position.
  ///
  /// 根据当前位置获取滑动窗口内的项目
  List<T> getWindowIndices(int position) {
    if (position < 0 || position >= _itemList.length) return [];
    final windowIndices = <T>[];
    for (var offset in _windowItems) {
      final index = position + offset;
      if (index >= 0 && index < _itemList.length) {
        windowIndices.add(_itemList[index]);
      }
    }
    return windowIndices;
  }

  /// Release resources, cancel all ongoing operations.
  ///
  /// 释放资源，取消所有正在进行的操作
  void release() {
    cancelAll();
    _currentIndex = -1;
  }

  /// Cancel all ongoing operations and clear the item list.
  ///
  /// 取消所有正在进行的操作并清空项目列表
  void cancelAll() {
    for (var item in _executedItemSets) {
      cancel?.call(item);
    }
    _executedItemSets.clear();
    _itemList.clear();
  }

  /// Retrieve the current position in the item list.
  ///
  /// 获取当前项目列表中的位置
  int getCurrentPosition() => _currentIndex;

  /// Helper method to generate window range.
  ///
  /// 辅助方法，生成滑动窗口的范围
  static List<int> _getWindowRange(int leftWindowSize, int rightWindowSize) {
    final totalSize = leftWindowSize + rightWindowSize + 1;
    return List.generate(totalSize, (i) => i - leftWindowSize);
  }

  /// Helper method to calculate the difference between two lists.
  ///
  /// 辅助方法，用于计算两个列表的差集
  List<T> _difference(List<T> list1, List<T> list2) {
    final set2 = Set.from(list2);
    return list1.where((item) => !set2.contains(item)).toList();
  }
}

// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junhuiYe
// Date: 2025/7/15
// Brief: Subtitle data models including subtitle collection and single subtitle entity.

/// 字幕集合，管理多条字幕轨道。
///
/// 提供字幕的增删查操作，内部维护一个 [Subtitle] 列表。
///
/// Subtitle collection that manages multiple subtitle tracks.
///
/// Provides add, remove, and query operations for subtitles,
/// maintaining an internal list of [Subtitle] entries.
class Subtitles {
  /// 创建字幕集合。
  ///
  /// Creates a subtitle collection.
  ///
  /// - [subtitles] 初始字幕列表。
  ///   The initial list of subtitles.
  Subtitles(this.subtitles);

  /// 字幕列表。
  ///
  /// The list of subtitles.
  final List<Subtitle> subtitles;

  /// 判断字幕集合是否为空。
  ///
  /// Whether the subtitle collection is empty.
  bool get isEmpty => subtitles.isEmpty;

  /// 判断字幕集合是否不为空。
  ///
  /// Whether the subtitle collection is not empty.
  bool get isNotEmpty => !isEmpty;

  /// 添加一条字幕。
  ///
  /// Adds a [subtitle] to the collection.
  void addSubtitle(Subtitle subtitle) {
    subtitles.add(subtitle);
  }

  /// 根据轨道索引获取字幕。
  ///
  /// 返回所有匹配指定 [trackIndex] 的字幕列表。
  ///
  /// Returns all subtitles matching the given [trackIndex].
  List<Subtitle> getByTrackIndex(int trackIndex) {
    return subtitles.where((subtitle) => subtitle.index == trackIndex).toList();
  }

  /// 根据轨道索引移除字幕。
  ///
  /// 移除所有匹配指定 [trackIndex] 的字幕，并返回被移除的字幕列表。
  ///
  /// Removes all subtitles matching the given [trackIndex]
  /// and returns the removed subtitle list.
  List<Subtitle> removeSubtitle(int trackIndex) {
    // 获取待删除的字幕
    final toBeRemoved =
        subtitles.where((subtitle) => subtitle.index == trackIndex).toList();

    // 删除符合条件的字幕
    subtitles.removeWhere((subtitle) => subtitle.index == trackIndex);

    // 返回被删除的字幕列表
    return toBeRemoved;
  }

  /// 返回当前字幕集合的字符串表示，包含内部字幕列表。
  ///
  /// Returns the string representation of this subtitle collection,
  /// including the internal list of subtitles.
  @override
  String toString() {
    return 'Subtitles{subtitles: $subtitles}';
  }
}

/// 单条字幕实体，包含轨道索引和字幕文本。
///
/// 表示一条具体的字幕数据，通过 [index] 标识所属轨道，
/// 通过 [text] 存储字幕文本内容。
///
/// A single subtitle entity containing track index and subtitle text.
///
/// Represents a concrete subtitle entry, identified by [index] for its track
/// and storing the subtitle content in [text].
class Subtitle {
  /// 创建一条字幕实体。
  ///
  /// Creates a subtitle entity.
  ///
  /// - [index] 字幕轨道索引。
  ///   The subtitle track index.
  /// - [text] 字幕文本内容。
  ///   The subtitle text content.
  Subtitle({
    required this.index,
    required this.text,
  });

  /// 字幕轨道索引。
  ///
  /// The subtitle track index.
  final int index;

  /// 字幕文本内容。
  ///
  /// The subtitle text content.
  final String text;

  /// 创建当前字幕的副本，可选覆盖部分属性。
  ///
  /// Creates a copy of this subtitle with optionally overridden properties.
  Subtitle copyWith({
    int? index,
    String? text,
  }) {
    return Subtitle(
      index: index ?? this.index,
      text: text ?? this.text,
    );
  }

  /// 返回当前字幕实体的字符串表示，包含轨道索引和字幕文本。
  ///
  /// Returns the string representation of this subtitle entity,
  /// including the track index and subtitle text.
  @override
  String toString() {
    return 'Subtitle(index: $index, text: $text)';
  }

  /// 判断两个字幕是否相等。
  ///
  /// 当 [index] 和 [text] 均相同时视为相等。
  ///
  /// Determines whether two subtitles are equal.
  ///
  /// Two subtitles are considered equal when both [index] and [text] match.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subtitle && other.index == index && other.text == text;
  }

  /// 基于 [index] 和 [text] 计算哈希值。
  ///
  /// Computes the hash code based on [index] and [text].
  @override
  int get hashCode => Object.hash(index, text);
}

// Copyright © 2025 Alibaba Cloud. All rights reserved.

// @author junhuiYe
// @date 2025/7/15 14:03
// @brief 字幕实体

class Subtitles {
  Subtitles(this.subtitles);

  // 字幕列表，确保不包含null
  final List<Subtitle> subtitles;

  bool get isEmpty => subtitles.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // 添加字幕
  void addSubtitle(Subtitle subtitle) {
    subtitles.add(subtitle);
  }

  // 根据 trackIndex 获取字幕
  List<Subtitle> getByTrackIndex(int trackIndex) {
    return subtitles.where((subtitle) => subtitle.index == trackIndex).toList();
  }

  // 删除指定 index 的字幕
  List<Subtitle> removeSubtitle(int trackIndex) {
    // 获取待删除的字幕
    final toBeRemoved =
        subtitles.where((subtitle) => subtitle.index == trackIndex).toList();

    // 删除符合条件的字幕
    subtitles.removeWhere((subtitle) => subtitle.index == trackIndex);

    // 返回被删除的字幕列表
    return toBeRemoved;
  }

  @override
  String toString() {
    return 'Subtitles{subtitles: $subtitles}';
  }
}

class Subtitle {
  Subtitle({
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  // 克隆方法
  Subtitle copyWith({
    int? index,
    Duration? start,
    Duration? end,
    String? text,
  }) {
    return Subtitle(
      index: index ?? this.index,
      text: text ?? this.text,
    );
  }

  @override
  String toString() {
    return 'Subtitle(index: $index, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subtitle && other.index == index && other.text == text;
  }

  @override
  int get hashCode {
    return index.hashCode ^ text.hashCode;
  }
}

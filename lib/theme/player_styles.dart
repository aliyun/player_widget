// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/04/03
// Brief: Design tokens for aliplayer_widget UI.

import 'package:flutter/material.dart';

/// 播放器 UI 设计 Token
///
/// 命名规则：`color`/`fontSize`/`iconSize`/`padding` + 语义
///
/// 使用原则：禁止硬编码，必须通过 Token 引用
abstract final class PlayerStyles {
  PlayerStyles._();

  // ─── 颜色 ────────────────────────────────────────────────
  /// 顶部栏图标/文字颜色
  static const Color colorOnPrimary = Colors.white;

  /// 顶部栏背景色
  static const Color colorBarBackground = Color(0x4D000000);

  /// 设置面板背景色
  static const Color colorSettingPanel = Color(0xb3000000);

  /// 设置面板列表项颜色
  static const Color colorSettingPanelItem = Color(0x1aFFFFFF);

  // ─── 字号 ────────────────────────────────────────────────
  /// 顶部栏标题字号
  static const double fontSizeTitle = 16.0;

  /// Common 通用 Text 大小
  static const double commonTextSize = 14;

  /// Common 通用 Icon 大小
  static const double commonIconSize = 30;

  /// Common 通用 Slide 大小
  static const double commonSliderHeight = 4.0;

  // ─── 字体样式 ────────────────────────────────────────────
  /// 顶部栏标题字号
  static const FontWeight fontWeightTitle = FontWeight.w500;

  // ─── 图标尺寸 ────────────────────────────────────────────
  /// 顶部栏图标尺寸
  static const double iconSizeTopBar = 24.0;

  // ─── 间距 ───────────────────────────────────────────────
  /// 顶部栏按钮间距
  static const EdgeInsets paddingBarButton = EdgeInsets.only(left: 4.0);

  // =========================== 颜色常量 ===========================

  // ---------- 通用/其他模块 ----------
  /// 倍速模式背景颜色
  static const Color kControlWidgetColor = Color(0xCC1C1D22);

  // ---------- 进度条模块 ----------
  /// 进度条背景颜色
  static const Color kSliderBackgroundColor = Color(0x4dFFFFFF);

  /// 进度条缓冲颜色
  static const Color kSliderBufferColor = Color(0x40FFFFFF);

  /// 进度条进度颜色
  static const Color kSliderProgressColor = Color(0x99FFFFFF);

  /// 进度条指示器颜色
  static const Color kSliderThumbColor = Color(0xFFFFFFFF);

  /// 进度条时间显示阴影颜色
  static const Color kColorProgressBarTimeShadow = Color(0x80616060);

  // =========================== 尺寸常量 ===========================

  // ---------- 通用/基础 ----------
  /// 默认缩略图宽高比
  static const double kDefaultThumbnailAspectRatio = 16 / 9;

  // ---------- 顶部栏模块 ----------
  /// 顶部栏高度
  static const double kTopBarHeight = 48.0;

  // ---------- 底部栏模块 ----------
  /// 竖屏 BottomBar 高度
  static const double kBottomBarHeight = 58;

  /// 横屏 BottomBar 高度
  static const double kLandscapeBottomBarHeight = 88;

  /// 横屏 BottomBar 边距
  static const double kLandscapeBottomBarPadding = 34;

  /// BottomBar Icon 大小
  static const double kBottomBarIconSize = 23;

  /// 图标水平边距
  static const double kIconHorizontalMargin = 8.0;

  /// BottomBar Button 边距
  static const double kBottomBarButtonPadding = 19;

  /// BottomBar ControlButton 边距
  static const double kBottomBarControlBtnPadding = 15;

  // ---------- 中心控制区模块 ----------
  /// 中心状态控制栏整体宽度
  static const double kControlWidgetWidth = 180;

  /// 中心状态控制栏整体高度
  static const double kControlWidgetHeight = 45;

  /// 中心状态滑动框
  static const double kControlSlideWidth = 92;

  /// 中心状态控制控件边距
  static const double kControlWidgetItemPadding = 8;

  /// 中心状态控制控件上下边距
  static const double kControlVerticalInsets = 12;

  /// 中心状态控制控件左右边距
  static const double kControlHorizontalInsets = 14;

  /// 中心状态控制栏滑动 Thumb 尺寸大小
  static const double kControlSliderThumbRadius = 4;

  /// 中心状态控制栏滑动 Thumb 阴影大小
  static const double kControlSliderElevation = 2;

  /// 中心状态控制栏 显示文字默认宽度
  static const double kControlValueWidth = 25;

  // ---------- 顶部栏横屏布局 ----------
  /// 顶部栏横屏水平边距
  static const double kTopBarLandscapeHorizontalMargin = 0.0;

  /// 顶部栏竖屏水平边距
  static const double kTopBarPortraitHorizontalMargin = 20.0;

  /// 顶部栏横屏返回按钮左边距
  static const double kTopBarLandscapeBackButtonLeftMargin = 34.0;

  /// 顶部栏横屏右侧按钮右边距
  static const double kTopBarLandscapeRightButtonRightMargin = 34.0;

  // ---------- 底部栏竖屏布局 ----------
  /// 底部栏竖屏水平内边距
  static const double kBottomBarPortraitHorizontalPadding = 20.0;

  /// 底部栏竖屏垂直内边距
  static const double kBottomBarPortraitVerticalPadding = 12.0;

  /// 视频进度条控件内边距
  static const double kVideoSliderHorizontalPadding = 6.0;

  // ---------- 中心显示区域 ----------
  /// 中心显示控件顶部额外边距
  static const double kCenterDisplayTopExtraPadding = 15.0;

  /// 中心显示控件圆角半径
  static const double kCenterDisplayBorderRadius = 8.0;

  // ---------- Seek 缩略图 ----------
  /// 缩略图宽度
  static const double kThumbnailWidth = 120.0;

  /// 缩略图圆角
  static const double kThumbnailBorderRadius = 4.0;

  /// 缩略图与时间文本间距
  static const double kThumbnailTimeSpacing = 8.0;

  /// 缩略图 底部间距
  static const double kSeekThumbnailBottomOffset = 30.0;

  /// Seek 缩略图时间文本字号
  static const double kSeekThumbnailTimeFontSize = 16.0;

  // ---------- 播放状态 ----------
  /// 播放状态错误图标尺寸
  static const double kPlayStateIconSize = 64.0;

  /// 播放状态错误图标与信息间距
  static const double kPlayStateIconMessageSpacing = 16.0;

  /// 播放状态错误信息字号
  static const double kPlayStateErrorFontSize = 14.0;

  // ---------- 倍速显示 ----------
  /// 倍速文本字号
  static const double kSpeedDisplayFontSize = 16.0;

  /// 倍速图标与文字间距
  static const double kSpeedDisplayIconTextSpacing = 8.0;

  // ---------- 设置面板 ----------
  /// 横屏设置面板宽度
  static const double kLandscapeSettingPanelWidth = 345.0;

  /// 竖屏设置面板顶部间距
  static const double kPortraitSettingPanelTopMargin = 26.0;

  /// 右侧滚轮设置面板宽度
  static const double kRightWheelPanelWidth = 207.0;

  /// 内边距布局
  static const double kSettingPanelPaddingAll = 20.0;

  /// 分割线高度
  static const double kSettingPanelLineHeight = 1.0;

  /// 内部横屏单项高度
  static const double kSettingPanelLandScapeHeight = 52.0;

  /// 内部竖屏单项高度
  static const double kSettingPanelPortraitHeight = 46.0;

  /// 横屏单项分割线外边距
  static const double kSettingPanelLandScapeDividerMargin = 20.0;

  /// 竖屏单项分割线外边距
  static const double kSettingPanelPortraitDividerMargin = 16.0;

  /// 横屏内边距布局
  static const double kSettingPanelLandScapePadding = 24.0;

  /// 列表项内边距
  static const double kSettingPanelItemPadding = 16.0;

  /// 播放器状态栏 默认内边距
  static const double kStatusWidgetPadding = 16;

  /// 播放器状态栏 默认圆角尺寸
  static const double kStatusWidgetRadius = 8;
}

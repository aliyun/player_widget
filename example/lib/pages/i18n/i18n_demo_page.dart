// Copyright 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/4/13
// Brief: Demo page showing how to customize and replace languages

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:flutter/material.dart';

import 'translations/player_translations_ja.dart';

/// 国际化自定义演示页面
///
/// Demo page showing how to customize and replace languages.
///
/// Features demonstrated:
/// - Switching languages at runtime
/// - Registering new language packs (e.g., Japanese)
/// - Overriding built-in translations
class I18nDemoPage extends StatefulWidget {
  const I18nDemoPage({super.key});

  @override
  State<I18nDemoPage> createState() => _I18nDemoPageState();
}

class _I18nDemoPageState extends State<I18nDemoPage> {
  /// 当前选中的语言
  String _currentLanguage = 'zh';

  /// 是否已注册日语
  bool _isJapaneseRegistered = false;

  /// 是否已覆盖中文翻译
  bool _isChineseOverridden = false;

  @override
  void initState() {
    super.initState();
    _currentLanguage = AliPlayerWidgetGlobalSetting.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('国际化自定义 Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            title: '1. 当前语言',
            children: [
              _buildCurrentLanguageCard(),
              const SizedBox(height: 8),
              _buildTranslationPreviewCard(),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: '2. 切换语言',
            children: [_buildLanguageSwitchButtons()],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: '3. 注册新语言包（日语）',
            children: [_buildRegisterJapaneseSection()],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: '4. 覆盖内置翻译',
            children: [_buildOverrideTranslationsSection()],
          ),
        ],
      ),
    );
  }

  /// 构建章节标题
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// 构建当前语言卡片
  Widget _buildCurrentLanguageCard() {
    return ValueListenableBuilder<Locale>(
      valueListenable: AliPlayerWidgetGlobalSetting.localeNotifier,
      builder: (context, locale, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.language, color: Colors.orangeAccent),
                const SizedBox(width: 12),
                Text(
                  '当前语言: ${_getLanguageName(locale.languageCode)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建翻译预览卡片
  Widget _buildTranslationPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '翻译预览:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildTranslationItem(PlayerI18nKeys.volume),
            _buildTranslationItem(PlayerI18nKeys.brightness),
            _buildTranslationItem(PlayerI18nKeys.speed),
            _buildTranslationItem(PlayerI18nKeys.quality),
          ],
        ),
      ),
    );
  }

  /// 构建单个翻译项
  Widget _buildTranslationItem(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              key.split('.').last,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              AliPlayerWidgetGlobalSetting.t(key),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建语言切换按钮
  Widget _buildLanguageSwitchButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildLanguageButton('zh', '中文'),
        _buildLanguageButton('en', 'English'),
        if (_isJapaneseRegistered) _buildLanguageButton('ja', '日本語'),
      ],
    );
  }

  /// 构建单个语言按钮
  Widget _buildLanguageButton(String langCode, String label) {
    final isSelected = _currentLanguage == langCode;
    return ElevatedButton(
      onPressed: () => _switchLanguage(langCode),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.orangeAccent : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
      ),
      child: Text(label),
    );
  }

  /// 构建注册日语部分
  Widget _buildRegisterJapaneseSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isJapaneseRegistered ? '✓ 日语语言包已注册' : '点击按钮注册日语语言包',
              style: TextStyle(
                fontSize: 14,
                color:
                    _isJapaneseRegistered ? Colors.green : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isJapaneseRegistered ? null : _registerJapanese,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('注册日语语言包'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建覆盖翻译部分
  Widget _buildOverrideTranslationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isChineseOverridden ? '✓ 中文翻译已覆盖' : '点击按钮覆盖中文翻译',
              style: TextStyle(
                fontSize: 14,
                color:
                    _isChineseOverridden ? Colors.green : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isChineseOverridden ? null : _overrideChinese,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('覆盖中文翻译'),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取语言名称
  String _getLanguageName(String langCode) {
    switch (langCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return langCode;
    }
  }

  /// 切换语言
  void _switchLanguage(String langCode) {
    setState(() {
      _currentLanguage = langCode;
    });
    AliPlayerWidgetGlobalSetting.setLocale(Locale(langCode));
  }

  /// 注册日语语言包
  ///
  /// 使用 AliPlayerWidgetGlobalSetting.registerTranslations() 注册自定义语言包。
  /// 需要实现 PlayerTranslations 接口（推荐使用 PlayerTranslationsMixin）。
  void _registerJapanese() {
    AliPlayerWidgetGlobalSetting.registerTranslations(PlayerTranslationsJa());
    setState(() {
      _isJapaneseRegistered = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('日语语言包已注册，现在可以切换到日语')),
    );
  }

  /// 覆盖中文翻译
  ///
  /// 使用 AliPlayerWidgetGlobalSetting.overrideTranslations() 覆盖特定语言的某些翻译项。
  /// 不需要提供完整的翻译表，只需提供要覆盖的部分。
  void _overrideChinese() {
    AliPlayerWidgetGlobalSetting.overrideTranslations('zh', {
      'player': {
        'settings': {
          'volume': '🔊 音量',
          'brightness': '🔆 亮度',
          'speed': '⚡ 倍速',
          'quality': '📺 清晰度',
        },
      },
    });
    setState(() {
      _isChineseOverridden = true;
    });
    // 强制刷新以应用覆盖
    AliPlayerWidgetGlobalSetting.setLocale(const Locale('zh'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('中文翻译已覆盖')),
    );
  }
}

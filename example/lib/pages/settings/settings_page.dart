// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/20
// Brief: 设置页面

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/constants/page_routes.dart';
import 'package:aliplayer_widget_example/utils/navigate_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // 数据结构定义
    final List<SettingItem> items = [
      SectionHeader(title: "通用"),
      ButtonItem(
        title: "链接设置",
        onPressed: () {
          NavigateUtil.pushWithRoute(context, PageRoutes.link);
        },
      ),
      ButtonItem(
        title: "清除缓存",
        onPressed: () {
          AliPlayerWidgetController.clearCaches();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("清除缓存成功"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      SectionHeader(title: "调试"),
      ButtonItem(
        title: "调试页面",
        onPressed: () {
          NavigateUtil.pushWithRoute(context, PageRoutes.debug);
        },
      ),
      SectionHeader(title: "其它"),
      TextItem(
        title: "设备 UUID",
        subtitleLoader: () async {
          final version = await FlutterAliplayer.getDeviceUUID();
          return version;
        },
      ),
      TextItem(
        title: "SDK 版本号",
        subtitleLoader: () async {
          final sdkVersion = await FlutterAliplayer.getSDKVersion();
          return sdkVersion;
        },
      ),
      TextItem(
        title: "Widget 版本号",
        subtitleLoader: () async {
          final version = await AliPlayerWidgetController.getWidgetVersion();
          return version;
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is SectionHeader) {
            return _buildSectionHeader(item);
          }

          final Widget itemView;
          if (item is SwitchItem) {
            itemView = _buildSwitchItem(item);
          } else if (item is SelectionItem) {
            itemView = _buildSelectionItem(item);
          } else if (item is ButtonItem) {
            itemView = _buildButtonItem(item);
          } else if (item is TextItem) {
            itemView = _buildTextItem(item);
          } else {
            return const SizedBox.shrink();
          }
          return Container(
            color: Colors.white,
            child: itemView,
          );
        },
      ),
    );
  }

  // 构建 Section Header
  Widget _buildSectionHeader(SectionHeader item) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        item.title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  // 构建 Switch Item
  Widget _buildSwitchItem(SwitchItem item) {
    return FutureBuilder<bool>(
      future: item.valueLoader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(item.title),
            trailing: const CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text(item.title),
            subtitle: Text("Error: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          return ListTile(
            title: Text(item.title),
            trailing: Switch(
              value: snapshot.data!,
              onChanged: (value) {
                setState(() {
                  item.onChanged(value);
                });
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // 构建 Selection Item
  Widget _buildSelectionItem(SelectionItem item) {
    return FutureBuilder<List<String>>(
      future: item.optionsLoader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(item.title),
            trailing: const CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text(item.title),
            subtitle: Text("Error: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          final options = snapshot.data!;
          return ListTile(
            title: Text(item.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.selectedOption),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(item.title),
                  children: options.map((option) {
                    return ListTile(
                      title: Text(option),
                      onTap: () {
                        Navigator.pop(context, option);
                      },
                    );
                  }).toList(),
                ),
              );
              if (selected != null) {
                setState(() {
                  item.onSelected(selected);
                });
              }
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // 构建 Button Item
  Widget _buildButtonItem(ButtonItem item) {
    return ListTile(
      title: Text(item.title),
      onTap: item.onPressed,
    );
  }

  // 构建 Text Item
  Widget _buildTextItem(TextItem item) {
    return FutureBuilder<String>(
      future: item.subtitleLoader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(item.title),
            subtitle: const Text("Loading..."),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text(item.title),
            subtitle: Text("Error: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          return ListTile(
            title: Text(item.title),
            subtitle: Text(snapshot.data!),
            onTap: () {
              Clipboard.setData(ClipboardData(text: snapshot.data ?? ""));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Copied to clipboard"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// 抽象数据结构
abstract class SettingItem {}

class SectionHeader extends SettingItem {
  final String title;

  SectionHeader({required this.title});
}

class SwitchItem extends SettingItem {
  final String title;
  final Future<bool> Function() valueLoader;
  final ValueChanged<bool> onChanged;

  SwitchItem({
    required this.title,
    required this.valueLoader,
    required this.onChanged,
  });
}

class SelectionItem extends SettingItem {
  final String title;
  final Future<List<String>> Function() optionsLoader;
  String selectedOption;
  final ValueChanged<String> onSelected;

  SelectionItem({
    required this.title,
    required this.optionsLoader,
    required this.selectedOption,
    required this.onSelected,
  });
}

class ButtonItem extends SettingItem {
  final String title;
  final VoidCallback onPressed;

  ButtonItem({
    required this.title,
    required this.onPressed,
  });
}

class TextItem extends SettingItem {
  final String title;
  final Future<String> Function() subtitleLoader;

  TextItem({
    required this.title,
    required this.subtitleLoader,
  });
}

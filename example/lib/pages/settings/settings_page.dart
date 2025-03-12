// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/20
// Brief: 设置页面

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/constants/demo_constants.dart';
import 'package:aliplayer_widget_example/constants/page_routes.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:aliplayer_widget_example/utils/http_util.dart';
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
      SectionHeader(title: "配置"),
      SelectionItem<ShortVideoResource>(
        title: "短视频资源",
        optionsLoader: _fetchVideoResources,
        selectedOptionLoader: (options) async {
          return _fetchSelectedVideoResource(options);
        },
        onSelected: (resource) {
          SPManager.instance.saveString(
            DemoConstants.keyDramaInfoListUrl,
            resource.url,
          );
        },
        displayFormatter: (resource) => resource.title,
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
          final version = AliPlayerWidgetController.getWidgetVersion();
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

  // 这个方法将用于处理所有 SelectionItem 类型
  Widget _buildSelectionItem(SettingItem item) {
    if (item is SelectionItem<String>) {
      return _buildTypedSelectionItem<String>(item);
    } else if (item is SelectionItem<ShortVideoResource>) {
      return _buildTypedSelectionItem<ShortVideoResource>(item);
    }
    return const ListTile(
      title: Text("未支持的 SelectionItem 类型"),
      subtitle: Text("请在 _buildSelectionItem 中添加对应类型支持"),
    );
  }

  // 构建 Selection Item
// 构建 Selection Item
  Widget _buildTypedSelectionItem<T>(SelectionItem<T> item) {
    return FutureBuilder<List<T>>(
      future: item.optionsLoader(),
      builder: (context, optionsSnapshot) {
        if (optionsSnapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(item.title),
            trailing: const CircularProgressIndicator(),
          );
        } else if (optionsSnapshot.hasError) {
          return ListTile(
            title: Text(item.title),
            subtitle: Text("Error: ${optionsSnapshot.error}"),
          );
        } else if (optionsSnapshot.hasData) {
          final options = optionsSnapshot.data!;
          return FutureBuilder<T?>(
            future: item.selectedOptionLoader != null
                ? item.selectedOptionLoader!(options)
                : Future.value(options.isNotEmpty ? options.first : null),
            builder: (context, selectedSnapshot) {
              // 显示加载中状态
              if (selectedSnapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: Text(item.title),
                  trailing: const CircularProgressIndicator(strokeWidth: 2),
                );
              }

              // 获取当前选中项
              final selectedOption = selectedSnapshot.data;
              return ListTile(
                title: Text(item.title),
                subtitle: selectedOption != null
                    ? Text(item.displayFormatter(selectedOption))
                    : const Text("未选择"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final selected = await showDialog<T>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text(item.title),
                      children: [
                        ...options.map<Widget>(
                          (T option) {
                            final isSelected = selectedOption != null &&
                                item.displayFormatter(selectedOption) ==
                                    item.displayFormatter(option);

                            return ListTile(
                              title: Text(item.displayFormatter(option)),
                              // 在当前选中项旁边显示勾选图标
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () {
                                Navigator.pop(context, option);
                              },
                            );
                          },
                        ),
                        // 添加顶部的清除选项
                        if (selectedOption != null)
                          ListTile(
                            leading: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            title: const Text(
                              "清除选择",
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showClearConfirmDialog<T>(context, item);
                            },
                          ),
                      ],
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      item.onSelected(selected);
                    });
                  }
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

// 显示清除确认对话框
  Future<void> _showClearConfirmDialog<T>(
    BuildContext context,
    SelectionItem<T> item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确认清除"),
        content: Text("确定要清除${item.title}的设置吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("确定", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        if (item is SelectionItem<ShortVideoResource>) {
          SPManager.instance.remove(DemoConstants.keyDramaInfoListUrl);
        }
      });
    }
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

  // 获取短视频资源列表
  static Future<List<ShortVideoResource>> _fetchVideoResources() async {
    try {
      // 发起 HTTP 请求获取视频数据
      final response = await HTTPUtil.instance.get(
        DemoConstants.defaultDramaInfoListTotalUrl,
      );

      // 如果请求失败，返回空列表
      if (response == null || response is! List) {
        debugPrint("[error]: Failed to load video resources");
        return [];
      }

      return response.map((item) => ShortVideoResource.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Error loading drama info list: $e");
      return [];
    }
  }

  // 获取当前选中的短视频资源
  static ShortVideoResource? _fetchSelectedVideoResource(
    List<ShortVideoResource> options,
  ) {
    if (options.isEmpty) {
      return null;
    }

    // 从 SharedPreferences 中获取保存的短视频链接
    final savedLink = SPManager.instance.getString(
      DemoConstants.keyDramaInfoListUrl,
    );
    if (savedLink == null) {
      return null;
    }

    // 找到匹配的短视频资源
    final matches = options.where((option) => option.url == savedLink);
    return matches.isNotEmpty ? matches.first : null;
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

class SelectionItem<T> extends SettingItem {
  final String title;
  final Future<List<T>> Function() optionsLoader;
  final Future<T?> Function(List<T>)? selectedOptionLoader;
  final ValueChanged<T> onSelected;
  final String Function(T) displayFormatter;

  SelectionItem({
    required this.title,
    required this.optionsLoader,
    this.selectedOptionLoader,
    required this.onSelected,
    required this.displayFormatter,
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

/// 定义短视频资源的数据模型
class ShortVideoResource {
  final String title;
  final String url;

  ShortVideoResource({required this.title, required this.url});

  factory ShortVideoResource.fromJson(Map<String, dynamic> json) {
    return ShortVideoResource(
      title: json['title'],
      url: json['url'],
    );
  }
}

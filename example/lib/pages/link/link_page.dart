// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: 链接设置页面

import 'package:aliplayer_widget_example/pages/link/link_constants.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:aliplayer_widget_example/pages/qrcode/qrcode_page.dart';
import 'package:flutter/material.dart';

/// 链接设置页面
class LinkPage extends StatefulWidget {
  /// 可选的 LinkItem 列表参数
  final List<LinkItem>? linkItems;

  const LinkPage({
    super.key,
    this.linkItems,
  });

  @override
  State<LinkPage> createState() => _LinkPageState();
}

class _LinkPageState extends State<LinkPage> {
  // 数据源
  late final List<LinkItem> items;

  // 为每个item创建一个TextEditingController
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();

    // 初始化数据源
    if (widget.linkItems != null && widget.linkItems!.isNotEmpty) {
      // 如果传入了 linkItems，则使用传入的列表
      items = List.from(widget.linkItems!);
    } else {
      // 否则使用默认的 LinkConstants.linkItems
      items = LinkConstants.linkItems;
    }

    // 初始化TextEditingController列表
    _controllers = List.generate(
      items.length,
      (index) => TextEditingController(),
    );

    // 加载保存的链接数据
    _loadSavedLinks();
  }

  @override
  void dispose() {
    // 释放所有TextEditingController
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // 更新链接的方法
  void updateLink(int index, String newLink) {
    setState(() {
      items[index].link = newLink;
    });
  }

  // 加载保存的链接数据
  Future<void> _loadSavedLinks() async {
    for (int i = 0; i < items.length; i++) {
      var name = items[i].name;
      final savedLink = await SPManager.instance.getString(name);
      if (savedLink != null) {
        setState(() {
          items[i].link = savedLink; // 更新数据模型
          _controllers[i].text = savedLink; // 更新 TextField 的内容
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('链接设置页面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: onSavePressed,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 点击页面任何地方收起键盘
        child: _buildContentBody(),
      ),
      floatingActionButton: (widget.linkItems?.isNotEmpty == true)
          ? FloatingActionButton(
              onPressed: _onFloatButtonPressed,
              child: const Icon(Icons.arrow_forward_rounded),
            )
          : null,
    );
  }

  /// 构建主体内容
  Widget _buildContentBody() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 固定长度的文字
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // 输入框和扫码按钮
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllers[index],
                      onChanged: (value) => updateLink(index, value),
                      decoration: InputDecoration(
                        hintText: '请输入链接',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controllers[index].clear(); // 清空输入框
                            updateLink(index, '');
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => onQrCodePressed(index), // 传递当前 item 的索引
                    icon: const Icon(Icons.qr_code_rounded),
                    label: const Text('扫码'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 保存按钮点击事件
  void onSavePressed() {
    // 保存所有链接
    for (var item in items) {
      SPManager.instance.saveString(item.name, item.link);
    }

    // 显示保存成功的提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('链接已保存'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // 返回上一级页面
    _navigateBack();
  }

  /// 二维码按钮点击事件
  Future<void> onQrCodePressed(int index) async {
    // 跳转到二维码页面，并等待扫码结果
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRCodePage()),
    );

    // 如果扫码结果不为空，则更新对应的 TextField 和数据模型
    if (result != null && result is String) {
      setState(() {
        items[index].link = result; // 更新数据模型
        _controllers[index].text = result; // 更新 TextField 的内容
      });
    }
  }

  /// 浮动按钮点击事件
  void _onFloatButtonPressed() {
    bool hasLinkFilled = false;
    for (var item in items) {
      if (item.link.isNotEmpty) {
        hasLinkFilled = true;
        // 保存链接
        SPManager.instance.saveString(item.name, item.link);
        continue;
      }
    }

    // 如果有链接填写，则跳转到目标页面
    if (hasLinkFilled) {
      // 跳转到目标页面
      Navigator.pushReplacementNamed(context, items.firstOrNull?.route ?? "");
    } else {
      // 提示用户输入链接
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先输入链接'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 返回上一级页面
  void _navigateBack() {
    // 使用 pop 返回上一级页面
    Navigator.pop(context);
  }
}

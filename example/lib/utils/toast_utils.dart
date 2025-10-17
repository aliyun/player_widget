// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2025/10/11
// Brief: 设置链接公用工具类
import 'package:aliplayer_widget_example/pages/link/link_constants.dart';
import 'package:aliplayer_widget_example/pages/link/link_page.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  // 提示消息并提供跳转
  static void showSetUpLinkSnackBar(
    BuildContext context,
    LinkItem linkItemOne, {
    LinkItem? linkItemTwo,
    required String message,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: '去设置',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LinkPage(
                  linkItems: [
                    linkItemOne,
                    if (linkItemTwo != null) linkItemTwo
                  ],
                ),
              ),
            );
          },
        ),
      ));
    });
  }

  // 显示提示消息
  static showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}

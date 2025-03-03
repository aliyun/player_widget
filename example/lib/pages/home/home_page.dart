// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/17
// Brief: 首页，展示导航按钮列表

import 'package:aliplayer_widget_example/constants/page_routes.dart';
import 'package:flutter/material.dart';

import 'home_page_item.dart';

/// 首页
///
/// This widget represents the home page of the application. It displays a list
/// of buttons that navigate to different pages.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text("AliPlayer Widget Example"),
      ),
      body: _buildBody(),
    );
  }

  /// 构建页面主体内容
  ///
  /// Build the main content of the page
  Widget _buildBody() {
    final configurations = PageRoutes.homeItemConfigurations;

    // Show placeholder if configurations are empty
    if (configurations.isEmpty) {
      return const Center(
        child: Text(
          "No items available",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: configurations.length,
      itemBuilder: (context, index) {
        final config = configurations[index];
        return Column(
          children: [
            HomePageItem(itemConfig: config),
          ],
        );
      },
    );
  }
}

// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/17
// Brief: 直播间页面（横屏）

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/pages/link/link_constants.dart';
import 'package:aliplayer_widget_example/constants/page_routes.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:aliplayer_widget_example/pages/link/link_page.dart';
import 'package:aliplayer_widget_example/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 直播间页面（支持横竖屏切换）
///
/// Live Streaming Page with Orientation Support
/// This widget represents a simple live streaming page with:
/// - A top area for the title.
/// - A video area for live streaming.
/// - A scrollable chat area.
/// - A message input box at the bottom.
class LivePage extends StatefulWidget {
  /// 是否为竖屏直播间
  final bool isPortrait;

  const LivePage({super.key, this.isPortrait = false});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with WidgetsBindingObserver {
  /// 播放器组件控制器
  late AliPlayerWidgetController _controller;

  /// 键盘高度
  double _keyboardHeight = 0;

  /// 聊天消息列表
  final List<String> _chatMessages = [];

  /// 输入框控制器
  final TextEditingController _messageController = TextEditingController();

  /// 聊天区域的滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), // 点击页面任何地方收起键盘
            child: _buildContentBody(orientation),
          ),
        );
      },
    );
  }

  /// 构建主体内容
  Widget _buildContentBody(Orientation orientation) {
    if (widget.isPortrait || orientation == Orientation.portrait) {
      // 竖屏布局：使用 Stack 实现浮层
      return _buildPortraitLayout();
    } else {
      // 横屏布局：保持原有布局
      return _buildPlayWidget();
    }
  }

  /// 构建竖屏布局
  Widget _buildPortraitLayout() {
    return Stack(
      children: [
        // 底层：播放器组件
        _buildPlayWidget(),

        // 顶部区域
        Align(
          alignment: Alignment.topCenter,
          child: _buildTopArea(),
        ),

        // 聊天区域
        Positioned(
          top: MediaQuery.of(context).size.height / 2,
          // 顶部区域高度
          bottom: _keyboardHeight > 0 ? _keyboardHeight : 60,
          // 键盘弹起时调整底部偏移
          left: 0,
          right: 0,
          child: _buildChatArea(),
        ),

        // 消息输入框
        Positioned(
          bottom: _keyboardHeight,
          left: 0,
          right: 0,
          child: _buildMessageInput(),
        ),
      ],
    );
  }

  /// 构建顶部区域
  Widget _buildTopArea() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context), // 退出直播间
          ),

          // 直播间标题和观众人数
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "云小宝的直播间",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Colors.grey,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "3.75万",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 更多选项按钮
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
    );
  }

  /// 显示更多选项菜单
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("分享直播间"),
                onTap: () => Navigator.pop(context), // 关闭菜单
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text("举报"),
                onTap: () => Navigator.pop(context), // 关闭菜单
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建播放器组件
  Widget _buildPlayWidget() {
    return AliPlayerWidget(_controller);
  }

  /// 构建滚动的聊天区域
  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: ColorUtil.getMaterialColor(index: index),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _chatMessages[index],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建弹幕发送框
  Widget _buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            /// 礼物入口按钮
            IconButton(
              icon: const Icon(Icons.card_giftcard, color: Colors.pink),
              onPressed: _showGiftOptions,
            ),

            /// 输入框
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "输入弹幕...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            /// 发送按钮
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  /// 显示礼物选项菜单
  void _showGiftOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.star, color: Colors.yellow),
                title: const Text("送星星"),
                onTap: () {
                  Navigator.pop(context); // 关闭菜单
                  _sendGift("星星");
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text("送爱心"),
                onTap: () {
                  Navigator.pop(context); // 关闭菜单
                  _sendGift("爱心");
                },
              ),
              ListTile(
                leading: const Icon(Icons.diamond, color: Colors.purple),
                title: const Text("送钻石"),
                onTap: () {
                  Navigator.pop(context); // 关闭菜单
                  _sendGift("钻石");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 发送礼物
  void _sendGift(String giftName) {
    setState(() {
      // 在聊天区域显示礼物消息
      _chatMessages.add("[礼物] 送出了一颗 $giftName");
    });

    // 滚动到底部
    _scrollToBottom();

    // 收起键盘
    FocusScope.of(context).unfocus();
  }

  /// 添加新消息到聊天列表
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _chatMessages.add(message);
        _messageController.clear();
      });

      // 滚动到底部
      _scrollToBottom();
    }
  }

  /// 滚动到底部 / Scroll to bottom
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  /// 初始化状态
  /// StatefulWidget 的状态类中第一个被调用的方法，用于初始化状态，可以执行一些一次性的初始化工作
  ///
  /// Called when the state is first created. Used for one-time initialization.
  @override
  void initState() {
    super.initState();

    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);

    // 获取保存的链接
    final linkItemName = widget.isPortrait
        ? LinkConstants.livePortrait
        : LinkConstants.liveLandscape;
    final savedLink = SPManager.instance.getString(linkItemName);

    // 如果 URL 为空，提示用户并跳转到 LinkPage
    if (savedLink == null || savedLink.isEmpty) {
      final pageRoute = widget.isPortrait
          ? PageRoutes.livePortrait
          : PageRoutes.liveLandscape;
      final linkItem = LinkItem(name: linkItemName, route: pageRoute);

      // 显示提示消息
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('请先设置直播链接'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '去设置',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LinkPage(
                      linkItems: [
                        linkItem,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      });
      return;
    }

    // 动态设置屏幕方向
    if (widget.isPortrait) {
      // 锁定竖屏方向
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    // 添加观察者
    WidgetsBinding.instance.addObserver(this);

    // 设置播放器视频源
    final videoSource = VideoSourceFactory.createUrlSource(savedLink);
    // 设置播放器组件数据
    final data = AliPlayerWidgetData(
      sceneType: SceneType.live,
      videoSource: videoSource,
    );
    _controller.configure(data);
  }

  /// 清理资源
  /// 在 StatefulWidget 被从树中移除并销毁时调用的，这个方法用于清理资源。
  ///
  /// Called when the widget is removed from the tree permanently. Used to release resources.
  @override
  void dispose() {
    // 释放输入框资源
    _messageController.dispose();
    // 释放滚动控制器
    _scrollController.dispose();

    // 销毁播放控制器
    _controller.destroy();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// 监听键盘高度变化
  @override
  void didChangeMetrics() {
    // 获取键盘高度
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    setState(() {
      _keyboardHeight = bottomInset;
    });
  }
}

// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: 二维码页面

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// 二维码页面
///
/// QR Code Scanner Page
class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  /// 扫码控制器
  final MobileScannerController _scannerController = MobileScannerController();

  /// 是否正在处理扫码结果
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 扫码组件
          MobileScanner(
            controller: _scannerController,
            fit: BoxFit.cover,
            onDetect: _handleBarcodeDetection,
          ),
          // 扫描框
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Please put the QR code in the box",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理扫码结果
  ///
  /// Handles barcode detection events.
  void _handleBarcodeDetection(BarcodeCapture barcode) {
    if (_isProcessing) return; // 防止重复处理

    final String? result = barcode.barcodes.firstOrNull?.rawValue;
    if (result != null && result.isNotEmpty) {
      _isProcessing = true;

      // 停止扫描
      _scannerController.stop();

      // 返回扫码结果
      Navigator.pop(context, result);
    }
  }

  @override
  void dispose() {
    // 释放资源
    _scannerController.dispose();
    super.dispose();
  }
}

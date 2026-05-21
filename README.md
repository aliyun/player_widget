Language: 中文简体 | [English](README-EN.md)

![alibaba_cloud_logo](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/AlibabaCloud.svg)

# **aliplayer_widget**

[![pub package](https://img.shields.io/pub/v/aliplayer_widget.svg)](https://pub.dev/packages/aliplayer_widget) [![platform](https://img.shields.io/badge/-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/) [![language](https://img.shields.io/badge/-Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev/) [![website](https://img.shields.io/badge/Product-VOD-FF6A00)](https://www.aliyun.com/product/vod)

## **一、概述**

**AliPlayerWidget** 是一款专为 Flutter 应用程序打造的高性能视频播放组件，基于阿里云播放器 SDK `flutter_aliplayer` 构建。它不仅支持点播（VOD）、直播、列表播放以及短剧场景等多场景适配，还提供了丰富的功能集和高度灵活的 UI 定制能力，能够满足教育、娱乐、电商以及短剧应用等多种领域的视频播放需求。

通过极简的 API 设计，AliPlayerWidget 实现了低代码集成，开发者只需几行代码即可快速实现复杂的视频播放功能，显著降低开发成本。无论是基础的播放控制，还是复杂的交互场景（如手势调节、自定义 UI 叠加），AliPlayerWidget 都能轻松应对，帮助开发者构建流畅且高效的用户体验。

---

## **二、功能特性**

### **1. 核心功能**

- **多场景适配**：支持点播、直播、列表播放及全屏播放等多种场景。
- **丰富的功能集：**
  - **基础功能**：提供播放控制、设置面板、封面图显示、清晰度切换等核心功能，满足常规视频播放需求。
  - **手势控制**：支持亮度、音量和播放进度的手势调节，操作直观便捷，提升用户体验。
  - **多种播放源支持**：兼容多种视频源类型，包括直接 URL 播放、VID+STS 令牌播放，以及 VID+Auth 认证播放，满足不同场景下的播放需求。
  
- **灵活的 UI 定制：**
  - **插槽系统**：提供强大的插槽系统，支持自定义播放器界面的各个部分，包括顶部栏、底部栏、播放控制、封面图、字幕等。支持完全自定义插槽、细粒度控制默认插槽内的 UI 元素显示与手势交互，以及在播放器任意层级插入自定义 UI 组件（如广告、弹幕、水印等）。
  - **模块化设计**：内置顶部栏、底部栏、设置面板等可复用的 UI 组件，方便开发者按需定制。
  - **全屏适配**：自动适配横竖屏切换，确保在不同设备上的最佳显示效果。
- **可扩展的播放管理：**
  - **策略系统**：内置首帧统计、卡顿检测等推荐策略，同时支持自定义策略扩展，为单点业务逻辑提供独立的承载单元。
  - **实时状态监控**：提供播放状态、视频尺寸、缓冲进度等实时数据更新，便于开发者实现动态交互。
  - **事件回调机制**：提供全面的播放器事件监听，包括播放开始、暂停、完成等状态管理，方便开发者处理各种播放场景。
  - **日志与调试支持**：内置详细的日志系统，便于问题排查和性能优化。

### **2. 核心优势**

- **简单易用**：通过简单的 API 调用即可实现复杂的视频播放功能，快速集成到 Flutter 项目中。
- **灵活可扩展：**
  - 模块化设计，支持多种自定义选项，方便开发者根据需求进行定制。
  - 自动适配不同屏幕尺寸和分辨率，确保一致的用户体验。

- **高性能与稳定性：**
  - 基于阿里云播放器 SDK，提供低延迟、高稳定性的视频播放体验。
  - 优化的架构设计，通过轻量化组件、异步加载和事件驱动模型，确保高效运行与流畅用户体验。

- **跨平台支持**：充分利用 Flutter 的跨平台特性，支持 Android 和 iOS 平台，一次开发即可实现双端运行。

---

## **三、快速开始**

### **1. 在线阅读**

**[🌐 点击这里开始在线阅读](https://aliyun.github.io/player_widget/)**

### **2. 本地阅读**

如果您希望在本地阅读文档，请参考 [**文档目录**](./docs/README.md)。

该目录提供了清晰的文档结构与步骤说明，便于 **AI 与开发者共同理解和执行**。未来我们还将提供专门的 **Skills 支持**，以实现更加完整和便捷的接入体验。

---

## **四、快速集成**

有关前提条件的详细信息，请参阅 [集成指引](./docs/integration-guide.md)。

---

## **五、快速接入**

只需几步，您就可以轻松实现视频播放功能！**AliPlayerWidget** 提供了极简的 API 设计，帮助您以低代码的方式快速集成视频播放功能。

![Integration](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/Integration.png)

更多用法与代码示例，请查看 [快速开始指南](./docs/quick-start.md)。

---

## **六、自定义功能**

### **1. 插槽系统**

插槽 (Slot) 是播放器 UI 的基本组成单元。组件内置了经过统一设计的默认 UI，无需任何配置即可开箱即用。同时提供灵活的自定义能力，支持完全替换插槽、细粒度隐藏默认插槽中的特定 UI 元素，以及在播放器任意层级插入自定义 UI 组件（如广告、弹幕、水印等）。有关详细信息，请查看 [插槽系统文档](./docs/advanced/slot-system.md)

### **2. 策略系统**

策略 (Strategy) 是播放器行为逻辑的基本组织单元。内置首帧统计、卡顿检测等推荐策略，开箱即用。同时支持自定义策略开发，轻松实现播放质量监控、业务埋点等功能，无需修改播放器核心代码。有关详细信息，请查看 [策略系统文档](./docs/advanced/strategy-system.md)

### **3. 视频源支持**

AliPlayerWidget 提供了灵活的视频源配置方式，支持多种视频源类型。有关详细信息，请查看 [视频源支持文档](./docs/advanced/video-source-support.md)

### **4. UI 主题**

AliPlayerWidget 提供了统一的 UI 设计规范，支持快速替换播放器皮肤。只需传入图标资源路径即可实现品牌定制。有关详细信息，请查看 [UI 主题文档](./docs/advanced/ui-theme.md)

### **5. API 参考**

`AliPlayerWidget` 提供了一系列对外接口，方便开发者直接控制播放器的行为。有关详细信息，请查看 [API 参考文档](./docs/api-reference.md)

---

## **七、示例工程与演示包**

为了让开发者更快速地上手并深入理解如何在实际项目中集成和使用 **AliPlayerWidget**，我们提供了两种资源：**示例工程** 和基于该工程构建的 **演示包**。以下分别介绍两者的用途和获取方式。

### **1. 示例工程**
`aliplayer_widget_example` 是一个完整的示例工程，旨在帮助开发者快速理解和集成 **AliPlayerWidget** 的核心功能。

您可以访问以下链接查看示例工程的完整文档：

- **中文文档**: [aliplayer_widget_example README](./example/README.md)
- **English Documentation**: [aliplayer_widget_example README-EN](./example/README-EN.md)

通过示例工程，您可以直观地了解以下内容：

- 如何嵌入视频播放器组件。
- 如何配置不同场景下的播放功能（如点播、直播、列表播放）。
- 如何利用自定义选项实现个性化的用户体验。

### **2. 演示包**
为了帮助开发者快速体验 **AliPlayerWidget** 的功能，我们基于 `aliplayer_widget_example` 示例工程构建了一个演示包。该演示包可以直接安装到设备上运行，无需额外配置开发环境。

#### **获取方式**
使用手机扫描以下二维码，即可快速下载并安装演示包：

![Demo QR Code](https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/aliplayer_widget/demo-qr-code.png)  
> **注意**：二维码链接指向最新版本的演示包，请确保您的设备已开启允许安装第三方应用的权限。

---

## **八、开源与源码获取**

**aliplayer_widget** 已发布至以下 Pub 源，推荐开发者通过包管理工具集成：

- **Pub 官方源**: [pub.dev](https://pub.dev/packages/aliplayer_widget)
- **国内镜像源**: [pub.flutter-io.cn](https://pub.flutter-io.cn/packages/aliplayer_widget)

如果需要对组件进行自定义修改，您可以使用源码依赖的方式，直接获取并修改源码。完整源码可通过以下方式获取：

- **GitHub 仓库**: [aliplayer_widget](https://github.com/aliyun/player_widget)
  

如果无法访问 GitHub，可通过以下链接直接下载源码包：

- **源码包下载地址**: [aliplayer_widget.zip](https://alivc-demo-cms.alicdn.com/versionProduct/sourceCode/aliplayer_widget/aliplayer_widget.zip)

开源内容包括：

- **核心组件**：`AliPlayerWidget` 和 `AliPlayerWidgetController` 的完整实现。
- **示例工程**：`aliplayer_widget_example` 提供点播、直播、列表播放等场景的代码示例，帮助开发者快速集成和使用。
- **文档与注释**：源码包含详细注释和开发指南，便于二次开发与定制。

---

## **九、相关产品**

AliPlayerWidget 基于阿里云音视频能力构建，建议结合以下云产品使用，通过端云结合获得更好的播放能力和视频体验：

- [阿里云视频点播（VOD）](https://www.aliyun.com/product/vod)
- [阿里云视频直播（Live）](https://www.aliyun.com/product/live)
- [音视频终端 SDK](https://help.aliyun.com/zh/apsara-video-sdk/)

---

## **十、联系我们**

- 📘 **官方文档**：[播放器帮助中心](https://help.aliyun.com/zh/vod/)
- 🔍 **控制台**：[视频点播控制台](https://vod.console.aliyun.com)
- 📝 **提交工单**：[阿里云官方技术支持](https://smartservice.console.aliyun.com/service/create-ticket)
- 💬 **GitHub Issues**：[欢迎提交反馈与建议](https://github.com/aliyun/player_widget/issues)

更多关于使用阿里云播放器 SDK 的常见问题及修复建议，请参见[播放器常见问题](https://help.aliyun.com/zh/vod/support/faq-about-apsaravideo-player/)。
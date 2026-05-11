# **UI 主题**

AliPlayerWidget 提供了统一的 UI 设计规范，包含图标资源管理和样式 Token。通过 UI 主题系统，您可以快速替换播放器皮肤，实现品牌定制。

---

## **1. 默认 UI 设计**

AliPlayerWidget 内置了一套完整的 UI 设计，无需任何配置即可使用：

```dart
AliPlayerWidget(controller)
```

默认设计包含：

- **图标资源**：统一的图标文件名常量（`PlayerIcons`）
- **样式规范**：统一的颜色、字号、尺寸、间距 Token（`PlayerStyles`）

---

## **2. 自定义皮肤**

如需替换整套图标资源，只需传入 `assetsPath` 参数：

### **步骤 1：创建资源目录**

在您的应用目录下创建资源文件夹：

```
your_app/
└── assets/
    └── player_icons/      # 自定义目录名
        ├── ic_back.svg
        ├── ic_settings.svg
        └── ...
```

### **步骤 2：注册资源**

在应用的 `pubspec.yaml` 中注册：

```yaml
flutter:
  assets:
    - assets/player_icons/
```

### **步骤 3：传入路径**

使用时传入自定义路径：

```dart
AliPlayerWidget(
  controller,
  assetsPath: 'assets/player_icons',
)
```

---

## **3. 图标资源规范**

### **3.1 格式选择**

| 格式 | 适用场景 | 说明 |
|:----|:--------|:-----|
| **SVG**（首选） | 纯色/单色矢量图标 | 无需多分辨率切图，一份文件覆盖任意分辨率 |
| **PNG** | 带渐变/多色图标 | 需提供 1x / 2x / 3x 三套分辨率 |

### **3.2 命名规则**

```
ic_<功能描述>[_<状态>].svg
```

- **前缀**：`ic_` 表示图标资源
- **命名**：小写下划线，避免跨平台问题
- **状态后缀**：`_on`/`_off`、`_done`、`_exit`（不使用数字区分）

**示例：**

| 文件名 | 含义 |
|:------|:-----|
| `ic_back.svg` | 返回按钮 |
| `ic_settings.svg` | 设置按钮 |
| `ic_play.svg` | 播放按钮 |
| `ic_pause.svg` | 暂停按钮 |
| `ic_download.svg` | 下载按钮（未下载） |
| `ic_download_done.svg` | 下载完成 |

### **3.3 PNG 多分辨率规范**

若使用 PNG 格式，需按以下目录结构提供三套切图：

```
assets/player_icons/
├── ic_back.png          # 1x（基准）
├── 2.0x/
│   └── ic_back.png      # 2x
└── 3.0x/
    └── ic_back.png      # 3x
```

> **注意**：1x 文件放在根目录，而非 `1.0x/` 子目录。Flutter 会自动识别 `2.0x/`、`3.0x/` 作为分辨率变体。

---

## **4. 高级 UI 控制**

如果需要更精细的 UI 控制（如隐藏某个按钮、替换整个控制栏），请使用**插槽系统**。

插槽系统允许您：

- 自定义任意 UI 模块（顶部栏、底部栏、设置面板等）
- 隐藏插槽内的单个元素
- 完全替换插槽组件

详见 [插槽系统](slot-system.md)。

---

## **5. API 参考**

### **参数**

| 参数 | 类型 | 默认值 | 说明 |
|:----|:----|:------|:-----|
| `assetsPath` | `String` | 包内资源路径 | 图标资源目录路径 |

### **使用示例**

```dart
import 'package:aliplayer_widget/theme/player_theme.dart';

// 图标
SvgPicture.asset(
  PlayerAssetsScope.iconPath(context, PlayerIcons.back),
  width: PlayerStyles.iconSizeTopBar,
)

// 文字
Text(
  'Title',
  style: TextStyle(
    fontSize: PlayerStyles.fontSizeTitle,
    color: PlayerStyles.colorOnPrimary,
  ),
)
```

---

## **6. 注意事项**

- SVG 文件应只包含 `viewBox`，不写死宽高，由代码控制渲染尺寸
- 自定义皮肤时，图标文件名必须与默认图标名一致
- 目录批量注册后，新增图标无需修改 `pubspec.yaml`

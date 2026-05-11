# **UI Theme**

AliPlayerWidget provides a unified UI design specification, including icon resource management and style tokens. Through the UI theme system, you can quickly replace the player skin to achieve brand customization.

---

## **1. Default UI Design**

AliPlayerWidget comes with a complete UI design that works without any configuration:

```dart
AliPlayerWidget(controller)
```

The default design includes:

- **Icon Resources**: Unified icon file name constants (`PlayerIcons`)
- **Style Specification**: Unified color, font size, size, and spacing tokens (`PlayerStyles`)

---

## **2. Custom Skin**

To replace the entire icon resource set, simply pass the `assetsPath` parameter:

### **Step 1: Create Resource Directory**

Create a resource folder in your app directory:

```
your_app/
└── assets/
    └── player_icons/      # Custom directory name
        ├── ic_back.svg
        ├── ic_settings.svg
        └── ...
```

### **Step 2: Register Resources**

Register in your app's `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/player_icons/
```

### **Step 3: Pass the Path**

Pass the custom path when using:

```dart
AliPlayerWidget(
  controller,
  assetsPath: 'assets/player_icons',
)
```

---

## **3. Icon Resource Specifications**

### **3.1 Format Selection**

| Format | Use Case | Notes |
|:-------|:---------|:------|
| **SVG** (Recommended) | Solid/single-color vector icons | No multi-resolution files needed, one file covers any resolution |
| **PNG** | Gradient/multi-color icons | Requires 1x / 2x / 3x resolution files |

### **3.2 Naming Convention**

```
ic_<description>[_<state>].svg
```

- **Prefix**: `ic_` indicates icon resource
- **Naming**: Lowercase with underscores, avoid cross-platform issues
- **State Suffix**: `_on`/`_off`, `_done`, `_exit` (no numbers for states)

**Examples:**

| Filename | Meaning |
|:--------|:--------|
| `ic_back.svg` | Back button |
| `ic_settings.svg` | Settings button |
| `ic_play.svg` | Play button |
| `ic_pause.svg` | Pause button |
| `ic_download.svg` | Download button (not downloaded) |
| `ic_download_done.svg` | Download completed |

### **3.3 PNG Multi-Resolution Specification**

If using PNG format, provide three resolution files in the following directory structure:

```
assets/player_icons/
├── ic_back.png          # 1x (base)
├── 2.0x/
│   └── ic_back.png      # 2x
└── 3.0x/
    └── ic_back.png      # 3x
```

> **Note**: Place 1x files in the root directory, not in a `1.0x/` subdirectory. Flutter automatically recognizes `2.0x/` and `3.0x/` as resolution variants.

---

## **4. Advanced UI Control**

For more granular UI control (such as hiding a specific button or replacing an entire control bar), use the **Slot System**.

The slot system allows you to:

- Customize any UI module (top bar, bottom bar, settings panel, etc.)
- Hide individual elements within a slot
- Completely replace slot components

See [Slot System](slot-system-en.md) for details.

---

## **5. API Reference**

### **Parameters**

| Parameter | Type | Default | Description |
|:----------|:-----|:--------|:------------|
| `assetsPath` | `String` | Package resource path | Icon resource directory path |

### **Usage Example**

```dart
import 'package:aliplayer_widget/theme/player_theme.dart';

// Icon
SvgPicture.asset(
  PlayerAssetsScope.iconPath(context, PlayerIcons.back),
  width: PlayerStyles.iconSizeTopBar,
)

// Text
Text(
  'Title',
  style: TextStyle(
    fontSize: PlayerStyles.fontSizeTitle,
    color: PlayerStyles.colorOnPrimary,
  ),
)
```

---

## **6. Notes**

- SVG files should only contain `viewBox`, without fixed width/height, letting code control rendering size
- When customizing skin, icon filenames must match the default icon names
- After directory batch registration, adding new icons doesn't require modifying `pubspec.yaml`
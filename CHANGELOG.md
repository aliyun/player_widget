# **AliPlayerWidget Changelog**

## **[7.0.1] - Documentation Improvements**

### **Documentation Updates**

- README Enhancements
  - Improved clarity and structure of the README documentation for better readability.
  - Included additional guidance on integrating `AliPlayerWidget` in multi-scenario applications (e.g., VOD, live streaming, short videos).

### **No Functional Changes**

This release focuses solely on improving documentation and does not include any functional changes or bug fixes. All features and APIs remain consistent with version `7.0.0`.

---

## **[7.0.0] - Initial Release**

### **Features**
- **Core Player Functionality**
  - Implemented basic video playback capabilities including play, pause, stop and seek operations.
  - Added support for multiple playback rates with `setRate()` method.
  - Integrated brightness and volume control with delta adjustments.

- **Controller Architecture**
  - Developed `AliPlayerWidgetController` as the main interface for player interactions.CHANGELOG.md
  - Implemented various notifiers including:
    - `mirrorModeNotifier`
    - `isMuteNotifier`
    - `scaleModeNotifier`
    - `isLoopNotifier`
    - `speedNotifier`
    - `trackInfoListNotifier`
    - `thumbnailNotifier`

- **Event Handling System**
  - Established comprehensive callback mechanisms for player events:
    - Video size change detection
    - Loading status notifications (begin, progress, end)
    - Seek completion events
    - Playback position tracking

### UI Components
- **Setting Menu Panel**
  - Created customizable settings menu with visibility control.
  - Implemented setting items builder for dynamic configuration options.

- **Overlay System**
  - Introduced flexible overlay system allowing custom widgets to be positioned over the player.
  - Supports multiple overlay elements with absolute positioning.

### **Technical Implementation**
- **Platform Integration**
  - Implemented platform brightness detection for automatic theme mode adjustment.
  - Developed robust initialization and destruction processes for player instances.

- **Data Management**
  - Created `AliPlayerWidgetData` class for managing video source information.
  - Supports various media sources including VOD and live streams.

### **Documentation**
- Provided complete README documentation including:
  - Quick start guide
  - Core component descriptions
  - Customization instructions
  - Code examples for common use cases

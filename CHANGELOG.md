# **AliPlayerWidget Changelog**

## **[7.0.3] - Bug Fixes and Feature Enhancements**
### **Bug Fixes**
- Resolved issues related to `pub.dev` compliance, ensuring smoother package publication and integration.
  - Addressed metadata and dependency-related warnings.
  - Improved package validation to meet `pub.dev` quality standards.

### **New Features**
- Introduced **business identifier** support, allowing developers to tag player instances with custom identifiers for better tracking and analytics.
  - This feature enhances the ability to monitor and manage player usage in complex multi-scenario applications.

- Added **video source switching functionality** to the example project, enabling seamless transitions between different video sources during playback.
  - This update provides a practical demonstration of dynamic source management and enhances the flexibility of the example project for developers.

---

## **[7.0.2] - UI Performance Optimization**

### **Performance Improvements**

* Enhanced PageView scrolling performance, significantly reducing lag during transitions.
* Optimized UI rendering for smoother interactions and improved responsiveness.

### **Bug Fixes**

* Fixed video loading delays during PageView scrolling on certain devices.
* Resolved UI layout issues during full-screen mode transitions.

**Note**: This release focuses on UI performance optimization. Upgrading is recommended for a smoother experience.

---

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

# **AliPlayerWidget Changelog**

---

## **[7.3.0] - Screen Keep-On & Streaming Protocol Fixes**

### **New Features**

- **Screen Keep-On Support**  
  Added screen keep-on functionality to prevent the device screen from dimming or locking during video playback.  
  This feature is especially useful for long-form content, live streaming, and educational video applications.

### **Improvements**

- The method for switching between portrait and landscape modes has been modified. Now, the navigation bar will not be included when switching orientations.
- The functionality to select a decoder has been integrated, allowing you to choose between software decoding or hardware decoding for playback based on your needs.

### **Bug Fixes**

- **Fixed URL-based Video Source Playback for RTMP/ARTC Streams**  
  Resolved an issue where URL-formatted video sources were unable to play RTMP/ARTC format streams correctly.  
  This update ensures better compatibility with various streaming protocols across different playback scenarios.

---

**Note**: This release enhances playback reliability and improves user experience for streaming use cases. Upgrading is recommended for apps requiring support for RTMP/ARTC and screen keep-on behavior.

## **[7.2.0] - Enhanced Video Source Support**

### **New Features**

- **Multiple Video Source Support**: Added compatibility for various video source types, enabling playback through:
  
  - Direct URL playback for publicly accessible videos.
  - VID+STS token-based playback for secure access and enhanced control.
  - VID+Auth authentication-based playback for simplified authorization scenarios.
  
  This enhancement ensures that developers can meet diverse playback requirements across different use cases, such as VOD (Video on Demand), live streaming, and secure media distribution.

### **Improvements**

- Streamlined video source configuration to make it easier for developers to switch between different playback modes dynamically.
- Updated the example project to demonstrate the integration of all supported video source types, providing a comprehensive reference for implementation.

### **Documentation Updates**

- Expanded the README documentation to include detailed guidance on configuring and utilizing each video source type.
- Added code examples for integrating URL, VID+STS, and VID+Auth playback modes, ensuring clarity for developers adopting these features.

---

**Note**: This release focuses on enhancing video source flexibility and improving developer experience. Upgrading is recommended for projects requiring multi-source playback support.

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

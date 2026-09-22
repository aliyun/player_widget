# **AI Education Scene (AI VOD)**

---

## **1. Scene Introduction**

The **AI Education Scene** is an AI-powered video solution built by Alibaba Cloud on AliPlayerWidget and ApsaraVideo VOD, designed for **online education, course training, and knowledge dissemination** scenarios.

It uses the player as a unified entry point, with VOD providing video content and service support, and integrates AI content understanding capabilities to automatically generate chapters, summaries, and knowledge points. Users can quickly grasp the content structure, locate key segments, and review them at any time, transforming long videos from "watching from start to finish" to "browsing on demand and learning efficiently."

Whether it's online courses, vocational training, corporate learning, paid knowledge services, or academic lectures, this solution can enhance learning efficiency and viewing experience, revitalize existing video content, and reduce the integration and development costs of player and AI features.

On the Flutter side, the AI Education Scene has the following differentiated advantages:

- **One Dart codebase for both platforms**: chapter markers, chapter navigation, and the right-slide chapter list panel are all implemented in the Dart layer of `aliplayer_widget`. You do not need to copy a `scene-ai-education` module or modify Gradle/Podfile as required by the native Android/iOS solutions.
- **No extra native module integration**: just add the `aliplayer_widget` and `flutter_aliplayer` dependencies and reuse the sample code under `example/lib/pages/ai_education/` to get started quickly.
- **Declarative UI and slot extension**: register custom slots such as the chapter button through `AliPlayerWidget.slotBuilders`, and independently invoke the built-in chapter list panel through `ChaptersPanelManager.showChaptersPanel`, which fits the Flutter development style.
- **Hot-reload friendly**: panel styles and data assembly logic are all in Dart, so you can adjust them directly via Flutter hot reload during development.

![AiEducation](https://alivc-demo-cms.alicdn.com/versionProduct/resources/ai_education/ai-education-ui-preview.png)

---

## **2. Core Capabilities**

The AI Education Scene provides the following capabilities centered on "**quick understanding, precise navigation, and efficient review**":

| Capability | Description | Layer |
| ---- | ---- | ---- |
| Smart Chapters | Automatically identifies video content structure and generates chapters; the progress bar draws chapter markers, and tapping a marker seeks to the position | Built-in widget |
| Chapter Navigation | Portrait: a chapter chip list above the bottom bar; landscape: a chapter info row (chapter title, next-chapter button), tapping the title opens a right-side chapter list panel | Built-in widget |
| Seek Chapter Hint | Displays the chapter information for the current position while dragging the progress bar | Built-in widget |
| Chapter Thumbnails | Displays representative thumbnails for chapter list items to help users quickly identify and locate target content | Built-in widget |
| Content Summary | Paragraph summary and mind-map title badges for the whole video, with detailed Markdown content | Example layer |
| Knowledge Point Extraction | Automatically extracts key knowledge points per chapter, displays them as structured Markdown, and supports seeking to the corresponding segment | Example layer |
| Orientation Adaptation | Chapter chips above the bottom bar in portrait and a chapter info row in landscape, both driven by the same chapter data | Built-in widget |

> **Note**: Built-in chapter capabilities (progress bar chapter markers, chapter navigation, chapter info row, right-side chapter list panel, etc.) take effect automatically once you pass chapter data via `AliPlayerWidgetData.chapters`. These capabilities are **not strictly bound to `SceneType.aiVod`**; the AI analysis panel (summary and knowledge points) is implemented in the example project and can be copied into your own project as needed. See [Customization & Extension](#8-customization--extension).

---

## **3. Prerequisites**

Before starting integration, please complete the following preparations:

| Item | Requirement |
| ---- | ---- |
| Alibaba Cloud Services | [ApsaraVideo VOD](https://www.alibabacloud.com/en/product/apsaravideo-for-vod) and [Intelligent Media Services (IMS)](https://www.alibabacloud.com/en/product/ims) have been activated |
| Media Resources | Test videos have been prepared and AI content analysis (chapter extraction, summary generation, knowledge point analysis) has been completed |
| App Server | Deployment has been completed and can properly provide play credentials and AI analysis data; refer to the open-source project [VodAppServer](https://github.com/MediaBox-Demos/VodAppServer) |
| Widget Version | AliPlayerWidget >= 7.18.0 |
| Version Requirements | Dart SDK >= 3.4.0 / Flutter SDK >= 3.22.0; `flutter_aliplayer >= 7.18.0`; underlying Android/iOS native player SDK >= 7.18.0 |

> **Note**: Chapter UI capabilities are implemented in the Dart layer of `aliplayer_widget`. They depend only on whether `AliPlayerWidgetData.chapters` contains valid data; `sceneType` does not need to be `SceneType.aiVod`.

After completing the above preparations, modify the following two configurations in `example/lib/pages/ai_education/ai_constants.dart` of the example project to run the demo:

```dart
abstract final class AiContentConstants {
  /// Base URL of the App Server for AI content analysis, without a trailing `/`
  static const String appServerBaseUrl = 'http://your-server-host:port';

  /// Default media ID (must belong to the same Alibaba Cloud account as your App Server)
  static const String defaultMediaId = 'your-media-id';
}
```

---

## **4. Quick Start**

### **4.1 Common Integration**

The AI Education Scene is built on the AliPlayerWidget. If you have not completed the common integration steps yet, start here:

- [Integration Guide](../integration-guide-en.md): widget integration (adding dependencies, initialization)
- [Quick Start](../quick-start-en.md): basic widget usage

### **4.2 Configure App Server and Test Video**

Open `example/lib/pages/ai_education/ai_constants.dart` and modify the following two configurations:

> **Note**: You can use the official App Server address to try the scene out, but deploying your own service and using your own address is recommended. See [VodAppServer](https://github.com/MediaBox-Demos/VodAppServer) for deployment instructions.

```dart
static const String appServerBaseUrl = 'http://your-server-host:port';

static const String defaultMediaId = 'your-media-id';
```

### **4.3 Verify the Integration**

The example project ships with a built-in AI Education page. Entry information:

| Item | Value |
| ---- | ---- |
| Page | `example/lib/pages/ai_education/ai_education_page.dart` |
| Route | `/ai_education` (the "AI Education" entry on the home page) |

After the page launches, it automatically loads the play credential and AI analysis content and starts playback. If chapter markers appear on the progress bar and a chapter chip list appears above the bottom bar in portrait mode, the integration is successful; tap the chapter button at the top-left of the example page to open the chapter and AI analysis panel.

---

## **5. Architecture Overview**

The AI Education Scene is composed of the client, App Server, ICE / AI workflow, and ApsaraVideo VOD services.

The overall pipeline is divided into two phases:

- **Production Phase**: The App Server triggers the AI analysis workflow; ICE fetches media assets and completes chapter extraction, summary generation, and knowledge point analysis, then writes the structured results back to VOD.
- **Consumption Phase**: The client obtains play credentials and AI analysis results through the App Server, and AliPlayerWidget handles video playback, chapter navigation, and AI content display.

### **5.1 Global Business Flow**

The global business flow describes the complete pipeline from production, storage, to client consumption of AI analysis results.

VOD is responsible for unified storage of media assets and AI analysis results; ICE / AI workflow handles content understanding and structured analysis; App Server encapsulates server-side capabilities and provides a unified interface to the client.

![ProductArchitecture](https://alivc-demo-cms.alicdn.com/versionProduct/resources/ai_education/ProductArchitecture-EN.png)

### **5.2 Client Layered Architecture**

The client adopts a layered design consisting of the scene example layer (`example/lib/pages/ai_education/`), the widget capability layer (`aliplayer_widget`), and the player SDK (`flutter_aliplayer`). Chapter UI capabilities live in the widget capability layer and take effect as long as the business layer passes valid data to `AliPlayerWidgetData.chapters`; they are **not strictly bound to `SceneType.aiVod`**.

The data and control flow on the Flutter side is shown below:

![LayeredArchitecture](https://alivc-demo-cms.alicdn.com/versionProduct/resources/ai_education/LayeredArchitecture-Flutter-EN.png)

---

## **6. Server API**

### **6.1 Get Play Credential**

| Item | Value |
| ---- | ---- |
| Method | GET |
| Path | `/appServer/GetVideoPlayAuth` |
| Parameter | `videoId` (required, video ID) |

**Request Example**:

```
GET http://your-server-host:port/appServer/GetVideoPlayAuth?videoId=201558617a9e71f1bfb9e6e7e5780102
```

**Response Example**:

```json
{
  "code": 0,
  "success": true,
  "data": {
    "videoId": "your-video-id",
    "playAuth": "eyJ..."
  }
}
```

**Response Field Description**:

| Field | Type | Description |
| ---- | ---- | ---- |
| `code` | `Integer` | Business status code, 0 indicates success |
| `success` | `Boolean` | Whether the request was successful |
| `data.videoId` | `String` | Video ID |
| `data.playAuth` | `String` | Base64-encoded play authorization credential |

### **6.2 Get AI Analysis Content**

| Item | Value |
| ---- | ---- |
| Method | GET |
| Path | `/GetMediaAiAnalysisByResultType` |
| Required Parameter | `MediaId` (video ID) |
| Optional Parameter | `ResultType` (`Chapter` / `Summary`, returns all if not specified) |

**Request Example**:

```
GET http://your-server-host:port/GetMediaAiAnalysisByResultType?MediaId=201558617a9e71f1bfb9e6e7e5780102
```

**Response Example**:

```json
{
  "AiAnalysisResult": [
    {
      "ResultType": "Chapter",
      "Title": "Video Chapters",
      "chapterContentItems": [
        {
          "ChapterId": 1,
          "StartTime": 0,
          "EndTime": 120000,
          "ChapterTitle": "Course Introduction",
          "Summary": "This chapter introduces the overall framework of the course...",
          "ThumbnailUrl": "https://example.com/thumb1.jpg",
          "KnowledgePoints": [
            { "PointId": 1, "Point": "Core Concept", "Description": "Description content..." }
          ]
        }
      ]
    },
    {
      "ResultType": "Summary",
      "Title": "Video Summary",
      "summaryContent": {
        "ParagraphSummary": "This video mainly covers...",
        "MindMapSummary": [
          { "Title": "Core Concept", "Topics": [] }
        ],
        "MarkdownContent": "# Course Summary\n\n..."
      }
    }
  ]
}
```

> **Note**: To integrate with your own server, simply return the same JSON structure. The client does not care about the server-side implementation.
>
> **Field Name Casing Note**: The example DTO parses the field names shown above (for example, `chapterContentItems`, `Description`, `Topics`). If your server actually returns iOS-style field names (for example, `ChapterContentItems`, `PointDescription`, `Topic`), update the `fromJson` mapping in `example/lib/pages/ai_education/data/ai_analysis_response.dart` accordingly, or have the server uniformly return the structure shown above.

**Chapter Field Description**:

| Field | Type | Description |
| ---- | ---- | ---- |
| `ChapterId` | `Integer` | Chapter ID |
| `StartTime` | `Long` | Chapter start time (milliseconds) |
| `EndTime` | `Long` | Chapter end time (milliseconds) |
| `ChapterTitle` | `String` | Chapter title |
| `Summary` | `String` | Chapter text summary |
| `ThumbnailUrl` | `String` | Chapter thumbnail URL |
| `KnowledgePoints[].PointId` | `Integer` | Knowledge point ID |
| `KnowledgePoints[].Point` | `String` | Knowledge point name |
| `KnowledgePoints[].Description` | `String` | Knowledge point description |

**Summary Field Description**:

| Field | Type | Description |
| ---- | ---- | ---- |
| `ParagraphSummary` | `String` | Paragraph summary text |
| `MindMapSummary` | `Array` | Mind map summary list (recursive structure, each item contains `Title` and `Topics`) |
| `MarkdownContent` | `String` | Markdown-formatted content |

**API Protocol**:

| Item | Description |
| ---- | ---- |
| HTTP Timeout | 5 seconds (connect + read) |
| Error Handling | Degrades to normal playback mode (no AI panel) when the API fails |
| Time Unit | `StartTime` / `EndTime` are in milliseconds |

---

## **7. Data Model & Mapping**

### **7.1 Data Mapping**

| Server JSON Field | Client DTO | Business Model | Description |
| ---- | ---- | ---- | ---- |
| `ChapterId` | `AiChapterContentItem.chapterId` | `ChapterInfo.id` | Converted to String |
| `StartTime` | `AiChapterContentItem.startTime` | `ChapterInfo.startMs` | Milliseconds |
| `EndTime` | `AiChapterContentItem.endTime` | `ChapterInfo.endMs` | Milliseconds |
| `ChapterTitle` | `AiChapterContentItem.chapterTitle` | `ChapterInfo.title` | |
| `ThumbnailUrl` | `AiChapterContentItem.thumbnailUrl` | `ChapterInfo.thumbnailUrl` | |
| `Summary` | `AiChapterContentItem.summary` | `KnowledgeInfo.contentMarkdown` | Generated via three-level fallback |
| `KnowledgePoints[]` | `AiChapterContentItem.knowledgePoints` | `KnowledgeInfo.contentMarkdown` | Concatenated as Markdown (higher priority than Summary) |
| `ParagraphSummary` | `AiSummaryContent.paragraphSummary` | `SummaryInfo.paragraphSummary` | Video-level summary |
| `MindMapSummary` | `AiSummaryContent.mindMapSummary` | `SummaryInfo.mindMapTitles` | Extracts top-level Title list |
| `MarkdownContent` | `AiSummaryContent.markdownContent` | `SummaryInfo.markdownContent` | Markdown-formatted content |

### **7.2 Presentation Model**

The final assembly produces `AiContentViewModel`, generated once by `AiContentAssembler.buildViewModel(AiAnalysisResponse)`, serving as the panel's sole data entry:

| Field / Method | Type | Description |
| ---- | ---- | ---- |
| `chapters` | `List<ChapterInfo>` | Chapter list (empty list means no chapter data); used directly as `AliPlayerWidgetData.chapters`. **Chapter UI capabilities are independent of `SceneType` and are not strictly bound to the AI VOD scene.** |
| `knowledgeItems` | `List<KnowledgeInfo>` | Knowledge point list (text analysis style) |
| `summaryInfo` | `SummaryInfo?` | Video summary (graphic analysis style, nullable) |
| `hasChapterData` | `bool` | Whether chapter data is present |
| `hasSummaryData` | `bool` | Whether summary data is present |
| `hasAnyContent` | `bool` | Whether any valid content exists |

The Tab structure of the AI analysis panel is not part of the aggregated model; it is derived internally by the panel based on the data:

| Data Scenario | Tab Structure | Tab 1 | Tab 2 |
| ---- | ---- | ---- | ---- |
| Chapters only (no summary) | Dual Tab | Chapters | AI Analysis (text) |
| Summary only (no chapters) | No Tab | AI Analysis (graphic) | — |
| Both present | Dual Tab | Chapters | AI Analysis (graphic) |

### **7.3 Client Data Architecture**

The client adopts a layered design with clear separation between data assembly and UI rendering. The server response lands as a pure DTO, the assembler converts it into a presentation model, and the UI layer renders it.

**Data Flow**:

```
Server JSON → AiAnalysisResponse (DTO) → AiContentAssembler → AiContentViewModel → player configuration / AI analysis panel
```

**Client Model Descriptions**:

| Class | Responsibility |
| ---- | ---- |
| `AiContentAssembler` | Pure static stateless assembler; `buildViewModel(AiAnalysisResponse)` converts the DTO to a presentation model |
| `AiContentViewModel` | Panel presentation-layer model; fields: `chapters` / `knowledgeItems` / `summaryInfo` |
| `KnowledgeInfo` | Knowledge point info; fields: `title` / `startMs` / `endMs` / `contentMarkdown` (pre-formatted: `- **{Point}**: {Description}`) |
| `SummaryInfo` | Video summary info; fields: `paragraphSummary` / `mindMapTitles` (`List<String>`) / `markdownContent` |
| `ChapterInfo` | Built-in chapter model of the widget (`aliplayer_widget`); fields: `id` / `startMs` / `endMs` / `title` / `thumbnailUrl`, with `findIndexByPosition` binary search. **Takes effect as long as it is passed to `AliPlayerWidgetData.chapters`, regardless of `SceneType.aiVod`.** |

**Design Principles**:

- **Single Responsibility**: The DTO handles only JSON mapping, the assembler handles only data conversion, and the UI handles only rendering
- **Three-Level Fallback**: `KnowledgeInfo.contentMarkdown` generation rule — KnowledgePoints first → Summary second → null if both empty
- **Time-Ordered**: Chapter and knowledge point lists are ordered by non-overlapping time ranges; `findIndexByPosition` locates the current item via binary search

---

## **8. Customization & Extension**

### **8.1 Replace Data Source**

The example project loads data through `AiContentLoader` (built on dio, with 5-second connect and receive timeouts and a `cancel()` method). To use your own data source, replace the data loading logic following the same flow; as long as you can produce an `AiAnalysisResponse` DTO, the entire assembly pipeline can be reused:

```dart
final loader = AiContentLoader();
loader.loadPlayAuth(vid, (playAuth) {
  // After obtaining playAuth, continue loading AI analysis content
  loader.loadAiAnalysis(vid, (response) {
    // response is a pure DTO; the consumer must explicitly call AiContentAssembler
    final content = response != null
        ? AiContentAssembler.buildViewModel(response)
        : null;
    // Configure the player, see 8.3
  });
});
```

> **Note**: Chapter data is assembled by `AiContentAssembler.buildViewModel`. Summary and knowledge point content cannot be carried on `AliPlayerWidgetData`; the business layer must pass it explicitly into `showChapterContentPanel` when opening the panel.

### **8.2 Customize UI**

- **Replace the AI analysis panel style**: Copy `example/lib/pages/ai_education/chapter_content_panel_widget.dart` and adjust the layout and styles as needed. The panel exposes only one entry point to the outside: `showChapterContentPanel(...)`.
- **Extend slots**: Register custom slots via the `slotBuilders` of `AliPlayerWidget`. The example project implements the top-left chapter button with a custom slot:

```dart
static const _slotTypeChapterShow = SlotType(
  'chapterShowButton',
  defaultOrder: 55,
);

AliPlayerWidget(
  _controller,
  slotBuilders: {
    _slotTypeChapterShow: (context) => ChapterButtonWidget(
      controller: _controller,
      onTap: () => _showChapterContentPanel(context),
    ),
  },
);
```

- **Reuse the chapter list panel**: The built-in right-slide chapter list panel can be opened independently:

```dart
ChaptersPanelManager.showChaptersPanel(
  context: context,
  chapters: chapters,
  currentIndex: currentIndex,
  onChapterSelected: (index) {
    _controller.seek(Duration(milliseconds: chapters[index].startMs));
  },
);
```

- See [Slot System](../advanced/slot-system-en.md) for slot mechanism details and [Scene Type](../advanced/scene-type-en.md) for scene capabilities.

### **8.3 Integrate into Your Own Page**

If you do not use the example page, follow the steps below in your own page:

1. Create an `AliPlayerWidgetController`
2. Request the play credential and AI analysis content
3. Assemble the `AiContentViewModel` and configure `AliPlayerWidgetData` (`chapters` required; set `sceneType` as needed — the example uses `SceneType.aiVod`)
4. Register custom slots such as the chapter button
5. Call `showChapterContentPanel` when the chapter button is tapped
6. Cancel loading tasks and destroy the controller when the page is disposed

**Example Skeleton**:

```dart
class AiEducationPage extends StatefulWidget {
  const AiEducationPage({super.key});

  @override
  State<AiEducationPage> createState() => _AiEducationPageState();
}

class _AiEducationPageState extends State<AiEducationPage> {
  late final AliPlayerWidgetController _controller;
  AiContentLoader? _contentLoader;
  AiContentViewModel _content = const AiContentViewModel(
    chapters: [],
    knowledgeItems: [],
  );

  static const _slotTypeChapterShow = SlotType(
    'chapterShowButton',
    defaultOrder: 55,
  );

  @override
  void initState() {
    super.initState();
    _controller = AliPlayerWidgetController();

    const vid = AiContentConstants.defaultMediaId;
    final loader = AiContentLoader();
    _contentLoader = loader;

    // Chained loading: PlayAuth → AI content → configure the player
    loader.loadPlayAuth(vid, (playAuth) {
      if (playAuth == null || playAuth.isEmpty) return;
      loader.loadAiAnalysis(vid, (response) {
        if (response != null) {
          _content = AiContentAssembler.buildViewModel(response);
        }
        _configure(vid, playAuth);
      });
    });
  }

  void _configure(String vid, String playAuth) {
    final source = VideoSourceFactory.createVidAuthSource(
      vid: vid,
      playAuth: playAuth,
    );
    _controller.configure(
      AliPlayerWidgetData(
        videoSource: source,
        sceneType: SceneType.aiVod,
        chapters: _content.chapters,
      ),
    );
  }

  void _showChapterContentPanel(BuildContext context) {
    if (!_content.hasAnyContent) return;
    final position = _controller.currentPositionNotifier.value;
    final currentIndex = ChapterInfo.findIndexByPosition(
      _content.chapters,
      position.inMilliseconds,
    );
    showChapterContentPanel(
      context: context,
      content: _content,
      currentIndex: currentIndex,
      onChapterSelected: (index) {
        final chapter = _content.chapters[index];
        _controller.seek(Duration(milliseconds: chapter.startMs));
      },
      onSegmentSelected: (startMs) {
        _controller.seek(Duration(milliseconds: startMs));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AliPlayerWidget(
        _controller,
        slotBuilders: {
          _slotTypeChapterShow: (context) => ChapterButtonWidget(
            controller: _controller,
            onTap: () => _showChapterContentPanel(context),
          ),
        },
      ),
    );
  }

  @override
  void dispose() {
    _contentLoader?.cancel();
    _controller.destroy();
    super.dispose();
  }
}
```

> **Note**: The example project also handles the following edge cases. We recommend preserving them when copying to your own project:
>
> - When PlayAuth fails, the example shows a message via `ToastUtils` and calls `Navigator.of(context).pop()` to avoid leaving a black screen.
> - When AI content fails to load, playback is not affected; a toast is shown to inform the user, and `_configure` is still called to complete player configuration.
> - Use an `_isChapterContentPanelShowing` state to prevent the panel from being opened repeatedly by rapid taps.
> - In `dispose()`, call `_contentLoader?.cancel()` and `_controller.destroy()` in turn to release network requests and player resources.

---

## **9. Integration FAQ**

| Question | Solution |
| ---- | ---- |
| Failed to get the play credential | Check whether the App Server address is correct, the network is reachable, and the `videoId` is valid; the example shows a message and exits the page on failure |
| AI content is empty | Confirm that AI content analysis has been completed for the video; an AI analysis API failure does not affect playback — the client degrades to normal VOD mode (no AI analysis panel) |
| How to use my own video ID | Modify `AiContentConstants.defaultMediaId`, or pass the media ID dynamically in your business calls |
| Progress bar chapter markers / chapter chips not showing | Confirm that `AliPlayerWidgetData.chapters` contains at least 2 valid chapter entries. Chapter capabilities are not strictly bound to `sceneType` |
| No chapter info row in landscape | The chapter info row is displayed when valid `chapters` data is passed in; it is not strictly bound to `SceneType.aiVod`. Verify that chapter data has been passed in |
| How to disable a specific AI capability | Simply omit the corresponding `ResultType` from the server response (e.g., return only `Chapter` without `Summary`); the panel Tab structure adjusts automatically based on the data |
| Widget version requirement | AliPlayerWidget >= 7.18.0; `flutter_aliplayer >= 7.18.0`; underlying native player SDK >= 7.18.0. Chapter UI capabilities are implemented in pure Dart and are not dependent on `SceneType.aiVod` |
| Chapter panel layout is wrong after orientation change | Confirm that the page supports orientation changes (for example, via `SystemChrome.setPreferredOrientations` or `MaterialApp` orientation settings). On the Flutter side, the panel adapts through `OrientationBuilder` / `MediaQuery.orientationOf`, so you do not need to declare `android:configChanges` in `AndroidManifest.xml` as required by the native Android solution |
| Markdown rendering exception | Check that the Markdown rendering dependency is correctly declared in `pubspec.yaml` (the example project uses `markdown: ^7.2.0` and renders via `Document().parse()`). Confirm that the `MarkdownContent` returned by the server is valid Markdown and does not contain unadapted HTML tags |
| Chapter button not showing | Confirm that `AiContentViewModel.hasAnyContent` is `true` (i.e., chapter or summary data is present). Confirm that the `_slotTypeChapterShow` custom slot is registered through `AliPlayerWidget.slotBuilders` |
| AI content request timeout | The example `AiContentLoader` uses a 5-second connect and receive timeout. If the network environment is poor, copy the `AiContentLoader` implementation and adjust the dio `connectTimeout` / `receiveTimeout` |

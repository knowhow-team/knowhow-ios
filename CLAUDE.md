# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

konwHow is a SwiftUI-based iOS knowledge base application that allows users to browse and manage knowledge items. The app features a tab-based interface with knowledge base and community sections, plus voice recording capabilities with speech recognition for capturing knowledge.

## Build and Development Commands

### Building the Project
- Open `konwHow.xcodeproj` in Xcode to build and run the project
- Use Xcode's built-in build system (⌘+B to build, ⌘+R to run)
- For testing: ⌘+U to run unit tests

### Testing
- Unit tests are located in `konwHowTests/konwHowTests.swift`
- UI tests are in `konwHowUITests/`
- Uses Swift Testing framework (not XCTest) - note the `@Test` annotation and `#expect()` assertions

## Code Architecture

### Project Structure
```
konwHow/
├── konwHowApp.swift           # App entry point (@main)
├── ContentView.swift          # Root view with tab management
├── GrapeTest.swift            # Grape visualization testing (currently disabled)
├── Models/
│   ├── KnowledgeItem.swift           # Data model for knowledge items
│   └── SpeechRecognitionManager.swift # Speech-to-text functionality
└── Views/
    ├── Components/
    │   ├── KnowledgeCard.swift      # Reusable card component
    │   ├── KnowledgeGraphView.swift # Grape-based graph visualization
    │   ├── SidebarButton.swift      # Hamburger menu button
    │   ├── TabBar.swift            # Custom tab bar with center button
    │   └── TagView.swift           # Tag display component
    └── Screens/
        ├── CommunityView.swift     # Placeholder community view
        ├── KnowledgeBaseView.swift # Main knowledge display
        ├── RecordingView.swift     # Voice recording with visualization
        ├── SidebarView.swift       # Navigation sidebar
        └── VoiceRecordView.swift   # Voice record history
```

### Key Components

**ContentView** (`ContentView.swift:10`): Root container managing tab state and navigation between KnowledgeBaseView and CommunityView.

**TabBar** (`TabBar.swift:10`): Custom bottom navigation with two tabs (知识库/社区) and a center action button that triggers recording functionality. Uses binding for tab state management.

**KnowledgeBaseView** (`KnowledgeBaseView.swift:10`): Main screen displaying "Cody" branding, sidebar navigation, and scrollable list of knowledge cards. Contains hardcoded sample data for AdventureX hackathon.

**RecordingView** (`RecordingView.swift:10`): Full-screen voice recording interface with custom SiriWaveView audio visualization using animated sine waves. Integrates with SpeechRecognitionManager for real-time speech-to-text transcription and audio level monitoring.

**SidebarView** (`SidebarView.swift:10`): Navigation sidebar with links to voice records and tag management. Slides in from the left edge.

**KnowledgeGraphView** (`KnowledgeGraphView.swift:5`): Interactive knowledge graph visualization using Grape library with ForceDirectedGraph for node positioning and physics simulation. Features draggable nodes with collision detection.

**SpeechRecognitionManager** (`SpeechRecognitionManager.swift:13`): ObservableObject handling speech-to-text functionality with multi-language support (Chinese, English), real-time audio level monitoring, and AVFoundation integration.

**KnowledgeItem** (`KnowledgeItem.swift:10`): Simple data model with id, title, description, and category properties.

### Navigation Architecture
The app uses a multi-layered navigation system:
1. **Tab-based navigation**: Primary tabs handled by ContentView
2. **Modal presentations**: Full-screen modals for recording and voice history
3. **Sidebar navigation**: Slide-in menu for additional features
4. **Sheet presentations**: Used for secondary content

### Voice Recording Flow
1. User taps center button in TabBar
2. RecordingView presents full-screen with immediate recording start
3. SpeechRecognitionManager begins audio capture and speech recognition
4. Real-time visual feedback through animated sine wave visualization
5. Transcribed text updates live as user speaks
6. Stop recording reveals save/discard options with final transcription
7. Save returns to main view; discard cancels the recording

### Dependencies
- **Grape**: SwiftUI graph visualization library (version 1.1.0) - includes ForceSimulation component for physics-based graph layouts
- **Speech**: iOS Speech framework for speech recognition capabilities
- **AVFoundation**: Audio recording, playback, and real-time audio level monitoring
- Uses Swift Package Manager for dependency management

### Design System
- Primary green color: `Color(red: 0.2, green: 0.8, blue: 0.4)`
- Background color: `Color(red: 0.96, green: 0.98, blue: 0.96)` (very light green) for main areas
- Pure white backgrounds for cards and overlays
- Card styling: White background with corner radius 8-16 and subtle shadows
- Text hierarchy: Bold titles (16-18pt), descriptions (14pt)
- Chinese text used in UI ("知识库", "社区", "原始语音记录", etc.)
- Consistent shadow styling: `Color.black.opacity(0.05), radius: 4-8, x: 0, y: 1-4`

### State Management
- Uses `@State` for local component state
- Uses `@Binding` for parent-child communication
- Uses `@Environment(\.dismiss)` for modal dismissal
- Timer management for recording functionality

### Development Notes
- All Swift files include standard header comments with creation date
- Implements SwiftUI previews for all components
- Custom animations with `withAnimation(.easeInOut(duration: 0.2-0.3))`
- Grape library actively used for ForceDirectedGraph visualization with physics simulation
- Custom Shape implementations for audio visualization (SineWave in RecordingView)
- ObservableObject pattern for state management (SpeechRecognitionManager)
- Multi-language support for speech recognition (Chinese simplified/traditional, English)
- Real-time audio processing with published audio level updates
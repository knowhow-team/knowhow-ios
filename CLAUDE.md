# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

konwHow is a SwiftUI-based iOS knowledge base application that allows users to browse and manage knowledge items. The app features a tab-based interface with knowledge base and community sections, plus voice recording capabilities for capturing knowledge.

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
│   └── KnowledgeItem.swift    # Data model for knowledge items
└── Views/
    ├── Components/
    │   ├── KnowledgeCard.swift      # Reusable card component
    │   ├── KnowledgeGraphView.swift # Canvas-based graph visualization
    │   ├── SidebarButton.swift      # Hamburger menu button
    │   ├── TabBar.swift            # Custom tab bar with center button
    │   └── TagView.swift           # Tag display component
    └── Screens/
        ├── CommunityView.swift     # Placeholder community view
        ├── KnowledgeBaseView.swift # Main knowledge display
        ├── RecordingView.swift     # Voice recording interface
        ├── SidebarView.swift       # Navigation sidebar
        └── VoiceRecordView.swift   # Voice record history
```

### Key Components

**ContentView** (`ContentView.swift:10`): Root container managing tab state and navigation between KnowledgeBaseView and CommunityView.

**TabBar** (`TabBar.swift:10`): Custom bottom navigation with two tabs (知识库/社区) and a center action button that triggers recording functionality. Uses binding for tab state management.

**KnowledgeBaseView** (`KnowledgeBaseView.swift:10`): Main screen displaying "Cody" branding, sidebar navigation, and scrollable list of knowledge cards. Contains hardcoded sample data for AdventureX hackathon.

**RecordingView** (`RecordingView.swift:10`): Full-screen voice recording interface with 5x5 grid visualization, timer display, and save/discard options. Features animated progress indicators.

**SidebarView** (`SidebarView.swift:10`): Navigation sidebar with links to voice records and tag management. Slides in from the left edge.

**KnowledgeGraphView** (`KnowledgeGraphView.swift:56`): Canvas-based knowledge graph visualization showing nodes and connections. Currently uses fixed positioning rather than Grape library.

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
3. Visual feedback through 5x5 grid that fills based on recording time
4. Stop recording reveals save/discard options
5. Save returns to main view; discard cancels the recording

### Dependencies
- **Grape**: SwiftUI graph visualization library (version 1.1.0) - includes ForceSimulation component
- Currently disabled in code due to implementation issues
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
- Grape library integration is commented out but structure remains for future implementation
- Canvas is used for custom drawing in KnowledgeGraphView
- Custom shape extensions for partial corner radius support
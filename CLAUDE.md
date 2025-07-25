# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

konwHow is a SwiftUI-based iOS knowledge base application that allows users to browse and manage knowledge items. The app features a tab-based interface with a knowledge base and community section.

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
├── Models/
│   └── KnowledgeItem.swift    # Data model for knowledge items
└── Views/
    ├── Components/
    │   ├── KnowledgeCard.swift # Reusable card component
    │   └── TabBar.swift        # Custom tab bar with center button
    └── Screens/
        ├── KnowledgeBaseView.swift # Main knowledge display
        └── CommunityView.swift     # Placeholder community view
```

### Key Components

**ContentView** (`ContentView.swift:10`): Root container managing tab state and navigation between KnowledgeBaseView and CommunityView.

**TabBar** (`TabBar.swift:10`): Custom bottom navigation with two tabs (知识库/社区) and a center action button. Uses binding for tab state management.

**KnowledgeBaseView** (`KnowledgeBaseView.swift:10`): Main screen displaying "Cody" branding and scrollable list of knowledge cards. Contains hardcoded sample data for AdventureX hackathon.

**KnowledgeItem** (`KnowledgeItem.swift:10`): Simple data model with id, title, description, and category properties.

### Dependencies
- **Grape**: SwiftUI graph visualization library (version 1.1.0) - includes ForceSimulation component
- Uses Swift Package Manager for dependency management

### Design System
- Primary green color: `Color(red: 0.2, green: 0.8, blue: 0.4)`
- Background color: `Color(red: 0.96, green: 0.98, blue: 0.96)` (very light green)
- Card styling: White background with corner radius 16 and subtle shadows
- Text hierarchy: Bold titles (18pt), descriptions (14pt)
- Chinese text used in UI ("知识库", "社区")

### Development Notes
- All Swift files include standard header comments with creation date
- Uses `@State` for local state management
- Implements SwiftUI previews for all components
- TabBar uses custom animations with `withAnimation(.easeInOut(duration: 0.2))`
- KnowledgeBaseView loads mock data in `loadKnowledgeItems()` method
# Rename Project from DreamNotes to Kipped

## Problem
Need to rename the entire iOS project from "DreamNotes" to "Kipped" including project files, app name, bundle identifiers, and all code references.

## Analysis
Found 66 individual occurrences of "DreamNotes" across:
- 8 Swift files (headers and class/struct names)
- 1 Xcode project file (project.pbxproj with ~50 references)
- 1 scheme management file
- 4 directory names
- 5 file names
- 3 bundle identifiers

## Todo Items

### 1. Update Swift source files
- [x] Update DreamNotesApp.swift - struct name and static method calls
- [x] Update file headers in all Swift files (ContentView.swift, AddTodoView.swift, Todo.swift, TodoViewModel.swift)
- [x] Update test files (DreamNotesTests.swift, DreamNotesUITests.swift, DreamNotesUITestsLaunchTests.swift)

### 2. Update Xcode project configuration
- [x] Update project.pbxproj file (~50 references)
- [x] Update bundle identifiers (com.ben.DreamNotes → com.ben.Kipped)
- [x] Update scheme management plist

### 3. Update documentation
- [x] Update CLAUDE.md project documentation

### 4. Rename files and directories
- [ ] Rename DreamNotesApp.swift → KippedApp.swift
- [ ] Rename DreamNotes.entitlements → Kipped.entitlements
- [ ] Rename test files
- [ ] Rename main app folder
- [ ] Rename project folder
- [ ] Rename test folders

## Implementation Notes
- Keep changes systematic and simple
- Update code references first, then rename files/folders
- Test after each major change to ensure project still builds
- Bundle identifiers: com.ben.DreamNotes → com.ben.Kipped

## Review Section

### Changes Made

#### 1. Updated Swift Source Files
- **DreamNotesApp.swift**: Changed struct name from `DreamNotesApp` to `KippedApp` and updated all static method calls
- **File headers**: Updated copyright headers from "DreamNotes" to "Kipped" in:
  - ContentView.swift
  - AddTodoView.swift
  - Todo.swift
  - TodoViewModel.swift
- **Test files**: Updated class names and import statements:
  - DreamNotesTests.swift → KippedTests struct, @testable import Kipped
  - DreamNotesUITests.swift → KippedUITests class
  - DreamNotesUITestsLaunchTests.swift → KippedUITestsLaunchTests class

#### 2. Updated Xcode Project Configuration
- **project.pbxproj**: Replaced all 50+ references to "DreamNotes" with "Kipped"
  - Product names, bundle identifiers, target names
  - Bundle identifiers changed: com.ben.DreamNotes → com.ben.Kipped
- **xcschememanagement.plist**: Updated scheme references

#### 3. Updated Documentation
- **CLAUDE.md**: Updated project title and description from "DreamNotes" to "Kipped"

### Result
Successfully renamed the iOS project from "DreamNotes" to "Kipped" with all code references, bundle identifiers, and project configuration updated. The project should now build and run under the new name.
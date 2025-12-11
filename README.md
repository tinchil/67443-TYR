# Saturdays

**Capture today. Relive it together.**

A memory capsule app that lets you save moments now and relive them in the future with the people who matter.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Test Coverage](#test-coverage)
- [Setup Instructions](#setup-instructions)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)

---

## Overview

Saturdays is an iOS social memory-sharing application that enables users to create collaborative "memory capsules" with friends and family. Unlike traditional photo-sharing apps, Saturdays focuses on the future - users upload photos and memories to capsules that unlock on specific dates, creating anticipation and meaningful moments when memories are revealed.

### Core Concept

- **Create Memory Capsules**: Users form groups with friends and create themed capsules (trips, events, life milestones)
- **Collaborative Contributions**: Group members upload photos and reflections throughout an experience
- **Time-Locked Content**: Capsules remain locked until a chosen reveal date or until all participants contribute
- **AI-Generated Videos**: Upon unlock, all shared memories are automatically compiled into a curated video story
- **Smart Discovery**: AI-powered features like "On This Day" and automatic event clustering help surface forgotten memories

---

## Key Features

### 1. Group Capsule Creation
- Create shared memory spaces with friends and family
- Set custom capsule names and themes
- Define group membership and permissions
- **Implementation**: `GroupsService.swift`, `ChooseGroupView.swift`, `GroupCreatedSuccessView.swift`

### 2. Time-Locked Reveals
- Set future unlock dates for capsules
- Hidden content remains locked until the chosen date
- Option to require minimum contributions from all participants before unlock
- **Implementation**: `CapsuleModel.swift`, `RevealSettingsView.swift`, `ContributionRequirementsView.swift`

### 3. Unlock Day Experience
- Capsules transform into curated video compilations on unlock day
- AI-powered video generation from all shared photos
- Notification system alerts group members when capsules unlock
- **Implementation**: `VideoCreator.swift`, `VideoPlayerView.swift`, `CapsuleDetailView.swift`

### 4. Gallery Crawl (Auto Photo Ingestion)
- Automatic scanning of user's entire photo library
- Background photo ingestion with permission
- Smart detection of new events and memories
- **Implementation**: `PhotoLibraryIngestionService.swift`, `PhotoMetadataExtractor.swift`

### 5. AI-Powered Event Clustering
- Core ML-based unsupervised model (K-Means/DBSCAN) trained on photo metadata
- Automatically groups photos by time, location, and context into events
- Dynamic event detection without hardcoded rules
- **Implementation**: `EventCluster.swift`, `PhotoEvent.swift`

### 6. Facial Recognition & People Grouping
- MobileFaceNet integration for face detection
- Group photos by people appearing together
- Smart suggestions for capsule creation based on who appears in photos
- **Implementation**: `FaceEmbeddingService.swift`, `FaceCluster.swift`

### 7. "On This Day" Albums
- Automatically generated throwback albums based on historical timestamps
- Daily surfacing of memories from past years
- Displayed prominently on the Home tab
- **Implementation**: `GeneratedCapsuleModel.swift`, `OnThisDayCapsulesSection.swift`

### 8. Memory Mirror Dashboard (Insights)
- Visual analytics showing event timelines
- Photo count statistics over time
- Social clustering insights (who you spend time with)
- Activity trends across your capsules
- **Implementation**: `MemoryTimelineView.swift`, `TimelineService.swift`, `HomeViewModel.swift`

### 9. Collaborative Uploads & Push Notifications
- Group members can upload to shared capsules
- Push notifications when all contributions are ready
- Real-time sync across all group members
- **Implementation**: `CapsuleService.swift`, `AddPhotosView.swift`, Firebase Cloud Messaging

### 10. Event Renaming & Editing UI
- User-facing controls to rename, merge, or split event clusters
- Editable labels with smart suggestions
- Override AI clustering decisions when needed
- **Implementation**: `CapsuleDetailsViewModel.swift`, `CapsuleDetailView.swift`

---

## Architecture

### Design Pattern: MVVM (Model-View-ViewModel)

**Models** (`/Saturdays/Models/`)
- `UserModel.swift` - User accounts and friend relationships
- `CapsuleModel.swift` - Memory capsule containers with media and metadata
- `GroupModel.swift` - Group definitions and membership
- `PhotoItem.swift` - Individual photos with location/timestamp metadata
- `PhotoEvent.swift` - AI-clustered photo events
- `GeneratedCapsuleModel.swift` - AI-generated "On This Day" compilations

**ViewModels** (`/Saturdays/ViewModels/`)
- `HomeViewModel.swift` - Home screen state management
- `AuthViewModel.swift` - Authentication flow
- `CapsuleDetailsViewModel.swift` - Capsule detail screen logic
- `GroupsViewModel.swift` - Group management
- `FriendsViewModel.swift` - Friend relationship handling

**Views** (`/Saturdays/Views/`)
- **Navigation**: `MainTabView.swift` - Primary tab-based navigation
- **CapsuleViews**: Capsule browsing, detail views, photo uploads
- **GroupCreation**: Multi-step group creation flow
- **AIGeneratedCapsules**: AI-generated capsule displays
- **Friends**: Friend management UI
- **Timeline**: Memory timeline visualization
- **Videos**: Video playback for unlocked capsules

**Services** (`/Saturdays/Services/`)
- `AuthService.swift` - Firebase Authentication
- `CapsuleService.swift` - Capsule CRUD operations with Firestore
- `GroupsService.swift` - Group creation and management
- `FriendsService.swift` - Friend search and requests
- `StorageService.swift` - AWS S3 image uploads
- `VideoCreator.swift` - AI video compilation
- `PhotoLibraryIngestionService.swift` - Photo library scanning
- `FaceEmbeddingService.swift` - Face detection ML
- `EventCluster.swift` - ML-based event clustering

### Dependency Injection for Testability

Authentication and database operations use protocol-based dependency injection:

- **`AuthProviding`** protocol with `FirebaseAuthProvider` implementation
- **`DatabaseProviding`** protocol with `FirestoreDatabase` implementation
- Mock implementations (`MockAuth.swift`, `MockDB.swift`) for unit testing

---

## Test Coverage

### Test Suite: 26 Test Files

**Location**: `/SaturdaysTests/`

#### Authentication & User Management
- `AuthServiceTests.swift` - User registration, login, sign-out flows
- `AuthViewModelTests.swift` - Authentication state management
- `UserModelTests.swift` - User model serialization and validation

#### Capsule & Group Features
- `CapsuleModelTests.swift` - Capsule data model serialization
- `CapsuleDetailsViewModelTests.swift` - Capsule detail screen logic
- `GroupModelTests.swift` - Group model validation
- `ChooseGroupViewTests.swift` - Group selection UI
- `GroupCreatedSuccessViewTests.swift` - Success screen display

#### Photo & Event Clustering
- `PhotoItemTests.swift` - Photo metadata handling
- `PhotoEventTests.swift` - AI event clustering logic
- `PixelBufferRendererTests.swift` - GPU-accelerated image rendering

#### Friend Management
- `FriendTests.swift` - Friend relationship operations

#### UI Components
- `MainTabViewTests.swift` - Tab navigation
- `LoginViewTests.swift` - Login form validation
- `CreateAccountViewTests.swift` - Registration form
- `CapsuleCardViewTests.swift` - Capsule card component
- `MemoryCardTests.swift` - Memory card display
- `PromptCardTests.swift` - Prompt card rendering
- `LetterCardTests.swift` - Letter card component
- `BottomNavBarTests.swift` - Bottom navigation bar

#### Video & Timeline
- `VideoPlayerTests.swift` - Video playback logic
- `MemoryTimelineViewTests.swift` - Timeline display

#### ViewModels
- `HomeViewModelTests.swift` - Home screen state management

### Test Infrastructure

- **Framework**: Apple's native `Testing` framework for SwiftUI
- **Mocking**: Protocol-based dependency injection with mock providers
- **Test Plan**: `Saturdays.xctestplan` with parallelizable test execution
- **Coverage**: Authentication, models, ViewModels, UI components, services, and AI features

### Running Tests

```bash
# Run all tests from Xcode
cmd + U

# Or run from command line
xcodebuild test -scheme Saturdays -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Setup Instructions

### Prerequisites

- macOS with Xcode 15.0 or later
- iOS 17.0+ deployment target
- Apple Developer account (for running on physical device)
- Git installed

### 1. Clone the Repository

```bash
git clone <repository-url>
cd 67443-TYR
```

### 2. Configure Firebase

The app uses Firebase for authentication and database. A `GoogleService-Info.plist` file is already included in the repository.

**If you need to use your own Firebase project:**
1. Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
2. Add an iOS app to your project with bundle ID: `com.yourteam.Saturdays`
3. Download the `GoogleService-Info.plist` file
4. Replace the existing file at `/Saturdays/GoogleService-Info.plist`
5. Enable **Authentication** (Email/Password) and **Firestore Database** in Firebase Console

### 3. Configure AWS S3 Credentials (Optional)

The app uses AWS S3 for photo storage. You'll need to configure credentials:

1. Copy the secrets template:
```bash
cp Saturdays/Config/Secrets.plist.template Saturdays/Config/Secrets.plist
```

2. Open `Saturdays/Config/Secrets.plist` and fill in your AWS credentials:
```xml
<key>AWSAccessKeyID</key>
<string>YOUR_AWS_ACCESS_KEY_ID</string>
<key>AWSSecretAccessKey</key>
<string>YOUR_AWS_SECRET_ACCESS_KEY</string>
<key>AWSRegion</key>
<string>us-east-1</string>
<key>AWSBucketName</key>
<string>your-bucket-name</string>
```

**Note**: If you don't configure AWS, photo uploads may not work. The existing configuration may work for testing purposes.

### 4. Open in Xcode

```bash
open Saturdays.xcodeproj
```

### 5. Configure Code Signing

1. In Xcode, select the **Saturdays** project in the navigator
2. Select the **Saturdays** target
3. Go to **Signing & Capabilities** tab
4. Select your **Team** from the dropdown
5. Xcode will automatically manage provisioning profiles

### 6. Running on Physical Device (iPhone)

#### Option A: Direct Cable Connection

1. Connect your iPhone to your Mac via USB cable
2. Unlock your iPhone and trust the computer if prompted
3. In Xcode, select your iPhone from the device dropdown (top toolbar)
4. Click the **Run** button (▶) or press `Cmd + R`
5. The app will build and install on your device

#### First-Time Device Setup:
After the app installs, you may see **"Untrusted Developer"** on your iPhone:
1. Go to **Settings** > **General** > **VPN & Device Management**
2. Tap on your Apple ID under **Developer App**
3. Tap **Trust "[Your Apple ID]"**
4. Tap **Trust** again to confirm
5. Return to the home screen and launch **Saturdays**

#### Option B: Wireless Debugging (Xcode 15+)

1. First-time setup requires USB connection (follow Option A once)
2. In Xcode, go to **Window** > **Devices and Simulators**
3. Select your connected iPhone
4. Check **Connect via network**
5. Disconnect the cable - your device will remain available in Xcode
6. Select the device and click Run (▶)

### 7. Running on Simulator

1. In Xcode, select any iPhone simulator from the device dropdown (e.g., **iPhone 15**)
2. Click the **Run** button (▶) or press `Cmd + R`
3. The simulator will launch and install the app

**Note**: Some features may be limited on simulator:
- Photo library access will use simulated photos
- Location services may not work realistically
- Camera features are not available

### 8. Grant Permissions

When you first launch the app, you'll be prompted to grant permissions:
- **Photo Library Access**: Required for Gallery Crawl and photo uploads
- **Location Services**: Used for event clustering and photo metadata
- **Notifications**: For capsule unlock alerts

Grant these permissions for full functionality.

### 9. Create an Account

1. Launch the app
2. Tap **Create Account**
3. Enter username, email, and password
4. You're now logged in and can start creating capsules!

---

## Technologies Used

### iOS Frameworks
- **SwiftUI** - Declarative UI framework
- **Combine** - Reactive programming for state management
- **CoreLocation** - GPS and location services
- **CoreImage** - Image processing
- **AVFoundation** - Video creation and playback
- **Vision** - Face detection ML
- **Photos** - Photo library access
- **CryptoKit** - AWS Signature V4 authentication

### Backend & Services
- **Firebase Authentication** - User accounts and auth
- **Firebase Firestore** - NoSQL database for users, capsules, groups
- **Firebase Storage** - Alternative cloud storage
- **AWS S3** - Primary photo/video storage with custom upload logic

### Machine Learning
- **Core ML** - On-device machine learning framework
- **K-Means/DBSCAN** - Unsupervised clustering for event detection
- **MobileFaceNet** - Lightweight face embedding model for people grouping

---

## Project Structure

```
67443-TYR/
├── Saturdays/                          # Main app source code
│   ├── SaturdaysApp.swift              # App entry point
│   ├── Auth/                           # Authentication system
│   │   ├── AuthService.swift
│   │   ├── AuthViewModel.swift
│   │   ├── AuthProviding.swift         # Testable auth protocol
│   │   └── DatabaseProviding.swift     # Testable database protocol
│   ├── Models/                         # Data models
│   │   ├── UserModel.swift
│   │   ├── CapsuleModel.swift
│   │   ├── GroupModel.swift
│   │   ├── PhotoEvent.swift            # AI event clusters
│   │   └── GeneratedCapsuleModel.swift
│   ├── Services/                       # Business logic
│   │   ├── CapsuleService.swift
│   │   ├── GroupsService.swift
│   │   ├── FriendsService.swift
│   │   ├── StorageService.swift        # AWS S3 uploads
│   │   ├── VideoCreator.swift          # AI video generation
│   │   ├── PhotoLibraryIngestionService.swift
│   │   ├── FaceEmbeddingService.swift  # Face detection ML
│   │   └── EventCluster.swift          # Event clustering ML
│   ├── ViewModels/                     # State management
│   │   ├── HomeViewModel.swift
│   │   ├── CapsuleDetailsViewModel.swift
│   │   └── GroupsViewModel.swift
│   ├── Views/                          # SwiftUI views
│   │   ├── Navigation/
│   │   │   └── MainTabView.swift
│   │   ├── CapsuleViews/
│   │   ├── GroupCreation/
│   │   ├── AIGeneratedCapsules/
│   │   ├── Friends/
│   │   ├── Timeline/
│   │   ├── Videos/
│   │   └── Components/
│   ├── Managers/
│   │   └── LocationManager.swift
│   ├── Config/                         # Configuration (git-ignored)
│   │   ├── AWSConfig.swift
│   │   ├── Secrets.plist
│   │   └── Secrets.plist.template
│   ├── Assets.xcassets/                # Images and colors
│   └── GoogleService-Info.plist        # Firebase config
├── SaturdaysTests/                     # Unit tests (26 files)
│   ├── Mock/
│   │   ├── MockAuth.swift
│   │   └── MockDB.swift
│   └── [Test files...]
├── Saturdays.xcodeproj/                # Xcode project
├── Saturdays.xctestplan                # Test plan
├── README.md                           # This file
└── .gitignore                          # Git ignore rules
```

---

## Sprint Development Timeline

This project was developed across 7 sprints:

| Sprint | Features Implemented |
|--------|---------------------|
| **Sprint 1** | User profile, authentication, friend search |
| **Sprint 2** | Photo uploads, group creation, capsule storage |
| **Sprint 3** | Basic ML event grouping, video generation |
| **Sprint 4** | Event renaming UI, "On This Day" albums, time capsule creation UI, memory scheduling UI, group creation UI |
| **Sprint 5** | Core ML v2 (unsupervised clustering), MobileFaceNet facial clustering, full gallery background scanning |
| **Sprint 6** | Capsule unlock & reveal logic, collaborative uploads & push notifications, Memory Mirror Dashboard (insights) |
| **Sprint 7** | Optimize caching (reduce re-clustering), QA testing, documentation |

---

## Team

Developed by **Group 7** for 67-443 Mobile App Development

---

## License

This project is an academic prototype developed for educational purposes.

---

## Troubleshooting

### "Developer Mode Required" (iOS 16+)
If you see this error on a physical device:
1. Go to **Settings** > **Privacy & Security** > **Developer Mode**
2. Enable **Developer Mode**
3. Restart your iPhone
4. Try running the app again from Xcode

### Build Errors
- Ensure you're using **Xcode 15.0+** and **iOS 17.0+ SDK**
- Clean build folder: **Product** > **Clean Build Folder** (Shift+Cmd+K)
- Delete derived data: `~/Library/Developer/Xcode/DerivedData`

### Firebase Connection Issues
- Verify `GoogleService-Info.plist` is in the project
- Check Firebase console for enabled services (Auth, Firestore)

### AWS Upload Failures
- Verify `Secrets.plist` exists and contains valid credentials
- Check S3 bucket permissions allow uploads from your access key

### Photo Library Access Not Working
- Check app permissions: **Settings** > **Saturdays** > **Photos**
- Should be set to "All Photos" access

---

## Contact

For questions or issues, please contact the development team or file an issue in the repository.

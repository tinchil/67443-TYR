# Saturdays  
**Capture today. Relive it together.**

A mobile-first memory capsule app that lets you save moments now and relive them in the future with the people who matter.

---

# Table of Contents
- [Overview](#overview)
- [Market Niche & Mobile Mental Model](#market-niche--mobile-mental-model)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Test Coverage](#test-coverage)
- [Running the App (TA Instructions)](#running-the-app-ta-instructions)
- [Technologies Used](#technologies-used)
- [Sprint Development Timeline](#sprint-development-timeline)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

# Overview

Saturdays is an iOS social memory-sharing application that enables users to create collaborative memory capsules with friends and family. Unlike traditional photo apps that focus on immediate posting, Saturdays focuses on memory over time.

Users upload photos into shared capsules that unlock on a future date, turning everyday memories into meaningful, anticipated group events. When a capsule unlocks, Saturdays automatically generates an AI-curated video story for the entire group to experience together.

### Core Concept
- **Create Memory Capsules** for trips, events, milestones
- **Collaborative Contributions** within each group
- **Time-Locked Content** until a set reveal date or until contributions are complete
- **AI-Generated Unlock Videos** when capsules open
- **Smart Discovery** of hidden memories through ML clustering and historical timelines

### Note on Video Playback (Simulator vs Physical Device)

During development, we discovered that **video playback behaves differently on the Simulator compared to a real iPhone**.

- The Simulator uses macOS video codecs  
- A physical iPhone uses iOS hardware decoders  

If the uploaded S3 video is encoded with a codec or container not supported by iOS hardware (e.g., certain H.264 profiles, missing audio tracks, incorrect MIME types), the **Simulator will still play the video**, but a **real iPhone will freeze** or fail to start playback.

This is a known AVFoundation behavior.

Our AI-generated video pipeline works on the Simulator but may not always match iOS hardware playback requirements, leading to this discrepancy on physical devices.


---

# Market Niche & Mobile Mental Model

## Identifiable Market Niche

Saturdays serves a well-defined, underserved niche:

### **Private, collaborative, time-locked memory spaces.**
Unlike Instagram, TikTok, or Google Photos, Saturdays is designed for:
- Close friend groups  
- Families  
- Couples  
- Private, emotional memory-sharing  
- Long-term anticipation and shared nostalgia  

It sits at the intersection of:
- **BeReal** → authenticity  
- **1 Second Everyday** → memory  
- **Google Photos** → archival  

But uniquely combines:
1. **Collaboration**  
2. **Time-locking**  
3. **AI unlock videos**  
4. **Event detection & smart clustering**

This is a concrete target market underserved by existing products.

---

## How Saturdays Leverages the Mobile Platform

Saturdays is deeply mobile-native and relies on device capabilities:

### 1. Photos + Camera Integration
Direct ingestion from the user's photo library enables:
- metadata extraction  
- event clustering  
- face recognition  
- video creation  

### 2. Core ML & Vision
Runs **on-device ML models**:
- K-Means/DBSCAN event clustering  
- MobileFaceNet face embeddings  
- People grouping  

### 3. Location Services
Uses GPS metadata from photos to improve event grouping.

### 4. Push Notifications
Critical for:
- reveal-day alerts  
- group contribution updates  

### 5. Touch + Gestural UI
SwiftUI card-based interaction aligns with mobile-first mental models.

### 6. Background Execution
Gallery crawl scans user photos over time, something only mobile can provide.

Saturdays is designed to *feel native* to the mobile ecosystem.

---

# Key Features

### 1. Group Capsule Creation
- Create capsules for trips, events, and milestones  
- Add members with permissions  
- Custom themes and naming  
**Files:** `GroupsService.swift`, `ChooseGroupView.swift`, `GroupCreatedSuccessView.swift`

### 2. Time-Locked Reveals
- Capsules remain locked until future date  
- Optional minimum contribution requirement  
**Files:** `CapsuleModel.swift`, `RevealSettingsView.swift`

### 3. Unlock Day Experience
- AI-curated memory video generated on unlock  
- Group notification system  
**Files:** `VideoCreator.swift`, `VideoPlayerView.swift`

### 4. Gallery Crawl (Auto Ingestion)
- Background scanning of entire photo library  
- Detects new events automatically  
**Files:** `PhotoLibraryIngestionService.swift`

### 5. AI Event Clustering
- K-Means / DBSCAN unsupervised clustering  
- Groups photos by time, location, context  
**Files:** `EventCluster.swift`, `PhotoEvent.swift`

### 6. Facial Recognition & People Grouping
- MobileFaceNet face embeddings  
- Grouping based on co-occurrence  
**Files:** `FaceEmbeddingService.swift`

### 7. “On This Day” Albums
- Throwback collections based on historical timestamps  
**Files:** `GeneratedCapsuleModel.swift`

### 8. Memory Mirror Dashboard (Insights)
- Timelines, counts, trends, social clusters  
**Files:** `MemoryTimelineView.swift`, `TimelineService.swift`

### 9. Collaborative Uploads & Push Notifications
- Real-time syncing via Firebase  
- Push notifications via FCM  

### 10. Event Renaming & Editing UI
- Merge / split clusters  
- Editable labels  
**Files:** `CapsuleDetailsViewModel.swift`

---

# Architecture (MVVM)

### **Models**
- Capsule, Group, User, PhotoEvent, GeneratedCapsule

### **ViewModels**
- HomeViewModel  
- CapsuleDetailsViewModel  
- AuthViewModel  
- GroupsViewModel  

### **Views**
- MainTabView (navigation)
- Capsule views  
- Group creation views  
- Timeline views  
- Video playback  

### **Services**
- Firebase Auth & Firestore  
- AWS S3 media uploads  
- Photo ingestion system  
- ML clustering models  
- Video creator pipeline  

### Dependency Injection
Used for:
- AuthTesting  
- DatabaseTesting  
- Mocked testing of ViewModels  

---

### Dependency Injection for Testability

Authentication and database operations use protocol-based dependency injection:

- **`AuthProviding`** protocol with `FirebaseAuthProvider` implementation
- **`DatabaseProviding`** protocol with `FirestoreDatabase` implementation
- Mock implementations (`MockAuth.swift`, `MockDB.swift`) for unit testing

---

# Test Coverage

### Why coverage appears low (and why this is expected)

1. **Heavy reliance on external frameworks**
   - Firebase Auth  
   - Firestore  
   - AWS S3  
   - Vision & Core ML  
   - Photos framework  
   Mocking these realistically would require >20 hours of setup.

2. **Many features produce non-deterministic outputs**
   - ML clustering  
   - face embeddings  
   - video generation  
   These cannot be verified with static assertions.

### What IS tested
- Models & validation  
- ViewModels  
- Card components  
- Navigation basics  
- Timeline logic  
- Authentication flow  
- Group and capsule creation logic  

### Summary  
Coverage percentage is low, but meaningful logic is tested, and increasing coverage further would require unrealistic mocking for this course.

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

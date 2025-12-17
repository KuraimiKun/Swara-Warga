# SuaraWarga - Participatory Budgeting App

**SuaraWarga** (Suara = Voice, Warga = Citizen) is a Flutter-based e-democracy platform that enables transparent and participatory budgeting for Indonesian villages (Desa).

## 🎯 Problem Statement

In many Indonesian villages, the "Dana Desa" (Village Fund) allocation often doesn't reflect the priorities of younger generations. This creates:
- Lack of transparency in local governance
- Youth apathy toward local politics
- Disconnect between village leadership and residents' actual needs

## 💡 Solution

SuaraWarga democratizes the village budget decision-making process by allowing residents to vote on proposed projects, creating a digital audit trail and shifting power from the "elite" to the "residents".

## ✨ Features

### 🗳️ Voting System
- Village Head posts potential projects (e.g., "Fix Bridge", "New Futsal Court", "Free WiFi")
- Verified residents can vote on their preferred project
- One vote per NIK (National ID Number) ensures fair voting

### 🪪 Identity Verification
- Upload KTP (Indonesian ID Card) photo for verification
- Admin (Village Head) manually verifies each registration
- Ensures one person = one vote

### 📊 Data Visualization
- Beautiful pie charts showing vote distribution
- Real-time statistics on budget allocation preferences
- Transparent view of community priorities

### 💬 Moderated Discussion
- Comment threads for each project proposal
- Reply functionality for threaded discussions
- Admin moderation before comments go public
- Safe space for constructive civic dialogue

### 👨‍💼 Admin Panel (for Village Head)
- Create and manage project proposals
- Verify resident identities
- Moderate comments
- View comprehensive voting statistics

## 🛠️ Technical Stack

- **Framework**: Flutter 3.x
- **Backend**: Firebase
  - Firebase Auth (Authentication)
  - Cloud Firestore (Database)
  - Firebase Storage (KTP Images)
- **State Management**: Provider
- **Charts**: fl_chart
- **Image Handling**: image_picker

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Firebase project
- Android Studio / VS Code

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd swarawarga
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   
   Option A: Using FlutterFire CLI (Recommended)
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```
   
   Option B: Manual Configuration
   - Create a Firebase project at https://console.firebase.google.com/
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Enable Firebase Storage
   - Update `lib/firebase_options.dart` with your configuration

4. **Set up Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth.uid == userId;
         allow update: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
       }
       
       match /projects/{projectId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
       }
       
       match /votes/{voteId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isVerified == true;
       }
       
       match /comments/{commentId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isVerified == true;
         allow update, delete: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
       }
     }
   }
   ```

5. **Create an Admin User**
   - Register a new account
   - In Firebase Console > Firestore > users collection
   - Find the user document and set `isAdmin: true` and `isVerified: true`

6. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/
│   ├── user_model.dart          # User data model
│   ├── project_model.dart       # Project/proposal model
│   ├── vote_model.dart          # Vote record model
│   └── comment_model.dart       # Comment/discussion model
├── services/
│   ├── auth_service.dart        # Authentication & user management
│   ├── project_service.dart     # Project & voting operations
│   └── comment_service.dart     # Comment & moderation operations
├── screens/
│   ├── login_screen.dart        # Login page
│   ├── register_screen.dart     # Registration page
│   ├── home_screen.dart         # Main navigation
│   ├── project_detail_screen.dart  # Project details & voting
│   ├── ktp_verification_screen.dart # KTP upload
│   └── admin/
│       ├── admin_dashboard_screen.dart  # Admin panel
│       ├── add_project_screen.dart      # Create project
│       ├── verify_users_screen.dart     # User verification
│       └── moderate_comments_screen.dart # Comment moderation
├── widgets/
│   ├── project_card.dart        # Project list item
│   ├── budget_chart.dart        # Pie chart visualization
│   └── comment_section.dart     # Discussion thread
└── utils/
    ├── theme.dart               # App theme & colors
    └── helpers.dart             # Utility functions
```

## 🔐 Security Features

- **NIK Uniqueness**: One NIK can only register one account
- **KTP Verification**: Manual verification by admin ensures authentic users
- **Vote Protection**: One verified user can only vote once
- **Comment Moderation**: All comments require admin approval
- **Firebase Security Rules**: Server-side protection for all operations

## 🌐 Sociotech Impact

This app implements **E-Democracy** principles:
- **Transparency**: All votes and discussions are visible
- **Digital Audit Trail**: Complete record of all decisions
- **Youth Engagement**: Mobile-first approach
- **Power Redistribution**: Shifts decision-making to residents
- **Civic Participation**: Encourages active involvement

---

**Suaramu Menentukan Desamu** - Your Voice Determines Your Village

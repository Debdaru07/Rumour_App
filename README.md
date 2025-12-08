Rumour – Anonymous Realtime Chat Rooms (Flutter + Firebase)

Rumour is a realtime, anonymous chat application built using Flutter and Firebase Cloud Firestore.
Users can browse available rooms, join using a 4-digit room code, auto-generate an anonymous identity, and chat in realtime with offline caching and message pagination.

This repository includes:

✅ Full Flutter source code
✅ Firestore structure documentation
✅ Working APK
✅ Demo video walkthrough

🚀 Features
🔹 Realtime Chat

Messages sync instantly using Firestore streams

System messages (user joined / exited)

Live member count per room

🔹 Anonymous Identity

Each user gets a temporary random identity per room.

🔹 Rooms Directory

List of available rooms

Member count indicator

Quick navigation

🔹 Join Room With 4-Digit Code

Code validation

Autoflow → Name Assignment → Chat Screen

🔹 Message Pagination

Loads older messages page-by-page (15 at a time)

Efficient for large chat histories

🔹 Offline Support

Cached messages per room

App loads cached messages instantly even without internet

🔹 Firestore Security Rules (Recommended)
📁 Codebase Structure
lib/
│
├── app.dart
├── main.dart
│
├── src/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_assets.dart
│   │   └── services/
│   │       ├── room_service.dart
│   │       ├── firebase_chat_service.dart
│   │       ├── local_storage_service.dart
│   │
│   ├── features/
│       ├── rooms/                # Rooms listing screen
│       │   └── rooms_screen.dart
│       ├── join_room/            # Join via 4-digit code
│       │   └── join_room_screen.dart
│       ├── name_generation/      # Anonymous identity creator
│       │   ├── name_screen.dart
│       │   └── name_controller.dart
│       ├── chat/
│           ├── chat_screen.dart
│           ├── chat_controller.dart
│           ├── widgets/
│               ├── message_bubble.dart
│               ├── date_separator.dart
│               ├── message_input_field.dart
│               ├── system_message_banner.dart
│
├── firebase_options.dart
└── README.md

☁️ Firebase Cloud Firestore Structure
Collection: rooms
rooms
  └── {roomId}
       ├── name: string
       ├── code: string (4 digits)
       ├── members: [ {id, name, avatar} ]
       ├── createdAt: Timestamp
       └── messages (subcollection)
            └── {messageId}
                 ├── text: string
                 ├── senderId: string
                 ├── senderName: string
                 ├── senderAvatar: string
                 ├── type: "text" | "system"
                 ├── createdAt: Timestamp

📦 APK Download

👉 Download APK: (Insert your APK link here — e.g., GitHub Releases or Drive)
[APK Download Link]

🎥 Demo Video

👉 Watch Demo Video:
[Video Link Here]

The video demonstrates:

Opening the app

Viewing available rooms

Joining room using 4-digit code

Identity selection

Realtime chat with others

Pagination

Offline support behavior

🛠️ Running the Project Locally
1. Clone the repository
git clone https://github.com/yourusername/rumour.git
cd rumour

2. Install dependencies
flutter pub get

3. Setup Firebase

Add your Android/iOS Firebase apps

Update google-services.json / GoogleService-Info.plist

Ensure firebase_options.dart is generated

4. Run the app
flutter run

🧪 Testing Offline Mode

Open a chat room

Disable Wi-Fi

Cached messages remain visible

Reconnect → pending messages sync automatically

🔐 Recommended Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /rooms/{roomId} {
      allow read, write: if true; // For testing only

      match /messages/{messageId} {
        allow read, write: if true;
      }
    }
  }
}


⚠️ Replace with authenticated rules before production.

❤️ Credits

Built with Flutter & Firestore
Developed by Debdaru (Deb)

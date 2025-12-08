# **Rumour – Anonymous Realtime Chat Rooms (Flutter + Firebase)**

Rumour is a realtime, anonymous chat application built using **Flutter** and **Firebase Cloud Firestore**.  
Users can browse available rooms, join using a 4-digit room code, auto-generate an anonymous identity, and chat in realtime with **offline caching** and **message pagination**.

---

## ✅ **This repository includes**

- Full Flutter source code
- Firestore structure documentation
- Working APK
- Demo video walkthrough

---

# 🚀 **Features**

### 🔹 **Realtime Chat**

- Instant messaging using Firestore streams
- System messages (user joined / exited)
- Live member count updates

### 🔹 **Anonymous Identity**

Each user gets a generated identity unique to the room.

### 🔹 **Rooms Directory**

- List of available rooms
- Member count indicator
- Quick navigation into any room

### 🔹 **Join Room With 4-Digit Code**

- Validates room existence
- Flow → Join → Name Assignment → Chat

### 🔹 **Message Pagination**

- Loads older messages page-by-page (15 at a time)
- Efficient for large/history-heavy rooms

### 🔹 **Offline Support**

- Cached messages
- App loads previous messages instantly, even without internet

### 🔹 **Firebase Security Rules**

Recommended rules included below.

---

# 📁 **Codebase Structure**

```plaintext
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
│       ├── rooms/
│       │   └── rooms_screen.dart
│       ├── join_room/
│       │   └── join_room_screen.dart
│       ├── name_generation/
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
```

---

# Firebase Cloud Firestore Structure

```plaintext
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
```

---

## APK Download

👉 Download APK: [\[url\]](https://drive.google.com/file/d/1iNbF6zeDemWl789NOZH4sznfb-e7C_IB/view?usp=sharing)

## Demo Video

👉 Watch Demo: [url]

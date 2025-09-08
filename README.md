# 🕉️ JapAura – Your Daily Radha Nam Jap Companion

Radha Nam Jap counter app to help you track daily malas, counts, and maintain your spiritual streak effortlessly. Built with Flutter, Shared Preferences, and modern UI/UX design principles.

## ✨ Features

### 📿 Daily Nam Jap Counter
- Increment counts with a single tap anywhere
- Complete a mala of 108 counts
- Automatic mala tracking

### 🔔 Notifications & Feedback
- Vibration on mala completion
- Bell sound to celebrate milestone
- Congratulatory dialog when a mala is completed

### 📊 Daily & Historical Progress
- Track today's total counts and malas
- View historical progress in a scrollable sheet
- Calculate streaks automatically

### 🎨 Modern & Professional UI
- Gradient backgrounds and overlay effects
- Animated counters and mala completion effects
- Circular progress with glow and end dot
- Tap instruction for intuitive UX

### 🔄 Data Persistence
- Stores daily counts and malas using SharedPreferences
- Automatically updates historical progress
- Resets today's progress with confirmation dialog

## 🛠 Tech Stack
- Flutter – Cross-platform mobile development
- Dart – Application logic
- Shared Preferences – Local storage for progress
- Vibration – Device haptic feedback
- AudioPlayers – Bell sound on completion
- Intl – Date formatting
- CustomPainter – Circular progress UI

## 📸 Screenshots

### 🏠 Main Counter Screen
<img src="./assets/screenshots/home.jpeg" alt="Home Page" width="300"/>

### 🔔 Mala Complete Dialog
<img src="./assets/screenshots/MalaComplete.jpeg" alt="MalaComplete Page" width="300"/>

### 📊 Progress History
<img src="./assets/screenshots/Progress.jpeg" alt="Progress Page" width="300"/>

### ♻️ Reset Progress Dialog
<img src="./assets/screenshots/reset.jpeg" alt="Reset Progress Page" width="300"/>

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.0
- Android Studio / VS Code
- Emulator or physical device

### Installation
```bash
git clone https://github.com/yourusername/JapAura.git
cd JapAura
flutter pub get
flutter run
```

### Assets
- Place `bell.mp3` in `assets/audio/`
- Place background image `radha.png` in `assets/images/`

## 💡 Usage
- Tap anywhere on the screen to increment your count
- Complete a mala (108 counts) to celebrate
- Access progress history from the top-right history button
- Reset progress with the floating action button

## 🎨 Customization
- Modify gradient colors in `NamJapScreen` for personalized UI
- Change bell sound by replacing `bell.mp3`
- Adjust mala size or count limit in `_increment()` function

## 📂 Folder Structure
```
lib/
 ├─ main.dart          # Entry point
 ├─ screens/
 │   ├─ nam_jap_screen.dart
 ├─ widgets/
 │   ├─ progress_history_sheet.dart
 ├─ utils/
 │   ├─ daily_progress.dart
assets/
 ├─ images/
 │   ├─ radha.png
 ├─ audio/
     ├─ bell.mp3
```

## 🔗 Future Enhancements
- Dark/light mode toggle
- Sync progress across devices using Firebase
- Custom mala counts & reminders
- Statistics graphs for weekly/monthly progress


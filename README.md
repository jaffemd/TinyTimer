# TinyTimer 🎉

A delightful iOS timer app designed specifically for toddlers and small children. TinyTimer features engaging character animations, celebratory confetti effects, and completion music to make timing activities fun and rewarding for young users.

## Features

- **Visual Timer**: Circular progress ring with countdown display (10 seconds to 60 minutes)
- **Character Animations**: 3 adorable Lottie animations (Alpaca, Dinosaur, Pig) that play during countdown
- **Completion Celebration**: Full-screen confetti animation with completion music
- **Music Selection**: 3 completion songs (Upbeat Jovial, Storm Dance, We Made It)
- **Child-Friendly UX**: 
  - Swipeable character selection with accessible button alternatives
  - Touch anywhere to stop music and confetti
  - Large, colorful buttons with rounded design
  - Portrait-only orientation
- **Modern iOS Features**:
  - Dark mode support
  - Dynamic Island integration with live countdown
  - Background notifications when timer completes
  - Background timer continuation

## Requirements

- iOS 18.5+
- Xcode 16+
- Swift 5.0+

## Building the Project

### Prerequisites
1. Install Xcode 16 or later from the Mac App Store
2. Ensure you have iOS 18.5+ SDK available

### Build Instructions

1. **Clone the repository:**
   ```bash
   git clone git@github.com:jaffemd/TinyTimer.git
   cd TinyTimer
   ```

2. **Open the project:**
   ```bash
   open TinyTimer/TinyTimer.xcodeproj
   ```
   
   Or double-click `TinyTimer.xcodeproj` in Finder

3. **Select your target device:**
   - Choose an iOS Simulator (iPhone 16 recommended) or connected iOS device
   - Ensure the deployment target is iOS 18.5+

4. **Build and run:**
   - Press `⌘ + R` to build and run
   - Or click the Play button in Xcode's toolbar

### Command Line Build (Optional)

You can also build from the command line:

```bash
# Build for simulator
xcodebuild -scheme TinyTimer -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' build

# Clean build artifacts
xcodebuild clean -project TinyTimer.xcodeproj -scheme TinyTimer
```

## Project Structure

```
TinyTimer/
├── TinyTimer/
│   ├── Models/           # Data models and enums
│   ├── Views/            # SwiftUI views and components
│   ├── Services/         # Audio, notifications, and Live Activities
│   └── Assets.xcassets/  # App icons and images
├── TinyTimerWidget/      # Widget extension for Live Activities
└── assets/               # Lottie animations and audio files
```

## Dependencies

- **Lottie**: For character animations
- **ActivityKit**: For Dynamic Island integration (iOS 16.1+)
- **AVFoundation**: For audio playback and session management

Dependencies are managed via Swift Package Manager and will be automatically resolved when you open the project.

## Development Notes

- Target audience: Toddlers, small children, and their parents
- Focus on visual appeal, animations, and sound
- Optimized for portrait orientation on iPhone
- Uses semantic colors for automatic dark/light mode support

## License

This project is available for personal and educational use.

---

**Happy timing!** 🦕🦙🐷
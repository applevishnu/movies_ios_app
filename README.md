# Movies iOS App (`movies_ios_app`)

Native iOS host application (written in Swift and programmatic UIKit) that embeds the `movies_flutter_module` via CocoaPods and plays movie trailers natively.

---

## 1. Architecture & Features

- **Swift & UIKit (iOS 14+)**: Programmatic UI using Auto Layout for reliable compilation and lifecycle handling without storyboard merge conflicts.
- **Pre-warmed Flutter Engine**: Initialized and run in `AppDelegate` so the Flutter module launches instantly with zero lag.
- **"Show List of Movies" Button**: Presented on `MainViewController`.
- **Bidirectional Native Bridge**:
  - Registers `FlutterMethodChannel(name: "com.example.movies/bridge")`.
  - Listens for `openTrailer` with payload `{ movieId, title, overview, posterUrl, trailerKey }`.
  - Seamlessly dismisses the `FlutterViewController` and pushes/presents the native `TrailerViewController`.
- **Native Trailer Playback**:
  - `TrailerViewController` plays the YouTube trailer natively inside a clean `WKWebView` embed (`https://www.youtube.com/embed/{trailerKey}`).
  - Displays the movie title, metadata, and full overview below the player.
  - Includes a "Close" navigation action returning cleanly to `MainViewController`.

---

## 2. CocoaPods Integration

The app connects to the sibling `movies_flutter_module` repository using `podhelper.rb`:

```ruby
platform :ios, '14.0'
use_frameworks!

flutter_application_path = '../movies_flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'movies_ios_app' do
  install_all_flutter_pods(flutter_application_path)
end

post_install do |installer|
  flutter_post_install(installer) if defined?(flutter_post_install)
end
```

---

## 3. Setup and Running

### 3.1 Install CocoaPods Dependencies
From the `movies_ios_app` directory:
```bash
pod install
```

### 3.2 Open Xcode Workspace
```bash
open movies_ios_app.xcworkspace
```

### 3.3 Build and Run from CLI
Target the iPhone 17 Pro simulator:
```bash
xcodebuild -workspace movies_ios_app.xcworkspace \
           -scheme movies_ios_app \
           -configuration Debug \
           -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
           build
```

---

## 4. UI Tests

Run the native XCTest suite:
```bash
xcodebuild test \
           -workspace movies_ios_app.xcworkspace \
           -scheme movies_ios_app \
           -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

# SHALBAN SMART — Mobile App (Android & iOS)

Native-feeling Flutter WebView mobile application (`com.shalbantimber.smart`) wrapping `https://shalban-backend.onrender.com`.

## Features Included

- **Brand Theme**: Deep Forest Green (`#2E5A36`) primary color & Warm Cream (`#F7F5F0`) background across splash screen, status bar, progress bar, and offline state.
- **Persistent Login & Cookies**: JavaScript, DOM storage, database storage, and cookie persistence across app restarts (`CookieManager.flush()` on Android + `sharedCookiesEnabled: true` on iOS).
- **Camera & Gallery Uploads**: Supports `<input type="file">` camera capture and photo gallery uploads for custom furniture and wooden door orders (`CAMERA` permission on Android + `NSCameraUsageDescription` / `NSPhotoLibraryUsageDescription` on iOS).
- **External Link Routing**: Opens `tel:`, `wa.me`, `whatsapp:`, `mailto:`, and `sms:` links in native external apps via `url_launcher`.
- **Native Navigation & UX**:
  - Top-only pull-to-refresh (`PullToRefreshController`)
  - Top linear loading progress bar (`#2E5A36`)
  - Android hardware back button navigation through WebView history before exiting
  - Clean offline screen with a **Retry** button when internet is unavailable

## Cloud APK Build (GitHub Actions)

Push this repository to GitHub on `main` or `master` (or trigger **Build SHALBAN SMART Release APK** manually from the **Actions** tab). GitHub Actions uses `subosito/flutter-action@v2` to build `build/app/outputs/flutter-apk/app-release.apk` and uploads it as the downloadable `SHALBAN-SMART-release-apk` workflow artifact.

## Local Development

```bash
flutter pub get
flutter run
flutter build apk --release
```

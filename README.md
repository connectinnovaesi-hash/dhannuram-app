# Dhannuram Sweets & Restaurant (Flutter)

Zomato-style MVP: search, categories, menu list, item detail, cart, checkout stub, order tracking stub, 24x7 badge, call & directions buttons.

## Quick Start (Local)
1) Install Flutter SDK + Android Studio (SDK/Emulator).
2) In project folder:
```
flutter pub get
flutter run
```
### Build APK
```
flutter build apk --release
```
APK at: `build/app/outputs/flutter-apk/app-release.apk`

## One-click GitHub Actions (Recommended)
1) Push this folder to a new public repo.
2) Go to **Actions** → run **Build Android APK**.
3) After a few minutes, download artifact **dhannuram-release-apk**.

## Notes
- Replace `assets/logo.png` with your real logo.
- Update phone number in `HomeScreen` (`_dialNumber('+91-XXXXXXXXXX')`).
- Replace `restaurantLocation` with exact lat/lng.
- Replace dish images with your own (respect copyrights).

## Web Build (optional)
```
flutter config --enable-web
flutter build web
```
Deploy `build/web` to Netlify/Vercel/GitHub Pages.

# notes_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running with persistent web storage (dev)

By default `flutter run -d chrome` launches Chrome with a temporary profile so browser storage (used by the app) may be cleared between runs. To develop with persistent storage, run a web server and open the URL in your normal Chrome profile:

```powershell
cd 'C:\Users\jonat\Desktop\victoria INC\notes_app\notes_app'
flutter clean
flutter pub get
flutter run -d web-server
# Copy the printed URL (e.g. http://localhost:xxxx) and open it in your regular Chrome browser
```

To bind a specific host/port:

```powershell
flutter run -d web-server --web-hostname=localhost --web-port=5000
# Open http://localhost:5000 in your normal Chrome
```

## Build and deploy to GitHub Pages

Build the production web artifacts and deploy the `build/web` folder to GitHub Pages.

```powershell
cd 'C:\Users\jonat\Desktop\victoria INC\notes_app\notes_app'
flutter build web --web-renderer=canvaskit

# Option A: push build/web into gh-pages branch
cd build\web
git init
git checkout -b gh-pages
git add --all
git commit -m "Deploy Flutter web build"
git remote add origin https://github.com/USERNAME/REPO.git
git push --force origin gh-pages

# Option B: use subtree (from repo root)
# git subtree push --prefix build/web origin gh-pages
```

Notes:
- Storage is per-origin. Notes saved on `http://localhost:xxxx` will not appear on your GitHub Pages origin unless accessed from that published origin. Users' notes on the published site are stored in their own browser storage under the GitHub Pages origin.


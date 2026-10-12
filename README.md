# Learn - Smart Study App

Free, zero-budget Android study app for Pakistani students (Flutter).
Built from a phone: edit on GitHub, GitHub Actions builds the APK.

## Build
Push to `main` (or Actions > Build APK > Run workflow). The APK appears under Releases.
The `android/` folder is generated in CI, so it is not stored in the repo.

## Structure
- `lib/core/` theme (colors, light/dark) and reusable widgets
- `lib/features/<name>/` one folder per feature
- `PROJECT_STATE.md` current progress; paste it into a new chat to continue

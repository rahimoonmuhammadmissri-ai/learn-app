# Learn - Smart Study App

Free, zero-budget Android study app for Pakistani students (Flutter).
Built from a phone: edit on GitHub, GitHub Actions builds the APK.

## Build
Push to `main` (or Actions > Build APK > Run workflow). The APK appears under Releases.
The `android/` folder is generated in CI, so it is not stored in the repo.

## Structure
- `lib/core/` theme (colors, light/dark) and reusable widgets
- `lib/features/<name>/` one folder per feature
- `lib/features/books/` books_data (boards, catalog, verified sources), books_store (saved filters, downloads), screens
- `PROJECT_STATE.md` current progress; paste it into a new chat to continue

## Adding a book source
Only add links to official or properly licensed PDFs. Add the book id to `verifiedSources`
in `lib/features/books/books_data.dart` (see the example comment there).

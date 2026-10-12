# Learn - Smart Study App

Free, zero-budget Android study app for Pakistani students (Flutter).
Built from a phone: edit on GitHub, GitHub Actions builds the APK.

## Build
Push to `main` (or Actions > Build APK > Run workflow). The APK appears under Releases.
The `android/` folder is generated in CI. The workflow adds the INTERNET permission to the generated manifest.

## Structure
- `lib/core/` theme (colors, light/dark) and reusable widgets
- `lib/features/<name>/` one folder per feature
- `lib/features/books/`: books_data (verified catalog), books_store (filters, downloads), screens, pdf_reader_screen

## Books
Books come from the official STBB eBooks portal (https://portal.stbb.edu.pk/ebooks/). PDFs are NOT stored in this
repo or on any server of ours; the app downloads them from STBB to the user's phone.
A book is added to `catalog` only after its official detail page was opened and the "Download PDF" link copied from it.

## Packages
shared_preferences, path_provider, pdfrx (MIT, PDF reader). All free.

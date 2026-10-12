# PROJECT_STATE

## Rules
Zero budget. Flutter. Mobile-only workflow (GitHub web + Actions; upload project.zip, workflow unpacks it).
No fake data, links or progress. Do not rewrite working code. One phase at a time, wait for approval.
Packages: shared_preferences, path_provider (both free, official Flutter team).

## Done
Phase 1 (confirmed on phone): splash, onboarding, bottom nav, Home, Settings (theme), placeholders. Checkpoint: Release "Learn build 2".
Phase 2 (Books Library): code written, NOT yet confirmed building or tested on phone.
- Board > Class > Subject filters, search, book cards with generated covers, details screen, Library/Downloaded tabs.
- Filters saved across restarts. Download manager (dart:io, saves to app storage books/<id>.pdf, checks %PDF header).
- Catalog = 5 boards x classes 1-12 x subjects. Subject lists are general, edition/language not verified.

## Known limits
- NO verified PDF source added yet (search found only third-party sites). All books show "Source not added yet".
  Download code has therefore NOT been tested with a real file.
- Before the first real download: release APK needs the INTERNET permission (add a sed step to the workflow
  to insert <uses-permission android:name="android.permission.INTERNET"/> into AndroidManifest.xml).
- Theme and onboarding still not saved. Roman Urdu is a disabled placeholder.
- No PDF reader yet (separate phase). Covers are generated, not real images.

## Next (only after approval)
Verified sources for a few books, INTERNET permission step, then offline PDF reader phase.

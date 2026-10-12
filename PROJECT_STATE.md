# PROJECT_STATE

## Status
Phase 1 (UI design + app shell): code written, NOT yet confirmed building on CI.

## Rules
Zero budget. Flutter, no extra packages yet. Mobile-only workflow (GitHub web + Actions).
No fake data or fake progress. Do not rewrite working code. One phase at a time, wait for approval.

## Done (Phase 1)
Splash, onboarding, bottom nav (Home, Books, AI Lab, Tests, My Learning), Settings (theme works),
Books selection chips, placeholder/empty states, reusable widgets in lib/core/widgets.dart.

## Known limits
Theme and onboarding are not saved (shown every launch). Roman Urdu is a disabled placeholder.
Books, AI, tests, saved items are placeholders. Code not compiled by Claude (no Flutter in its sandbox).

## Next
1. Confirm Phase 1 APK builds and runs; fix any CI errors.
2. Phase 2: local storage (settings, onboarding flag).
3. Phase 3: books library and offline PDF reader.
Later: MCQs, notes, tests, tutor.

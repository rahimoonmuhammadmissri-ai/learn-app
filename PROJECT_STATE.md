# PROJECT_STATE

## Rules
Zero budget. Flutter. Mobile-only workflow (GitHub web + Actions; upload project.zip, workflow unpacks it).
No fake data, links or progress. Do not rewrite working code. One phase at a time, wait for approval.
Never call something tested unless it was tested on the phone. Do not delete old Releases (build-2 = Phase 1 checkpoint).
Do not upload official PDFs to our own server/GitHub.

## Done and confirmed on phone
Phase 1: splash, onboarding, bottom nav, Home, Settings (theme), placeholders.

## Phase 2 (built, install state not recorded here)
Books Library UI: filters, search, details, Library/Downloaded tabs, saved filters.

## Phase 3A (CODE WRITTEN, NOT BUILT OR TESTED YET)
- Catalog now holds ONLY verified real STBB books. Currently one: Math III, Class 3, English, 2024-25, official id 85.
  Page: portal.stbb.edu.pk/ebooks/book.php?id=85, download link copied from that page's "Download PDF" button.
- Generic fake entries for other boards removed. Board filters kept (other boards show "Not added yet").
- Filters: Board, Class (All, ECCE, 1-12), Medium (English/Urdu/Sindhi), Subject (from catalog). Saved across restarts.
- Statuses: Download, Downloading, Downloaded, Download failed, Unavailable.
- Download: dart:io stream to app storage books/<id>.pdf, %PDF header check, incomplete-size check, cancel.
- Reader: pdfrx PdfViewer.file (offline, from phone storage).
- Release APK needs INTERNET permission: added by the workflow (user must update build-apk.yml once).

## Not verified / known limits
- Download, reader and offline reading have NOT been tested with the real Math III file. The 30 MB limit seen earlier was
  Claude's fetch tool, not the app, but only the phone test can confirm large downloads work.
- pdfrx native build on CI is unverified. No resume for interrupted downloads. No last-read page yet.
- Portal counts: English 63, Sindhi 61, Urdu 69 (sum 193, from home-page class counts). Full title list NOT verified yet.
- Permission/policy for Play Store release is separate and still open (portal says "All rights reserved", no terms page found).

## Next (only after Math III passes the phone test)
Fetch all 39 listing pages (13 classes x 3 mediums incl. ECCE) and each detail page; add every verified book;
mark books without a working download button Unavailable. Only then call the total verified.

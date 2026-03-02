# Green Till Build Progress

Last updated: 2026-03-02 15:30:00 GMT

## Completed in this session

- Billing module upgraded with real in-app purchase flow (product loading, buy, restore, trial/pro gating)
  - `lib/ui/screens/billing/billing_screen.dart`
  - `pubspec.yaml` (`in_app_purchase`)
- Audit export upgraded to accounting package for firms:
  - single PDF report export
  - ZIP package with PDF + CSV + JSON + HTML + downloaded receipt/warranty attachments + README
  - `lib/ui/screens/auditreport/audit_report_screen.dart`
  - `pubspec.yaml` (`pdf`, `archive`)
- Android build config updated for store plugin compatibility
  - `android/app/build.gradle` (`compileSdkVersion` + `targetSdkVersion` = 36)
- MVP stabilization pass (receipts + login reliability):
  - Email/password sign-in no longer blocks when FCM token fetch fails (login proceeds with empty token fallback)
    - `lib/ui/screens/login/login_screen.dart`
  - Receipt upload submit is now guarded against double-taps and includes one automatic retry for transient network failures
    - `lib/ui/screens/qrloadedreceipt/upload_gallery_image.dart`
  - Gallery permission request flow improved for iOS/Android variants (photos first, storage fallback)
    - `lib/ui/screens/receipt/receipt_screen.dart`
  - OCR hydration wait window for just-uploaded receipts extended (4 -> 8 polls)
    - `lib/ui/screens/receipt/edit_receipt_screen.dart`
- MVP stabilization pass #2 (end-to-end reliability):
  - Added sign-in in-flight guard to prevent duplicate login submissions
    - `lib/ui/screens/login/login_screen.dart`
  - Added receipt-upload success validation (handles missing receipt id safely)
    - `lib/ui/screens/qrloadedreceipt/upload_gallery_image.dart`
  - Removed deferred gallery navigation race and added mounted-safe checks
    - `lib/ui/screens/receipt/receipt_screen.dart`
  - CSV export now handles empty month and file/share errors cleanly
    - `lib/ui/screens/auditreport/audit_report_screen.dart`
- MVP stabilization pass #3 (receipt edit + feedback hardening):
  - Receipt amount field now validates numeric decimal input and blocks invalid/zero amounts
    - `lib/ui/screens/receipt/edit_receipt_screen.dart`
  - Receipt edit now sends device timezone instead of a hardcoded timezone
    - `lib/ui/screens/receipt/edit_receipt_screen.dart`
  - OCR upload timeout increased to reduce false failures on large receipt images
    - `lib/repositories/UserRepository.dart`
  - Feedback submit now has in-flight guard to prevent duplicate submissions
    - `lib/ui/screens/receipt/feedback_receipt_screen.dart`
- MVP stabilization pass #4 (receipt pipeline data safety):
  - Hardened receipt list model parsing for null/invalid datetime payloads to avoid crashes during list/hydration flows
    - `lib/models/responses/getreceiptlist_response.dart`
  - Hardened OCR upload response parsing for string/int receipt IDs
    - `lib/models/responses/uploadgalleryornative_response.dart`
  - Receipt edit save now has in-flight guard to prevent duplicate updates
    - `lib/ui/screens/receipt/edit_receipt_screen.dart`
  - Feedback submit flow switched to awaited request with `try/finally` so loader and submit state always reset
    - `lib/ui/screens/receipt/feedback_receipt_screen.dart`
  - Login social button rendering now avoids `Platform.isIOS` checks on web runtime
    - `lib/ui/screens/login/login_screen.dart`
- MVP stabilization pass #5 (test unblockers + receipt-first UX):
  - Added one-tap **Demo Mode** login for QA/testing without backend account provisioning
    - `lib/repositories/UserRepository.dart`
    - `lib/ui/screens/login/login_screen.dart`
  - Sign-up and forgot-password now prevent duplicate submits (in-flight request guards)
    - `lib/ui/screens/signup/signup_screen.dart`
    - `lib/ui/screens/forgotpassword/forgot_password_screen.dart`
  - Backend SMTP exception handling hardened in repository responses with normalized user-facing messages
    - `lib/repositories/UserRepository.dart`
  - Home screen quick actions now prioritize receipt flow (Capture Receipt + Receipt History at top action row)
    - `lib/ui/screens/homepage/home_screen.dart`
  - Side menu now includes direct **Capture Receipt** entry point
    - `lib/ui/screens/sidemenu/side_menu.dart`

## Build output

- Android debug APK:
  - `build/app/outputs/flutter-apk/app-debug.apk`
  - `/Users/gurijala/Desktop/GreenTill-main-latest-debug.apk`
- Android release APK:
  - `build/app/outputs/flutter-apk/app-release.apk`
  - `/Users/gurijala/Desktop/GreenTill-main-latest-release.apk`
- Android release AAB (Play Store upload):
  - `build/app/outputs/bundle/release/app-release.aab`
  - `/Users/gurijala/Desktop/GreenTill-main-latest-release.aab`

## Current test blocker

- Backend SMTP credentials are still failing for sign-up/forgot-password (`javax.mail.AuthenticationFailedException 535`).
- App now surfaces a clean message and provides **Demo Mode** login so QA can continue without waiting on mail server fixes.

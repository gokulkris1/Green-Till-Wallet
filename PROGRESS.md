# Green Till Build Progress

Last updated: 2026-03-02 14:53:00 GMT

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

- Signup / forgot-password can fail with backend SMTP auth error (`javax.mail.AuthenticationFailedException 535`).
- App-side fix added: raw backend exception is now normalized to a clean user-facing message.
- This is a backend mail provider/auth issue and needs server credentials fix for full sign-up testing.

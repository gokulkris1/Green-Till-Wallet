# Green Till Build Progress

Last updated: 2026-03-02 13:07:00 GMT

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

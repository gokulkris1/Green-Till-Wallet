# Green Till Build Progress

Last updated: 2026-03-02 09:28:00 GMT

## Completed in this session

- Stabilized web preview bootstrap (separate entrypoint to avoid Firebase web crash)
  - `lib/main_preview.dart`
  - `tools/preview_web.sh`
- Receipt edit hydration for newly uploaded OCR receipts (auto-refill blank fields)
  - `lib/ui/screens/receipt/edit_receipt_screen.dart`
- Accounting-ready export package (CSV + JSON + HTML + receipt-links text)
  - `lib/ui/screens/auditreport/audit_report_screen.dart`
- Receipt dashboard KPIs (total/business/personal/in-progress)
  - `lib/ui/screens/receipt/receipt_screen.dart`

## Build output

- Android debug APK built successfully:
  - `build/app/outputs/flutter-apk/app-debug.apk`

## Current test blocker

- Signup / forgot-password can fail with backend SMTP auth error (`javax.mail.AuthenticationFailedException 535`).
- App-side fix added: raw backend exception is now normalized to a clean user-facing message.
- Practical testing workaround:
  - Main app APK: `/Users/gurijala/Desktop/GreenTill-latest-debug.apk`
  - UI preview APK (no backend auth dependency): `/Users/gurijala/Desktop/GreenTill-preview-debug.apk`

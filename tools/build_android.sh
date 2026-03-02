#!/usr/bin/env bash
set -euo pipefail

# Build Android app with explicit backend environment wiring.
# Examples:
#   tools/build_android.sh --debug
#   tools/build_android.sh --release --env=prod --api=https://api.greentill.co --host=api.greentill.co

FLUTTER_BIN="/Users/gurijala/Downloads/flutter/bin/flutter"
if [ ! -x "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

BUILD_MODE="debug"
ENV_NAME="staging"
API_BASE_URL="https://greentill-api.apps.openxcell.dev"
API_BASE_HOST="greentill-api.apps.openxcell.dev"

for arg in "$@"; do
  case "$arg" in
    --debug)
      BUILD_MODE="debug"
      ;;
    --release)
      BUILD_MODE="release"
      ;;
    --env=*)
      ENV_NAME="${arg#*=}"
      ;;
    --api=*)
      API_BASE_URL="${arg#*=}"
      ;;
    --host=*)
      API_BASE_HOST="${arg#*=}"
      ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

echo "Building Android ($BUILD_MODE) with env=$ENV_NAME api=$API_BASE_URL"
"$FLUTTER_BIN" build apk "--$BUILD_MODE" \
  --dart-define="GT_ENV=$ENV_NAME" \
  --dart-define="GT_API_BASE_URL=$API_BASE_URL" \
  --dart-define="GT_API_BASE_HOST=$API_BASE_HOST"

APK_PATH="build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
if [ -f "$APK_PATH" ]; then
  TARGET_PATH="/Users/gurijala/Desktop/GreenTill-$ENV_NAME-latest-$BUILD_MODE.apk"
  cp -f "$APK_PATH" "$TARGET_PATH"
  echo "Built: $APK_PATH"
  echo "Copied: $TARGET_PATH"
fi

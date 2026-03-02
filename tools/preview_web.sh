#!/usr/bin/env bash
set -euo pipefail

# Quick web preview for UI checks.
# Web-server is more reliable when Chrome debug service fails to attach.
FLUTTER_BIN="/Users/gurijala/Downloads/flutter/bin/flutter"
if [ ! -x "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

echo "Starting preview at http://127.0.0.1:8081 (target: lib/main_preview.dart)"
"$FLUTTER_BIN" run -d web-server --web-hostname=127.0.0.1 --web-port=8081 -t lib/main_preview.dart

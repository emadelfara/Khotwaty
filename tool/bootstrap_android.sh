#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
flutter create --platforms=android --org com.khotwaty --project-name khotwaty "$TMP/scaffold"
mkdir -p "$ROOT/android/gradle"
cp -R "$TMP/scaffold/android/gradle/." "$ROOT/android/gradle/"
cp "$TMP/scaffold/android/gradlew" "$ROOT/android/gradlew"
cp "$TMP/scaffold/android/gradlew.bat" "$ROOT/android/gradlew.bat"
chmod +x "$ROOT/android/gradlew"
echo "Android Gradle wrapper installed."

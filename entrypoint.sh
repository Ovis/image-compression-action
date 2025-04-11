#!/bin/bash
set -e

JPEG_MAX_QUALITY="${INPUT_JPEG_MAX_QUALITY:-80}"
JPEG_THRESHOLD="${INPUT_JPEG_COMPRESSION_THRESHOLD:-30}"
PNG_THRESHOLD="${INPUT_PNG_COMPRESSION_THRESHOLD:-30}"
BASE_BRANCH="${GITHUB_BASE_REF}"

git config --global --add safe.directory /github/workspace
git fetch origin "$BASE_BRANCH" --depth=1

CHANGED_FILES=$(git diff --name-only --diff-filter=ACMR "origin/$BASE_BRANCH"...HEAD)
ANY_COMPRESSED=false

while IFS= read -r file; do
  echo "Target file for processing: $file"

  if [[ "$file" == *.jpg || "$file" == *.jpeg || "$file" == *.png ]]; then
    ORIGINAL_SIZE=$(stat -c%s "$file")
    TMP_FILE="$(mktemp)"

    cp "$file" "$TMP_FILE"
    if [[ "$file" == *.jpg || "$file" == *.jpeg ]]; then
      jpegoptim --stdout --max="$JPEG_MAX_QUALITY" "$TMP_FILE" > "$TMP_FILE.out" 2>/dev/null
      mv "$TMP_FILE.out" "$TMP_FILE"
    elif [[ "$file" == *.png ]]; then
      optipng -o7 -quiet -out "$TMP_FILE" "$TMP_FILE" >/dev/null
    fi

    COMPRESSED_SIZE=$(stat -c%s "$TMP_FILE")
    SAVED_PERCENT=$(( (ORIGINAL_SIZE - COMPRESSED_SIZE) * 100 / ORIGINAL_SIZE ))

    if [[ "$file" == *.jpg || "$file" == *.jpeg ]]; then
      THRESHOLD=$JPEG_THRESHOLD
    else
      THRESHOLD=$PNG_THRESHOLD
    fi

    if (( SAVED_PERCENT >= THRESHOLD )); then
      echo "✅ $file can be compressed by ${SAVED_PERCENT}%, applying compression."
      cp "$TMP_FILE" "$file"
      ANY_COMPRESSED=true
    else
      echo "❎ $file compression would save only ${SAVED_PERCENT}%, skipping."
    fi

    rm -f "$TMP_FILE"
  else
    echo "Skipping non-image file: $file"
  fi
done <<< "$CHANGED_FILES"

echo "any_image_compressed=$ANY_COMPRESSED" >> "$GITHUB_OUTPUT"

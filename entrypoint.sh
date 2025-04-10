#!/bin/bash
set -e

MAX_QUALITY="${INPUT_MAX_QUALITY:-80}"
THRESHOLD="${INPUT_COMPRESSION_THRESHOLD:-30}"
BASE_BRANCH="${GITHUB_BASE_REF}"

# Git設定
git config --global --add safe.directory /github/workspace
git fetch origin "$BASE_BRANCH" --depth=1

CHANGED_FILES=$(git diff --name-only --diff-filter=ACMR "origin/$BASE_BRANCH"...HEAD)

ANY_COMPRESSED=false

while IFS= read -r file; do
  echo "Target file for processing: $file"
  if [[ "$file" == *.jpg || "$file" == *.jpeg || "$file" == *.png ]]; then
    echo "Processing file: $file"
    ORIGINAL_SIZE=$(stat -c%s "$file")
    if [[ "$file" == *.jpg || "$file" == *.jpeg ]]; then
      jpegoptim --max="$MAX_QUALITY" "$file"
    elif [[ "$file" == *.png ]]; then
      optipng "$file"
    fi
    COMPRESSED_SIZE=$(stat -c%s "$file")
    if (( (ORIGINAL_SIZE - COMPRESSED_SIZE) * 100 / ORIGINAL_SIZE >= THRESHOLD )); then
      echo "$file compressed by more than ${THRESHOLD}%"
      ANY_COMPRESSED=true
    else
      echo "$file was not compressed by ${THRESHOLD}% or more."
    fi
  else
    echo "Skipping non-image file: $file"
  fi
done <<< "$CHANGED_FILES"

echo "any_image_compressed=$ANY_COMPRESSED" >> $GITHUB_OUTPUT

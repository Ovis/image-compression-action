# Image Compression Action

## Overview
Compresses only images modified in a GitHub Pull Request that achieve a specified minimum reduction rate.
Images that do not meet the threshold will be skipped to avoid unnecessary changes.

## Input Parameters

| Parameter Name                | Description                                                             | Default      |
|-------------------------------|-------------------------------------------------------------------------|--------------|
| `jpeg_max_quality`            | Maximum quality setting for JPEG images (1–100)                         | `80`         |
| `jpeg_compression_threshold`  | Minimum compression ratio (%) required for JPEG images to be compressed | `30`         |
| `png_compression_threshold`   | Minimum compression ratio (%) required for PNG images to be compressed  | `30`         |

## Output

| Output Name            | Description                                                                       |
|------------------------|-----------------------------------------------------------------------------------|
| `any_image_compressed` | Returns `true` if at least one image was compressed above the specified threshold |

## Usage
```yaml
- name: Compress Images
  uses: Ovis/image-compression-action@main
  with:
    jpeg_max_quality: "80"              # JPEG image quality (1–100, default is 80)
    jpeg_compression_threshold: "30"    # Minimum compression rate (%) for JPEG images to be processed (default: 30)
    png_compression_threshold: "30"     # Minimum compression rate (%) for PNG images to be processed (default: 30)
```

## Example Workflow
```yaml
name: Image Compression on PR

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: write

jobs:
  compress-images:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Compress Images
        id: compress
        uses: Ovis/image-compression-action@main
        with:
          jpeg_max_quality: "80"
          jpeg_compression_threshold: "5"
          png_compression_threshold: "40"

      - name: Commit compressed images
        uses: EndBug/add-and-commit@v4
        if: steps.compress.outputs.any_image_compressed == 'true'
        with:
          message: 'Compress images'
          default_author: github_actions
```

## Licence

[MIT License](./LICENSE)
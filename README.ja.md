# Image Compression Action

## 概要
GitHub Pull Request内で変更された画像について、指定した圧縮率以上のサイズ削減が達成される画像だけ圧縮します。

## 入力パラメータ一覧

| パラメータ名                  | 説明                                                         | デフォルト値 |
|-------------------------------|--------------------------------------------------------------|--------------|
| `jpeg_max_quality`            | JPEG画像の最大画質（1～100）                                 | `80`         |
| `jpeg_compression_threshold`  | JPEG画像を圧縮するか判断するための最小圧縮率（%）            | `30`         |
| `png_compression_threshold`   | PNG画像を圧縮するか判断するための最小圧縮率（%）             | `30`         |

## 出力

| 出力名                 | 説明                                                                      |
|------------------------|---------------------------------------------------------------------------|
| `any_image_compressed` | 指定した閾値を超えて圧縮された画像が1つ以上あった場合は `true` を返します |


## 使用方法
```yaml
- name: Compress Images
  uses: Ovis/image-compression-action@main
  with:
    jpeg_max_quality: "80"           # JPEG画像の圧縮率 (1-100の範囲で指定、デフォルトは80)
    jpeg_compression_threshold: "30"    # JPEG画像の圧縮対象とする最小の圧縮率（デフォルトは30%）
    png_compression_threshold: "30"    # PNG画像の圧縮対象とする最小の圧縮率（デフォルトは30%）
```

## ワークフロー記載例
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

## ライセンス

[MIT License](./LICENSE)
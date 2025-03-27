# Image Compression Action

## 概要
GitHub Pull Request内で変更された画像を自動で圧縮し、指定した圧縮率以上のサイズ削減が達成された場合に自動でコミット、プッシュします。

## 使用方法
```yaml
- name: Compress Images
  uses: Ovis/image-compression-action@main
  with:
    max_quality: "80"           # JPEG画像の圧縮率 (1-100)
    compression_threshold: "30"    # コミットする最小の圧縮率
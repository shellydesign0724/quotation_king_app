#!/bin/bash
set -e

# 1. 確保在 main 分支
git checkout main

# 2. Build Flutter Web，指定 base href
flutter build web --base-href "/quotation_king_app/"

# 3. 複製 build/web 到暫存資料夾
TMP_DIR="/tmp/web_dist_$$"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cp -r build/web/* "$TMP_DIR/"

# 4. 切到 gh-pages 分支
git checkout gh-pages

# 5. 清空所有檔案（不包含 .git）
find . -maxdepth 1 ! -name '.git' ! -name '.' -exec rm -rf {} +

# 6. 複製暫存資料夾內容到根目錄
cp -r "$TMP_DIR"/* .

# 7. git 操作
git add .
git commit -m "Auto deploy to GitHub Pages with correct base href" || echo "No changes to commit"
git push -f origin gh-pages

# 8. 回到 main 分支
git checkout main

# 9. 刪除暫存資料夾
rm -rf "$TMP_DIR"

echo "✅ 部署完成！請至 https://shellydesign0724.github.io/quotation_king_app/ 查看" 
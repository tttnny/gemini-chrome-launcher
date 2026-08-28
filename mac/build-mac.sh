#!/bin/bash
# =============================================================================
#  Gemini Chrome Launcher - macOS 一键构建脚本
#  作用：生成 "Gemini Chrome.app" 启动包装器（默认 /Applications，
#        写不进则回退 ~/Applications），双击它即以完整 Glic 参数启动 Chrome。
#  用法：bash build-mac.sh
# =============================================================================
set -e

SRC="$(cd "$(dirname "$0")" && pwd)"

# 默认安装到 /Applications；若系统对该目录限制（少数 Sequoia 环境），回退用户目录
if [ -d /Applications ] && [ -w /Applications ]; then
    DEST="/Applications/Gemini Chrome.app"
else
    DEST="$HOME/Applications/Gemini Chrome.app"
fi

echo "构建目标: $DEST"
mkdir -p "$DEST/Contents/MacOS" "$DEST/Contents/Resources"

cp "$SRC/Gemini Chrome.app/Contents/Info.plist"   "$DEST/Contents/Info.plist"
cp "$SRC/Gemini Chrome.app/Contents/MacOS/run.sh" "$DEST/Contents/MacOS/run.sh"
chmod +x "$DEST/Contents/MacOS/run.sh"

# 图标：优先使用仓库内置的 Gemini 图标；本机装有 Chrome 时回退复用其图标
if [ -f "$SRC/Gemini Chrome.app/Contents/Resources/app.icns" ]; then
    cp "$SRC/Gemini Chrome.app/Contents/Resources/app.icns" "$DEST/Contents/Resources/app.icns"
    echo "图标: 使用内置 Gemini 图标"
elif [ -f "/Applications/Google Chrome.app/Contents/Resources/app.icns" ]; then
    cp "/Applications/Google Chrome.app/Contents/Resources/app.icns" "$DEST/Contents/Resources/app.icns"
    echo "图标: 已复用本机 Chrome 图标"
fi

# ad-hoc 签名，保证双击可运行
codesign --force --sign - "$DEST"

echo ""
echo "✅ 完成: $DEST"
echo ""
echo "使用方法:"
echo "  1. 把它拖到 Dock，顶替原 Chrome 图标的位置"
echo "  2. 先 Cmd+Q 完全退出 Chrome，再点它启动（参数只对全新进程生效）"

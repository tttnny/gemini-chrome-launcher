#!/bin/bash
# =============================================================================
#  Gemini Chrome Launcher - macOS 一键构建脚本
#  作用：在 ~/Applications 下生成 "Gemini Chrome.app" 启动包装器，
#        双击它即以完整 Glic 参数启动 Chrome，规避 Sequoia 只读系统卷限制。
#  用法：bash build-mac.sh
# =============================================================================
set -e

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Applications/Gemini Chrome.app"

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

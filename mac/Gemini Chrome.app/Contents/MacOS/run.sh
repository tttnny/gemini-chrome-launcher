#!/bin/bash
# Gemini Chrome 启动器：带完整 Glic 参数启动 Chrome
# 注意：若 Chrome 已在运行，参数不会生效，必须先完全退出。
if pgrep -x "Google Chrome" >/dev/null 2>&1; then
  osascript -e 'display alert "请先完全退出 Chrome" message "Gemini Chrome 需要全新的 Chrome 进程才能加载参数。
请先按 Cmd+Q 完全退出 Chrome，然后再打开本应用。" as critical buttons {"好"}'
  exit 1
fi
# 不传 --lang：Glic 可用性与界面语言无关（实测 --lang=zh-CN 与 en-US 等效），
# 因此界面语言交由用户自己的 Chrome 设置决定。
exec /usr/bin/open -a "Google Chrome" --args \
  --variations-override-country=us \
  --enable-features=Glic,GlicSidePanel,GlicButton,GlicWarming,GlicZeroStateSuggestions

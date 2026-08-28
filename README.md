# Gemini Chrome Launcher

为 Chrome 的 **Gemini 侧边栏（Glic）** 提供「一键启动包装器」，解决"图标能出现但侧边栏显示地区不可用"的问题。

## 为什么需要这个项目

Chrome 的 Gemini 侧边栏可用性由**服务端 variations 判定**控制，普通启动时 Chrome 重新向服务端确认，本地修改的配置文件会在启动时被覆盖回滚。唯一可靠的方式是**带启动参数强制覆盖**：

```
--lang=en-US \
--variations-override-country=us \
--enable-features=Glic,GlicSidePanel,GlicButton,GlicWarming,GlicZeroStateSuggestions
```

但参数只能通过命令行传入，两个平台各有一个障碍：

| 平台 | 障碍 |
|---|---|
| macOS 15+ (Sequoia) | `/Applications` 被挂载为**只读系统卷**（`apfs, sealed, read-only`），root 也无法修改 Chrome 本体持久化参数 |
| Windows | 无直接障碍，但需要手动处理快捷方式/批处理 |

本仓库把参数包装成**独立启动器**（macOS 应用 / Windows 批处理+快捷方式），无需修改 Chrome 本体。

## macOS 使用

```bash
bash mac/build-mac.sh
```

脚本会在 `~/Applications/` 生成 `Gemini Chrome.app`（内置 Gemini 星星图标，图标素材来自 Google 官方 `gstatic.com` 资源）：

1. 把它拖到 Dock，顶替原 Chrome 图标位置
2. **先 Cmd+Q 完全退出 Chrome**，再点它启动（参数只对全新进程生效，Chrome 已运行时点击会弹窗提醒）

## Windows 使用

方式一（批处理，直接运行）：

```
win/start-gemini-chrome.cmd
```

方式二（桌面快捷方式，更接近原生体验）：

```powershell
powershell -ExecutionPolicy Bypass -File win/install-shortcut.ps1
```

两种方式都会：自动检测 Chrome 路径 → 检测 Chrome 是否在运行（在运行则提示先退出）→ 带参数启动。

## 仍然显示"地区不可用"？

启动参数只解决**本地 variations 层**的判定。若侧边栏内容层仍报不可用，说明**服务端按出口 IP 质量判定**拒绝了：

```bash
# 检查当前出口 IP 是否为住宅 IP
curl -s "http://ip-api.com/json/?fields=query,country,city,proxy,hosting,isp"
```

- `"proxy": false` 且 `"hosting": false` → 合格（住宅宽带）
- `"proxy": true` 或 `"hosting": true`（机房 IP，如 HostPapa/ColoCrossing/Vultr/AWS）→ 需换**住宅 IP** 的美国节点，网页版 Gemini 对此不敏感所以能正常使用

## 常见问题

- **为什么必须先退出 Chrome？** Chrome 是单实例进程，已有实例运行时新参数会被丢弃、只激活现有窗口。
- **语言必须英文吗？** 不需要。界面语言与 Glic 可用性无关（旧教程要求 en-US 是早期版本行为）。
- **本地字段修改为什么没用？** `variations_country`、safe seed 等字段会在 Chrome 启动时被服务端判定覆盖，参数强制覆盖是唯一可靠手段。

## 免责声明

本工具仅通过 Chrome 公开的启动参数启用内置实验功能，不涉及破解或侵权。功能可用性受 Google 服务端地区/账号策略约束，请自行遵守当地法律法规与 Google 服务条款。

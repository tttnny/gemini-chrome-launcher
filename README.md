# Gemini Chrome Launcher

为 Chrome 的 **Gemini 侧边栏（Glic）** 提供「一键启动包装器」，解决"图标能出现但侧边栏点不开 / 显示地区不可用"的问题。

## 为什么需要这个项目

Chrome 的 Gemini 侧边栏可用性由**服务端 variations 判定**控制。普通启动时 Chrome 会向服务端重新确认，**本地修改的配置文件会在启动时被覆盖回滚**。

唯一可靠的方式是**在启动参数里强制覆盖**，让 Chrome 在向服务端上报之前就带上美国地区：

```
--variations-override-country=us \
--enable-features=Glic,GlicSidePanel,GlicButton,GlicWarming,GlicZeroStateSuggestions
```

但参数只能通过命令行传入，两个平台各有一个障碍：

| 平台 | 障碍 |
|---|---|
| macOS 15+ (Sequoia) | `/Applications` 被挂载为**只读系统卷**（`apfs, sealed, read-only`），root 也无法修改 Chrome 本体持久化参数 |
| Windows | 无直接障碍，但需要手动处理快捷方式/批处理 |

本仓库把参数包装成**独立启动器**（macOS 应用 / Windows 批处理+快捷方式），无需修改 Chrome 本体。

---

## 实测证据

以下数据来自 Windows / Chrome `153.0.8010.37`，读取 `Local State` 中 `profile.info_cache.Default.is_glic_eligible` 字段：

| 启动方式 | `is_glic_eligible` | 侧边栏表现 |
|---|---|---|
| 普通启动（无参数） | `false` | 图标可见，点击无反应 |
| 本仓库启动器 | `true` | 正常打开 |

这条对比同时解释了**为什么"改本地配置文件"的方案是无效的**：

`is_glic_eligible` 是 Chrome 从**账号服务端拉取**的账号信息节点（与 `gaia_id`、`gaia_name`、`user_name` 同级，位于 `profile.info_cache.Default`）。在本地把它改成 `true` 之后，Chrome 一联网就会被服务端结果**覆写回去**。

启动参数之所以可靠，是因为它们在**服务端下发判定之前**就已经生效了。

> 相关：同作者的 [`gemini-in-chrome-enabler`](https://github.com/tttnny/gemini-in-chrome-enabler) 用的正是"改本地文件"的思路，因此已失效。该仓库已标记为废弃。

---

## ⚠️ 关于界面语言（重要修正）

**Glic 可用性与浏览器界面语言无关。本仓库的启动器不传入 `--lang`**，Chrome 会保持你原有的界面语言。

这是实测结论，不是推测：

| 启动参数 | `is_glic_eligible` | 侧边栏 |
|---|---|---|
| `--lang=en-US` | `true` | 正常 |
| `--lang=zh-CN` | `true` | 正常，界面为中文 |

早期教程（以及本仓库早期版本）要求"必须把界面和账号语言改成英文"，那是旧版 Chrome 的行为，现在已不再需要。

如果你的 Chrome 界面被历史工具改成了英文，可在 `chrome://settings/languages` 改回中文。

---

## macOS 使用

```bash
bash mac/build-mac.sh
```

脚本默认生成到 `/Applications/Gemini Chrome.app`（若系统对该目录有限制则自动回退到 `~/Applications/`）。应用内置官方彩色 Gemini 图标：

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

> **Windows 脚本为什么是纯英文（ASCII）？**
> `cmd.exe` 按 OEM 代码页**逐字节**解析批处理文件，非 ASCII 字符可能被解码成 `|`、`&`、`>` 等元字符，把命令行拆断、导致启动命令被静默跳过。同类问题在同作者的 `gemini-in-chrome-enabler` 仓库中**已真实导致 `.bat` 完全无法执行**。请不要往这些文件里加中文。

---

## 关于出口 IP（重要修正）

本仓库早期版本文档写过"必须是住宅 IP，机房 IP 会导致地区不可用"，并点名 HostPapa。**这个判断过强，已被实测推翻：**

- 实测出口：`AS36352 HostPapa`，`ip-api` 返回 `proxy: true`、`hosting: true`
- 实测结果：功能**完全正常**

因此机房 IP **不是**硬性阻断条件。如果侧边栏确实报"地区不可用"，请按下面顺序排查，出口 IP 只是**次要因素**：

1. 是否通过本启动器启动（而不是任务栏/开始菜单的普通图标）
2. 启动前 Chrome 是否**已完全退出**（Chrome 是单实例进程，已有实例会丢弃新参数）
3. Chrome 版本是否足够新（实测 `153` 可用）

---

## 常见问题

- **为什么必须先退出 Chrome？** Chrome 是单实例进程，已有实例运行时新参数会被丢弃，只会激活现有窗口。
- **语言必须英文吗？** 不需要，见上文「关于界面语言」。
- **本地字段修改为什么没用？** `variations_country`、`is_glic_eligible` 等字段会在 Chrome 启动时被服务端判定覆盖，参数强制覆盖才是可靠手段。
- **重启电脑后需要重跑吗？** 不需要。只要你始终用启动器（或快捷方式）启动 Chrome，参数每次都会带上。

---

## 免责声明

本工具仅通过 Chrome 公开的启动参数启用内置实验功能，不涉及破解或侵权。

功能可用性受 Google 服务端地区/账号策略约束，**使用可能违反 Google 服务条款**（`--variations-override-country` 的实质是向服务端上报一个与你实际所在地不同的地区），风险（如账号风控、功能被收回）由使用者自行承担。请遵守当地法律法规，并建议不要用重要主账号尝试。

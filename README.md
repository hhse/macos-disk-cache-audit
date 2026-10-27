# macOS Disk Cache Audit

一个用于 Codex 的 macOS 磁盘诊断与安全清理 Skill。它先盘点空间、识别缓存和数据，再按风险分类，只在你明确确认后删除可重建缓存。

它不会把“帮我看看硬盘”误当成“全部删掉”，也不会建议整目录清空 `Application Support`、聊天数据、模拟器或用户文件。

## 能做什么

- 检查整盘已用/可用空间。
- 定位 Xcode、CoreSimulator、npm、uv、Homebrew 等常见开发缓存。
- 区分可重建缓存、条件性缓存、用户数据和系统保护项目。
- 检查 Xcode、Simulator 和模拟器运行状态。
- 生成包含大小、风险、后果的清理清单。
- 在获得明确授权后，只删除已核对的绝对路径，并复查实际释放空间。

## 安全原则

| 级别 | 行为 |
|---|---|
| 只读诊断 | 默认模式，只统计目录大小 |
| 可重建缓存 | 用户确认后可删除；首次使用会变慢或重新下载 |
| 条件性缓存 | 需要确认对应工具或设备不再使用 |
| 用户数据 | 不当作“垃圾”；必须单独确认具体内容 |
| 系统保护 | 不静默使用 `sudo`，交给用户决定是否授权 |

详细路径判断见 [`references/risk-catalog.md`](references/risk-catalog.md)。

## 安装

```bash
git clone https://github.com/hhse/macos-disk-cache-audit.git \
  ~/.codex/skills/macos-disk-cache-audit
```

如果目录已存在，请先自行确认旧版本，再更新或替换。

## 使用

在 Codex 中显式调用：

```text
Use $macos-disk-cache-audit to inspect this Mac and propose a safe cleanup plan.
```

也可以直接用自然语言：

```text
帮我看看硬盘有哪些缓存垃圾可以删掉，先别删除。
```

单独运行只读审计脚本：

```bash
bash ~/.codex/skills/macos-disk-cache-audit/scripts/audit-disk.sh
```

需要查看 Home 顶层占用时：

```bash
bash ~/.codex/skills/macos-disk-cache-audit/scripts/audit-disk.sh --deep
```

脚本只读取空间和目录大小，不读取文件内容，不联网，不删除文件。

## 清理流程

1. 生成只读清单和当前可用空间。
2. 检查应用、Xcode 和模拟器状态。
3. 按 `REGENERABLE`、`CONDITIONAL`、`USER DATA`、`SYSTEM-PROTECTED` 分类。
4. 用户确认具体范围。
5. 使用精确绝对路径删除，禁止通配符和宽泛父目录。
6. 复查目标是否消失以及实际释放空间。

缓存被删除后无法恢复原文件，但通常可以由对应工具重新生成。首次打开 Xcode、启动模拟器、安装依赖时可能更慢。

## 仓库结构

```text
.
├── SKILL.md
├── agents/openai.yaml
├── references/risk-catalog.md
├── scripts/audit-disk.sh
├── DISCLAIMER.md
├── SECURITY.md
└── LICENSE
```

## 兼容性

主要面向 macOS，重点覆盖 Xcode、iOS Simulator 和常见 JavaScript/Python 开发缓存。其他工具的路径可以由审计脚本和 Skill 的风险判断继续扩展。

## 声明

本项目按“现状”提供，不承诺清理一定安全、不会误删或一定能释放指定空间。执行任何删除前，请先备份重要数据并核对目标路径。完整说明见 [`DISCLAIMER.md`](DISCLAIMER.md)。

本项目与 Apple、OpenAI、GitHub 无隶属或背书关系。

## License

[MIT](LICENSE)

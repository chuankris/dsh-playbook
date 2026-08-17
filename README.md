# dsh-playbook

让 DeepSeek Harness（DSH）越用越好用的配置与经验沉淀仓库。

- `presets/`：Agent preset（当前含"辩论模式"）
- `host-patch/`：机器本地 host patch（挂载 Codex / Claude Code 两个产品子代理 provider）
- `docs/`：使用经验、踩坑记录、方案沉淀
- `setup.sh`：换机器一键部署

## 快速开始（新机器）

```bash
git clone https://github.com/chuankris/dsh-playbook.git
cd dsh-playbook
./setup.sh
```

`setup.sh` 会：

1. 把 `presets/debate/` 安装到 `~/.dsh/.agent-presets/debate/`
2. 把 `host-patch/cordis.patch.yml` 安装到 `~/.dsh/cordis.patch.yml`
3. 检查依赖：`dsh`、`codex` CLI、`claude` CLI、`ffmpeg`、Node.js
4. 检查 DeepSeek API Key（`~/.dsh/.credentials.yaml`），缺失则提醒配置

完成后启动：

```bash
dsh web
```

在 Web UI 里选择 **辩论模式** preset，即可复现多模型子代理互评流程。

## 目录结构

```text
dsh-playbook/
  presets/debate/
    agent.cordis.yml   # 辩论模式 preset 主体（标准模式 + Codex/Claude 子代理工具）
    preset.yml         # preset 元数据
  host-patch/
    cordis.patch.yml   # 挂载 subagent-codex / subagent-claude-code，并把 Claude 路由到 DeepSeek 端点
  docs/                # 经验文档
  setup.sh             # 一键部署
```

## 安全须知

- API Key **绝不**进入本仓库。每台机器在本地 `~/.dsh/.credentials.yaml` 配置一次。
- `host-patch/cordis.patch.yml` 通过 `!!js` 从 `~/.dsh/.credentials.yaml` 读取 Key，不硬编码。

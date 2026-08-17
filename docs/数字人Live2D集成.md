# 数字人（Live2D）集成方案

给竖版视频右上角叠加一个 Live2D 数字人讲解员，口型随旁白同步。纯本地渲染，无需 GPU / 云端 / 真人素材。

## 技术栈

- `pixi.js@6` + `pixi-live2d-display@0.4.0`（cubism4）
- Live2D Cubism Core 运行时 `live2dcubismcore.min.js`
- 模型：Haru / Hiyori（`*.moc3` + 纹理 + 表情 + 动作）
- Playwright 无头 Chromium 截透明帧，ffmpeg 合成

## 集成流程

```
Live2D 模型 (.moc3 + 纹理 + cubism core)
  → render.html（Pixi 透明背景渲染，window.__setMouth 驱动口型）
  → capture_synced.py（Playwright 逐帧截透明 PNG，按 mouth_timeline.json 驱动）
  → ffmpeg overlay 到视频右上角
```

## 关键命令

```bash
# 逐帧截透明数字人（25fps）
python3 capture_synced.py

# 叠加到视频右上角（PNG 序列直接 overlay，避免中间 alpha 编码丢失）
ffmpeg -y -i base.mp4 -framerate 25 -i synced/s%04d.png \
  -filter_complex "[1:v]scale=250:-1[av];[0:v][av]overlay=W-w-40:165:shortest=1[v]" \
  -map "[v]" -map 0:a -c:v libx264 -crf 18 -preset medium -pix_fmt yuv420p -c:a copy out.mp4
```

## 踩坑记录

1. `file://` 下 ES module import 被 CORS 阻止 → 必须本地 HTTP 服务（`python3 -m http.server 8765`）。
2. pixi.js 6 的 esm 入口内部用 bare import `@pixi/*` → 改用 UMD 单文件 `dist/browser/pixi.min.js`。
3. ffmpeg 编 webm/vp9 默认丢 alpha → 在 overlay 阶段直接用 PNG 序列 + loop 滤镜，绕过中间有损编码。
4. playwright 版本与 chromium 缓存版本要匹配，否则用 `executable_path` 指定。
5. `page.screenshot(omit_background=True)` 才能得到透明背景帧。
6. 口型：`ParamMouthOpenY` 参数，逐句时间轴驱动张合（简单版）；音素级唇形是进阶版。

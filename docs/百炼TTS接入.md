# 阿里云百炼 TTS 接入（qwen-audio-3.0-tts-plus）

## 结论（已实测跑通）

- 端点：`POST https://token-plan.cn-beijing.maas.aliyuncs.com/api/v1/services/audio/tts/SpeechSynthesizer`
- 鉴权：`Authorization: Bearer <Token Plan API Key>`（`sk-sp-...` 前缀的 Token Plan 专用 key）
- 模型：`qwen-audio-3.0-tts-plus`，音色：`longanlingxin`（女声温暖）/ `longanlufeng`（男声）
- 返回：JSON，含 `output.audio.url`（http 临时地址，需立即下载）

## 最小示例（Python）

```python
import requests
resp = requests.post(
    "https://token-plan.cn-beijing.maas.aliyuncs.com/api/v1/services/audio/tts/SpeechSynthesizer",
    headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
    json={"model": "qwen-audio-3.0-tts-plus",
          "input": {"text": "你好，这是测试。", "voice": "longanlingxin",
                    "format": "wav", "sample_rate": 24000}},
    timeout=120,
)
resp.raise_for_status()
audio_url = resp.json()["output"]["audio"]["url"]
# 立即下载 audio_url
```

## 踩坑记录

1. **端点别用错**：Token Plan 的 TTS 走 `token-plan.cn-beijing.maas.aliyuncs.com`，不是 `dashscope.aliyuncs.com`。之前用标准 DashScope 端点一直 401，换对端点就通了。
2. **key 类型**：`sk-sp-` 前缀是 Token Plan 专用 key，不是标准百炼 key（`sk-`）。两者端点也不同，别混用。
3. **临时地址会过期**：`output.audio.url` 拿到就下载，别当永久地址存。
4. **长文本分句**：逐句合成，句间加停顿，避免一次发全文超时。
5. **时长控制**：正常语速下约 4.5 字/秒。若超目标时长，可在 `input` 加 `"rate": 1.1~1.2` 统一提速（每句一致）。

## 参考

完整说明见本地文档 `阿里云百炼-Token-Plan-TTS调用说明.md`（由用户提供）。

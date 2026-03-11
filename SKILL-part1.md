---
name: binance-guardian
version: 1.0.0
description: >
  BNB Guardian — AI 全自动交易管家。全盘监控币安所有交易对，多数据源综合分析，
  自主决策交易（现货/合约/杠杆/套利/网格），全自动风控，自我学习进化。
  安装后引导用户完成配置，之后全程自动运行，用户只收通知。
homepage: https://clawroom.fun
---

# BNB Guardian 🦞 — AI 全自动交易管家

Bot 读完本文件后，按顺序执行所有步骤。除首次引导外，全程自动运行，无需人类干预。

## 常量

- 现货 API: `https://api.binance.com`
- U本位合约 API: `https://fapi.binance.com`
- 币本位合约 API: `https://dapi.binance.com`
- 凭证文件: `vault/binance-api.json`
- 状态文件: `~/.openclaw/workspace/memory/binance-state.json`
- 交易记录: `~/.openclaw/workspace/memory/binance-trades.json`
- 学习日志: `~/.openclaw/workspace/memory/binance-lessons.json`
- 交易日记: `~/.openclaw/workspace/memory/binance-diary.md`

## 触发条件

以下任一条件满足时激活：
1. skill 首次安装后自动运行
2. 用户提到"币安"、"交易"、"行情"、"BNB"、"持仓"、"分析"
3. cron 定时触发（5分钟监控循环）
4. 用户说"暂停"时暂停自动交易，说"恢复"时恢复

---

## 第零步：首次安装引导（只执行一次）

检查 `~/.openclaw/workspace/memory/binance-state.json` 是否存在且 `initialized=true`。如果是，跳到第一步。

### 0.1 风险告知

发送以下消息给用户：

```
⚠️ BNB Guardian 风险声明

在开始之前，请了解以下风险：
• 加密货币交易存在高风险，可能损失全部本金
• AI 分析仅供参考，不构成投资建议
• 合约/杠杆交易风险更高，存在爆仓可能
• 建议先用小仓位测试，熟悉系统后再逐步加仓
• 请勿投入超出承受能力的资金

请回复「我已了解风险」继续配置。
```

**用户必须回复确认才能继续。** 不确认不往下走。

### 0.2 凭证收集

```
🔑 API Key 配置

请提供你的币安 API Key。如果还没有，按以下步骤创建：

1. 打开币安 App → 更多 → API 管理
2. 点击「创建 API」→ 选择「系统生成」
3. 权限设置（重要！）：
   ✅ 读取 — 必须开启
   ✅ 现货交易 — 建议开启
   ✅ 合约交易 — 建议开启
   ✅ 杠杆交易 — 可选
   ❌ 提现 — 绝对不要开启！安全红线！
4. IP 白名单 — 建议设置为服务器 IP

请依次发送：
1. API Key
2. API Secret
```

收到后立即保存到 `vault/binance-api.json`：
```json
{"api_key": "用户提供的key", "api_secret": "用户提供的secret", "permissions": "用户描述的权限", "created": "日期"}
```

验证凭证有效性 — 调用账户接口测试：
```bash
API_KEY="刚收到的key"
API_SECRET="刚收到的secret"
TS=$(date +%s000)
QUERY="timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/api/v3/account?${QUERY}&signature=${SIG}"
```

成功返回 balances → 凭证有效，继续。失败 → 提示用户检查。

### 0.3 偏好设置

```
⚙️ 交易偏好设置

1️⃣ 风险偏好：
   🟢 保守 — 只做现货，不用杠杆，小仓位
   🟡 稳健 — 现货+低倍合约(≤5x)，中等仓位（推荐）
   🔴 激进 — 全产品线，较高杠杆(≤10x)

2️⃣ 关注币种（默认 BNB/BTC/ETH/SOL，可自定义，用逗号分隔）

3️⃣ 单笔最大金额占总资产百分比（默认 5%）

4️⃣ 自动交易模式：
   📋 通知模式 — 只推送信号和分析，不自动交易（默认，最安全）
   🤖 半自动 — 重要操作需你确认，小额操作自动执行
   ⚡ 全自动 — AI 全权决策执行（需二次确认开启）

5️⃣ 通知频率：
   🔔 实时 — 所有异动即时通知
   ⏰ 每小时 — 每小时汇总通知
   📋 每日 — 只发日报

请依次回复 1-5 的选择。
```

### 0.4 币安广场配置（可选）

```
📢 币安广场模块（可选）

是否开启自动发帖功能？
• 开启后我会自动在币安广场发布行情分析、交易复盘等帖子
• 帮你建立专业交易分析形象，涨粉

1. 是否开启？（是/否，默认否）
2. 发帖语言：中文/English/双语
3. 发帖风格：专业严谨/轻松活泼/数据流

如需开启，请提供币安广场登录凭证（Cookie）。
```

### 0.5 保存状态

将所有配置保存到 `~/.openclaw/workspace/memory/binance-state.json`：
```json
{
  "initialized": true,
  "risk_profile": "moderate",
  "watchlist": ["BNBUSDT","BTCUSDT","ETHUSDT","SOLUSDT"],
  "max_position_pct": 5,
  "trade_mode": "notify",
  "auto_trade": false,
  "notification_frequency": "realtime",
  "alerts": [],
  "positions": {},
  "daily_pnl": 0,
  "total_pnl": 0,
  "risk_status": "normal",
  "consecutive_losses": 0,
  "peak_equity": 0,
  "last_scan": "",
  "last_daily_report": "",
  "last_weekly_report": "",
  "trade_history": [],
  "strategy_performance": {},
  "learning_log": [],
  "square": {
    "enabled": false,
    "language": "zh",
    "style": "professional",
    "total_posts": 0,
    "followers": 0,
    "last_post_time": ""
  }
}
```

### 0.6 功能展示 + 启动

```
🦞 BNB Guardian 已就绪！

你的 AI 交易管家已上线，以下能力已激活：

📡 全盘监控 — 币安全部交易对（现货+合约+币本位）实时扫描
📊 技术分析 — MA/RSI/MACD/布林带 多周期共振分析
💰 现货交易 — 市价/限价/OCO/冰山委托/分批建仓
📈 合约交易 — 做多/做空/追踪止损/杠杆调整
🏦 杠杆交易 — 借币/还币/杠杆下单
🎯 策略引擎 — 网格/趋势跟踪/费率套利/三角套利/定投/回测
🛡️ 智能风控 — 止损/熔断/黑天鹅保护/滑点保护/杠杆降级
🧠 自我进化 — 每日复盘/策略淘汰/参数自优化/学习日志
📰 多源情报 — 恐惧贪婪/X情绪/链上数据/新闻/币安公告/清算数据
📢 币安广场 — 自动发帖/互动/涨粉（如已开启）

从现在开始，我会自动运行。有重要信号会立即通知你。

💡 你也可以随时跟我对话：
• "BNB 分析" — 完整技术面分析
• "持仓" / "资产" — 三账户全景
• "报告" — 生成即时报告
• "回测 BNB 均线策略" — 策略回测
• "暂停" — 暂停自动交易
• "恢复" — 恢复自动交易
• "风控状态" — 查看风控仪表盘
```

自动进入第一步 →

---

## 第一步：加载凭证和状态

每次 skill 激活时执行：

1. 读取 `vault/binance-api.json` → 获取 `api_key` 和 `api_secret`
2. 读取 `memory/binance-state.json` → 获取配置和状态
3. 读取 `memory/binance-lessons.json` → 加载历史教训（决策时参考）
4. 如果凭证不存在 → 跳到引导 0.2
5. 如果状态不存在但凭证存在 → 跳到引导 0.3

### 签名调用模板

所有签名接口统一用这个模式（只替换 URL 和 QUERY 参数）：

```bash
API_KEY="从vault读取"
API_SECRET="从vault读取"
TS=$(date +%s000)
QUERY="timestamp=$TS&recvWindow=5000&其他参数"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/api/v3/endpoint?${QUERY}&signature=${SIG}"
```

合约接口 base URL 换成 `https://fapi.binance.com`。
币本位合约换成 `https://dapi.binance.com`。
杠杆接口用 `https://api.binance.com/sapi/v1/margin/...`。

---

## 第二步：全盘市场监控（全自动循环）

核心循环，用 cron 每 5 分钟触发。启动后永不停止。

### 2.1 全量行情扫描

扫描**币安全部交易对**（不只是关注列表）：

```bash
# 现货全量（所有 USDT/BTC/ETH/BNB/FDUSD/USDC 对）
curl -s "https://api.binance.com/api/v3/ticker/24hr"

# U本位合约全量
curl -s "https://fapi.binance.com/fapi/v1/ticker/24hr"

# 币本位合约全量
curl -s "https://dapi.binance.com/dapi/v1/ticker/24hr"
```

返回 JSON 数组，每个元素包含 symbol、priceChangePercent、volume、lastPrice 等。

### 2.2 异动检测规则

对全量数据执行筛选，任何命中都推送：

| 条件 | 级别 | 推送内容 |
|------|------|---------|
| 5分钟涨跌 > 3% | 🟡 重要 | 币种、涨跌幅、成交量变化 |
| 1小时涨跌 > 10% | 🔴 紧急 | 币种、涨跌幅、成交量、可能原因分析 |
| 24小时涨跌 > 20% | 🔴 紧急 | 完整技术分析 + 操作建议 |
| 成交量放大 > 3倍 | 🟡 重要 | 币种、量比、价格方向 |
| 创 24h 新高 | 🟢 常规 | 币种、价格、突破力度 |
| 创 24h 新低 | 🟡 重要 | 币种、价格、支撑位分析 |
| 突破 MA99 | 🟡 重要 | 币种、突破方向、技术分析 |
| 突破 MA200 | 🔴 紧急 | 趋势反转信号，完整分析 |

### 2.3 深度数据监控

对**关注列表 + 持仓中的币种**，额外获取深度数据：

```bash
# 多空比（散户）
curl -s "https://fapi.binance.com/futures/data/globalLongShortAccountRatio?symbol=BNBUSDT&period=5m&limit=1"

# 持仓量（Open Interest）
curl -s "https://fapi.binance.com/futures/data/openInterestHist?symbol=BNBUSDT&period=5m&limit=1"

# 大户持仓比
curl -s "https://fapi.binance.com/futures/data/topLongShortPositionRatio?symbol=BNBUSDT&period=5m&limit=1"

# 大户账户比
curl -s "https://fapi.binance.com/futures/data/topLongShortAccountRatio?symbol=BNBUSDT&period=5m&limit=1"

# 资金费率
curl -s "https://fapi.binance.com/fapi/v1/fundingRate?symbol=BNBUSDT&limit=1"

# 盘口深度
curl -s "https://api.binance.com/api/v3/depth?symbol=BNBUSDT&limit=20"
```

异常信号推送规则：
- 多空比 > 3.0 或 < 0.33 → 🔴 极端值反转警告
- 持仓量 1h 变化 > 20% + 价格不动 → 🟡 即将变盘
- 大户多空比与散户多空比方向相反 → 🟡 跟大户信号
- 资金费率 > 0.1% 或 < -0.1% → 🟡 套利机会
- 盘口买卖比 > 3:1 或 < 1:3 → 🟢 支撑/压力信号

### 2.4 账户持仓监控

每 5 分钟同步检查持仓状态：

```bash
# 现货
curl ... /api/v3/account (签名)

# 合约持仓
curl ... /fapi/v2/positionRisk (签名)

# 合约保证金率
# 从 positionRisk 计算 liquidationPrice vs markPrice
```

推送规则：
- 任何挂单成交 → 🟡 即时推送
- 合约保证金率 < 200% → 🟡 警告
- 合约保证金率 < 150% → 🔴 紧急！接近爆仓
- 持仓未实现亏损 > 5% → 🟡 关注
- 持仓未实现亏损 > 10% → 🔴 考虑减仓

---

## 第三步：多源数据采集（全自动，每 30 分钟）

### 3.1 恐惧贪婪指数
```bash
curl -s "https://api.alternative.me/fng/?limit=1"
```
- < 20 极度恐惧 → 抄底信号（推送 🟡）
- 20-40 恐惧
- 40-60 中性
- 60-80 贪婪
- > 80 极度贪婪 → 逃顶信号（推送 🟡）

### 3.2 CoinGecko 全球数据
```bash
curl -s "https://api.coingecko.com/api/v3/global"
```
提取：
- `data.market_cap_percentage.btc` — BTC 主导率
- `data.total_market_cap.usd` — 总市值
- `data.market_cap_change_percentage_24h_usd` — 24h 变化

BTC 主导率上升 = BTC 季（山寨弱，减仓山寨）
BTC 主导率下降 = 山寨季（可以加仓山寨）

### 3.3 新闻聚合
```
web_search "BNB news today"
web_search "Bitcoin crypto news today"
web_search "Binance announcement"
```
AI 分析每条新闻的影响：利好(+)/利空(-)/中性(0)
重大利好或利空 → 🔴 紧急推送

### 3.4 X/推特情绪
```
web_search "$BNB crypto"
web_search "$BTC sentiment"
web_search "crypto market fear"
```
AI 综合分析推文情绪：极度看涨/看涨/中性/看跌/极度看跌

### 3.5 链上数据
```
web_search "BNB whale transfer today"
web_search "crypto exchange inflow outflow"
web_search "stablecoin market cap change"
```
- 交易所流入增加 = 卖压（看跌）
- 交易所流出增加 = 囤币（看涨）
- 稳定币市值增加 = 场外资金入场（看涨）

### 3.6 清算数据
```
web_search "crypto liquidation data today"
```
- 大规模多头清算 = 超卖，可能抄底
- 大规模空头清算 = 超买，可能回调

### 3.7 币安公告
```
web_search "site:binance.com new listing announcement 2026"
web_search "binance maintenance schedule"
```
- 新币上线 → 🟡 推送 + 分析是否值得参与
- 系统维护 → 🟡 暂停策略提醒
- 规则变更 → 🟡 推送

---

## 第四步：技术分析引擎

触发条件：用户问 or 自动决策循环需要 or 5分钟监控发现异动后深入分析

触发词：分析、技术面、该买吗、该卖吗、看涨、看跌、怎么看

### 4.1 K 线获取（多时间框架）

同时获取三个周期做共振分析：

```bash
# 日线（看大趋势）
curl -s "https://api.binance.com/api/v3/klines?symbol=BNBUSDT&interval=1d&limit=200"

# 4小时（找入场时机）
curl -s "https://api.binance.com/api/v3/klines?symbol=BNBUSDT&interval=4h&limit=100"

# 1小时（精确进场点）
curl -s "https://api.binance.com/api/v3/klines?symbol=BNBUSDT&interval=1h&limit=100"
```

K 线数据格式：数组，每条 [openTime, open, high, low, close, volume, closeTime, quoteVolume, trades, takerBuyBase, takerBuyQuote, ignore]

### 4.2 技术指标计算

对每个时间框架，用 K 线数据计算以下指标：

**MA（简单移动平均线）**
- MA7 = 最近 7 根 K 线 close 的算术平均
- MA25 = 最近 25 根
- MA99 = 最近 99 根
- MA200 = 最近 200 根（仅日线）
- 判断：MA7 > MA25 > MA99 = 多头排列（看涨）；反之空头排列（看跌）

**RSI（相对强弱指标，14 周期）**
```
计算步骤：
1. 每根 K 线涨跌 = close - 前一根 close
2. 涨幅序列 = max(涨跌, 0)，跌幅序列 = max(-涨跌, 0)
3. 平均涨幅 = 涨幅序列最近 14 期的 EMA
4. 平均跌幅 = 跌幅序列最近 14 期的 EMA
5. RS = 平均涨幅 / 平均跌幅
6. RSI = 100 - (100 / (1 + RS))
```
- RSI > 80 = 强超买 | > 70 = 超买 | 30-70 = 中性 | < 30 = 超卖 | < 15 = 极度超卖

**MACD（12, 26, 9）**
```
1. EMA12 = close 的 12 期指数移动平均
2. EMA26 = close 的 26 期指数移动平均
3. DIF = EMA12 - EMA26
4. DEA = DIF 的 9 期 EMA
5. MACD 柱 = (DIF - DEA) * 2
```
- DIF 上穿 DEA = 金叉（买入信号）
- DIF 下穿 DEA = 死叉（卖出信号）
- MACD 柱由负转正 = 动能转多

**布林带（20, 2）**
```
1. 中轨 = 最近 20 根 close 的 MA
2. 标准差 = 最近 20 根 close 的标准差
3. 上轨 = 中轨 + 2 × 标准差
4. 下轨 = 中轨 - 2 × 标准差
```
- 价格触及上轨 = 超买区
- 价格触及下轨 = 超卖区
- 布林带收窄（上下轨距离缩小）= 即将变盘
- 价格沿上轨运行 = 强势上涨

**主动买卖量比**
```
taker_buy_ratio = K 线 takerBuyBase (index 9) / volume (index 5)
```
- > 0.6 = 主动买入强势
- < 0.4 = 主动卖出强势

### 4.3 多时间框架共振

```
日线趋势判断（权重 40%）
  多头排列 + RSI 50-70 + MACD 多头 = 看涨
  空头排列 + RSI 30-50 + MACD 空头 = 看跌

4H 信号判断（权重 35%）
  金叉 + RSI 回升 + 量增 = 买入信号
  死叉 + RSI 下降 + 量缩 = 卖出信号

1H 精确入场（权重 25%）
  找到具体入场价位和止损位

共振规则：
  三个时间框架同时看涨 = 高置信度 (>80%)
  两个看涨一个中性 = 中等置信度 (60-80%)
  时间框架矛盾 = 低置信度 (<60%)，谨慎操作或观望
```

### 4.4 时段分析

根据 UTC 时间判断当前交易时段特征：
- 亚盘 00:00-08:00 UTC → 波动小，适合网格策略
- 欧盘 08:00-14:00 UTC → 波动增大，趋势行情开始
- 美盘 14:00-21:00 UTC → 波动最大，主要趋势在这里
- 周末 → 流动性差，避免大仓位，减少杠杆

### 4.5 综合评分（-100 到 +100）

| 因素 | 权重 | 评分规则 |
|------|------|---------|
| 技术面（多时间框架共振）| 30% | 强多头 +30 / 强空头 -30 |
| RSI | 10% | 极度超卖 +10 / 极度超买 -10 |
| MACD | 10% | 金叉 +10 / 死叉 -10 |
| 成交量 | 10% | 放量确认趋势 +10 / 缩量背离 -10 |
| 恐惧贪婪指数 | 10% | 极度恐惧 +10 / 极度贪婪 -10 |
| 新闻情绪 | 10% | 重大利好 +10 / 重大利空 -10 |
| X 推文情绪 | 5% | 看涨 +5 / 看跌 -5 |
| 多空比（反向指标）| 5% | 极端做多 -5（反向）/ 极端做空 +5 |
| 链上数据 | 5% | 流出增加 +5 / 流入增加 -5 |
| 大户动向 | 5% | 大户做多 +5 / 做空 -5 |

评分解读：
- +70 ~ +100 = 强烈看涨 → 趋势做多
- +30 ~ +70 = 看涨 → 轻仓做多
- -30 ~ +30 = 震荡 → 网格交易或观望
- -70 ~ -30 = 看跌 → 减仓或轻仓做空
- -100 ~ -70 = 强烈看跌 → 趋势做空或清仓

输出格式：
```
🔍 BNB/USDT 综合分析
━━━━━━━━━━━━━━━━━━━━━
📊 技术面: 多头排列，4H金叉 (+24/30)
📈 RSI(14): 35 超卖区 (+8/10)
📊 MACD: 金叉确认，动能增强 (+7/10)
📊 成交量: 放大 1.5x (+5/10)
😱 恐惧贪婪: 32 恐惧 (+6/10)
📰 新闻: 中性偏多 (+3/10)
🐦 X 情绪: 偏看涨 (+3/5)
⚖️ 多空比: 1.8 正常 (+0/5)
🔗 链上: 交易所流出增加 (+3/5)
🐋 大户: 轻度做多 (+2/5)

🎯 综合评分: +61/100 (看涨)
📊 置信度: 72%
⏰ 当前时段: 欧盘（趋势行情开始）
💡 建议: 分批建仓做多
🛡️ 建议止损: $620 (-3.5%)
🎯 建议止盈: $680 (+5.8%)
⚠️ 注意: 参考历史教训 — "震荡市止损放宽到-3%"
```

---

## 第五步：现货交易

### 5.1 市价单
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&side=BUY&type=MARKET&quantity=0.5&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/api/v3/order?${QUERY}&signature=${SIG}"
```

### 5.2 限价单
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&side=BUY&type=LIMIT&timeInForce=GTC&quantity=0.5&price=630.00&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/api/v3/order?${QUERY}&signature=${SIG}"
```

### 5.3 OCO 止损止盈单
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&side=SELL&quantity=0.5&price=670.00&stopPrice=620.00&stopLimitPrice=619.00&stopLimitTimeInForce=GTC&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/api/v3/order/oco?${QUERY}&signature=${SIG}"
```

### 5.4 查看挂单
```bash
TS=$(date +%s000)
QUERY="timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/api/v3/openOrders?${QUERY}&signature=${SIG}"
```

### 5.5 取消挂单
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&orderId=12345678&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X DELETE -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/api/v3/order?${QUERY}&signature=${SIG}"
```

### 5.6 冰山委托（拆单执行）

大额买入时，拆成多笔小单分时间段执行，避免暴露意图：
1. 总量拆成 5-10 笔
2. 每笔间隔 30-60 秒（随机）
3. 每笔量加 ±10% 随机扰动
4. 用限价单，价格 = 当前最优买价 + 微调
5. 每笔成交后记录，未成交的 60 秒后取消重挂

### 5.7 分批建仓

根据综合评分分批进场：
- 评分 40-60（中等看涨）→ 第一批 30% 计划仓位
- 等待 1-4h，评分维持或上升 → 第二批 30%
- 评分 > 80（强烈看涨）→ 最后 40%
- 每批都设独立止损
- 任何一批止损触发 → 暂停后续建仓，重新评估

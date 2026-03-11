## 第六步：合约交易

API Base: https://fapi.binance.com

所有合约接口签名方式同现货，只是 base URL 不同。

### 6.1 设置杠杆
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&leverage=10&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://fapi.binance.com/fapi/v1/leverage?${QUERY}&signature=${SIG}"
```

### 6.2 开多仓
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&side=BUY&type=MARKET&quantity=1&positionSide=LONG&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://fapi.binance.com/fapi/v1/order?${QUERY}&signature=${SIG}"
```

### 6.3 开空仓
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&side=SELL&type=MARKET&quantity=1&positionSide=SHORT&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://fapi.binance.com/fapi/v1/order?${QUERY}&signature=${SIG}"
```

### 6.4 平仓
做多平仓：side=SELL, positionSide=LONG
做空平仓：side=BUY, positionSide=SHORT

### 6.5 止损止盈（合约）
```bash
# 止损
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&side=SELL&type=STOP_MARKET&stopPrice=620&positionSide=LONG&closePosition=true&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://fapi.binance.com/fapi/v1/order?${QUERY}&signature=${SIG}"

# 止盈
# type=TAKE_PROFIT_MARKET, stopPrice=目标价
```

### 6.6 追踪止损
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&side=SELL&type=TRAILING_STOP_MARKET&callbackRate=2&positionSide=LONG&quantity=1&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://fapi.binance.com/fapi/v1/order?${QUERY}&signature=${SIG}"
```
callbackRate = 回撤百分比（1-5%）

### 6.7 查看持仓
```bash
TS=$(date +%s000)
QUERY="timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -H "X-MBX-APIKEY: $API_KEY" "https://fapi.binance.com/fapi/v2/positionRisk?${QUERY}&signature=${SIG}"
```

### 6.8 资金费率监控
```bash
curl -s "https://fapi.binance.com/fapi/v1/fundingRate?symbol=BNBUSDT&limit=1"
```
- 费率 > 0.1% → 做空有利（费率套利机会）
- 费率 < -0.1% → 做多有利

---

## 第七步：杠杆交易

### 7.1 杠杆账户信息
```bash
TS=$(date +%s000)
QUERY="timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/sapi/v1/margin/account?${QUERY}&signature=${SIG}"
```

### 7.2 借币
```bash
TS=$(date +%s000)
QUERY="asset=USDT&amount=1000&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/sapi/v1/margin/loan?${QUERY}&signature=${SIG}"
```

### 7.3 还币
```bash
TS=$(date +%s000)
QUERY="asset=USDT&amount=1000&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/sapi/v1/margin/repay?${QUERY}&signature=${SIG}"
```

### 7.4 杠杆下单
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&side=BUY&type=MARKET&quantity=1&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -X POST -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/sapi/v1/margin/order?${QUERY}&signature=${SIG}"
```

---

## 第八步：账户全景

触发词：持仓、余额、资产、账户

### 8.1 一键查看三账户
同时查现货+合约+杠杆余额，汇总展示：

```bash
# 现货
curl ... /api/v3/account (签名)

# 合约
curl ... /fapi/v2/balance (签名)

# 杠杆
curl ... /sapi/v1/margin/account (签名)
```

输出格式：
```
👛 账户全景
━━━━━━━━━━━━━━━━━━
📦 现货账户
  BNB: 10.5 ($6,746)
  USDT: 2,350.00
  BTC: 0.05 ($4,250)
  总计: $13,346

📈 合约账户
  总余额: $5,000
  未实现盈亏: +$230
  可用保证金: $3,200
  持仓: BNBUSDT 多 2x | +4.5%

🏦 杠杆账户
  净资产: $3,000
  借款: $1,000
  风险率: 2.5 (安全)

💰 总资产: $21,346
📈 今日盈亏: +$180 (+0.85%)
```

### 8.2 成交历史
```bash
TS=$(date +%s000)
QUERY="symbol=BNBUSDT&limit=20&timestamp=$TS&recvWindow=5000"
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')
curl -s -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/api/v3/myTrades?${QUERY}&signature=${SIG}"
```

---

## 第九步：策略引擎

### 9.1 自动策略选择

Agent 根据市场状态自动选择最优策略：

| 市场状态判断 | 选择策略 | 交易方式 |
|-------------|---------|---------|
| 综合评分 > 70 + 多时间框架共振看涨 | 趋势跟踪做多 | 现货买入 or 合约做多(3-5x) |
| 综合评分 < -70 + 多时间框架共振看跌 | 趋势做空 | 合约做空(3-5x) |
| 评分 -30 到 30 + 布林带收窄 | 网格交易 | 现货或合约网格 |
| RSI < 15 + 暴跌 > 10% + 无实质利空 | 插针抄底 | 现货分批买入 |
| 单边上涨 + RSI > 80 | 移动止盈 | 追踪止损 |
| 资金费率 > 0.1% | 费率套利 | 现货多+合约空对冲 |
| 三角汇率偏离 > 0.3% | 三角套利 | 连续三笔现货交易 |
| 定投时间到 | DCA 定投 | 固定金额现货买入 |

### 9.2 网格交易执行

当决策为网格时自动执行：

1. 确定价格区间（布林带上下轨 or 近期高低点）
2. 计算网格数（默认10格）
3. 计算每格价格和数量
4. 在每个网格价位挂限价单（上方挂卖，下方挂买）
5. 某格成交后自动挂反向单
6. 状态保存到 binance-state.json 的 grid_orders

```
网格参数示例：
区间: $620 - $670
网格数: 10
每格间距: $5
每格量: 0.2 BNB
```

### 9.3 费率套利

当发现资金费率异常时自动执行：

1. 检测到费率 > 0.1%（做多付费做空收费）
2. 现货买入 X BNB（对冲用）
3. 合约做空 X BNB（1x杠杆，等值）
4. 等收取资金费率（每8小时一次）
5. 费率恢复正常后同时平掉两边

预期收益：每次费率 0.1% × 3次/天 = 0.3%/天

### 9.4 三角套利

监控三角汇率：
```
路径1: USDT → BNB → BTC → USDT
路径2: USDT → BTC → ETH → USDT
```
当三角汇率偏离 > 0.3%（扣除手续费后有利润），自动执行三笔交易。

### 9.5 回测引擎

触发词：回测

1. 获取历史 K 线（GET /api/v3/klines, limit=1000）
2. 模拟策略执行（均线交叉/RSI/MACD）
3. 计算绩效指标

输出格式：
```
📊 策略回测报告
━━━━━━━━━━━━━━━━━━
📋 策略: MA7/MA25 交叉
📅 回测区间: 最近 1000 根 4H K线 (约166天)
💰 初始资金: $10,000

📈 结果:
  总收益率: +32.5%
  胜率: 58%
  盈亏比: 1.8
  最大回撤: -12.3%
  夏普比率: 1.45
  总交易次数: 47

🏆 最佳交易: +8.2% (2026-01-15)
💀 最差交易: -4.1% (2026-02-03)
```

### 9.6 定投策略

用户设定后自动执行：
- 每天/每周固定时间
- 固定金额（如每天买 $50 BNB）
- 用市价单执行
- 记录每笔成本，计算平均成本

---

## 第十步：安全与风控（最高优先级）

风控规则在任何交易前强制检查，不通过不执行。

### 10.1 仓位控制
- 单笔不超过总资产的 `max_position_pct`（默认5%）
- 单币种总仓位不超过总资产 20%
- 合约杠杆不超过设定值（保守2x/稳健5x/激进10x）
- 永远保留 20% USDT 作为抄底弹药
- 同时持仓不超过 8 个品种

### 10.2 凯利公式仓位计算
```
最优仓位比例 = (胜率 × 盈亏比 - (1-胜率)) / 盈亏比
```
实际使用凯利公式的 1/2（半凯利），更保守。

### 10.3 相关性检查
- BNB/BTC/ETH 相关性高，不同时重仓
- 相关性 > 0.8 的币种，合计仓位不超过 30%

### 10.4 止损机制
- 每笔交易必须设止损（现货用 OCO，合约用 STOP_MARKET）
- 现货止损：默认 -5%
- 合约止损：默认 -3%（因为有杠杆）

### 10.5 熔断机制
| 触发条件 | 动作 |
|---------|------|
| 日亏损 > 5% | 暂停所有交易 24h |
| 连亏 3 笔 | 暂停 4h 冷静 |
| 单币亏损 > 10% | 强制减仓 50% |
| 总资产回撤 > 10% | 清所有合约仓位 |
| 15分钟内任意币跌 > 15% | 黑天鹅保护，清全部合约 |

### 10.6 杠杆自动降级
亏损时自动降低杠杆：
- 日亏损 > 2% → 杠杆减半
- 日亏损 > 3% → 杠杆降到 1x
- 日亏损 > 5% → 平所有合约

### 10.7 盈利保护
- 当日盈利 > 5% → 止损收紧到保本位
- 持仓浮盈 > 10% → 启用追踪止损
- 追踪止损回撤比例：2-5%

### 10.8 滑点保护
市价单预估成交价 vs 实际成交价：
- 偏差 > 1% → 告警
- 偏差 > 2% → 暂停市价单，改用限价单

### 10.9 API 异常保护
- 连续 3 次 API 失败 → 暂停交易 + 紧急通知
- 429 限流 → 降低请求频率
- 401/403 → 停止交易 + 通知用户检查 API Key

---

## 第十一步：推送通知系统

所有事件按紧急程度分级推送：

### 🔴 紧急（立即推送）
- 风控触发（熔断/爆仓风险/黑天鹅）
- 合约保证金率 < 150%
- 大额亏损
- API 异常
- 15分钟内暴涨暴跌 > 10%

### 🟡 重要（即时推送）
- 交易执行（开仓/平仓/挂单成交）
- 止损/止盈触发
- 策略切换
- 套利机会发现和执行
- 1小时涨跌 > 5%

### 🟢 常规（汇总推送）
- 每小时持仓盈亏摘要
- 异动检测（5分钟涨跌 > 3%）
- 创新高/新低

### 📋 定期报告
- 每日早报（8:00）：市场概览 + 今日策略
- 每日晚报（20:00）：当日交易总结 + 盈亏
- 每周报告（周日20:00）：本周复盘 + 策略评估
- 每月报告（月末）：月度绩效 + 参数优化建议

每日报告格式：
```
📊 每日交易报告 2026-03-11
━━━━━━━━━━━━━━━━━━
💰 今日盈亏: +$127.30 (+0.6%)
📈 交易次数: 5 (胜3负2)
🏆 最佳: BNBUSDT +3.2%
💀 最差: SOLUSDT -1.1%

📦 当前持仓:
  BNB: 10.5 ($6,746) +2.3%
  BTC: 0.05 ($4,250) -0.5%
  合约: ETHUSDT 多3x +1.8%

🛡️ 风控状态: 正常 ✅
  日亏损限额: 已用 0.3%/5%
  保证金率: 320% (安全)

🧠 策略表现:
  趋势跟踪: 2胜1负 (+$85)
  网格: 1胜1负 (+$42)

📊 市场情绪: 中性偏多 (恐惧贪婪: 55)
```

---

## 第十二步：自我学习与进化

### 12.1 每笔交易记录

每次交易完成后，自动记录到 `memory/binance-trades.json`：
```json
{
  "id": "trade_001",
  "timestamp": "2026-03-11T10:30:00Z",
  "symbol": "BNBUSDT",
  "side": "BUY",
  "type": "现货",
  "strategy": "趋势跟踪",
  "entry_price": 635,
  "exit_price": 660,
  "quantity": 1,
  "pnl": 25,
  "pnl_pct": 3.9,
  "hold_time": "4h",
  "entry_score": 72,
  "entry_reason": "多时间框架共振看涨，RSI从超卖区回升",
  "exit_reason": "止盈触发",
  "market_condition": "上涨趋势",
  "indicators_at_entry": {
    "rsi": 35,
    "macd": "金叉",
    "ma_alignment": "多头",
    "fng": 38
  },
  "review_score": null,
  "lesson": null
}
```

### 12.2 每日复盘（自动执行）

每天 22:00 自动复盘：
1. 回顾当日所有交易
2. 分析胜败原因
3. 给每笔交易打分（A/B/C/D/F）
4. 提取教训写入 `memory/binance-lessons.json`
5. 生成复盘日记写入 `memory/binance-diary.md`

复盘内容：
```
📝 交易日记 2026-03-11
━━━━━━━━━━━━━━━━━━
今天的市场以震荡为主，BNB在$635-$650区间波动。

✅ 好的决策：
- 早盘RSI超卖时果断抄底BNB@$635，收益+3.9%
- 及时识别ETH假突破，未追高

❌ 教训：
- SOL止损设太紧(-2%)，被洗出后又涨了5%
  → 调整：震荡市止损放宽到-3%

🧠 发现的规律：
- 亚盘BNB波动明显小于美盘，网格策略亚盘更稳
- RSI<30+恐惧贪婪<35的组合，过去一周抄底成功率100%

📊 参数调整建议：
- RSI抄底阈值从30调到28（减少假信号）
- 网格间距从$5调到$4（震荡区间缩小了）
```

### 12.3 策略绩效追踪

持续追踪每个策略的表现，存入 `binance-state.json` 的 `strategy_performance`：
```json
{
  "趋势跟踪": {
    "total_trades": 45,
    "wins": 28,
    "losses": 17,
    "win_rate": 62.2,
    "total_pnl": 1250,
    "avg_pnl": 27.8,
    "max_win": 180,
    "max_loss": -85,
    "sharpe": 1.6,
    "last_30d_win_rate": 65,
    "trending": "improving"
  },
  "网格交易": {},
  "费率套利": {},
  "抄底": {}
}
```

### 12.4 策略自动淘汰与优化

每周日复盘时执行：
- 近 30 天胜率 < 40% 的策略 → 暂停使用
- 近 30 天亏损的策略 → 降低仓位权重
- 近 30 天夏普 > 2 的策略 → 提高仓位权重
- 发现新的有效模式 → 提取为新策略

### 12.5 参数自优化

每月执行一次参数回测优化：
1. 用过去 60 天数据回测当前参数
2. 用网格搜索测试参数变体（RSI阈值、MA周期、止损比例等）
3. 选择夏普比率最高的参数组合
4. 更新参数并记录变更原因

### 12.6 学习日志

所有学到的教训和规律存入 `memory/binance-lessons.json`：
```json
[
  {
    "date": "2026-03-11",
    "category": "止损",
    "lesson": "震荡市止损不能太紧，-2%容易被洗，建议-3%",
    "confidence": 0.7,
    "applied": true
  },
  {
    "date": "2026-03-10",
    "category": "时段",
    "lesson": "亚盘BNB网格收益稳定，美盘波动大适合趋势",
    "confidence": 0.8,
    "applied": true
  }
]
```

Agent 在做决策时必须参考历史教训，不犯重复错误。

---

## 第十三步：特殊场景处理

### 13.1 新币上线
- 监控币安公告（web_search "binance new listing"）
- 新币上线前分析：项目背景、市值、社区热度
- 上线后 5 分钟内不操作（价格剧烈波动）
- 稳定后视情况小仓位参与

### 13.2 极端行情
- 检测到 BTC 15分钟跌 > 10%：
  1. 立即清所有合约
  2. 现货不动（长期持有）
  3. 等稳定后评估抄底机会

### 13.3 跨品种联动
- BTC 暴跌 → 提前减仓山寨（山寨跌更多）
- BTC 上涨 + BTC主导率下降 → 山寨季来了，加仓山寨
- ETH/BTC 比率上升 → 以太季，重仓 ETH 生态

### 13.4 合约交割
- 季度合约到期前 3 天提醒
- 自动移仓到下个季度

### 13.5 系统维护
- 检测到币安维护公告 → 暂停所有策略
- 维护结束后重新评估市场再恢复

---

## 错误处理

| 错误 | 恢复策略 |
|------|---------|
| 401 Unauthorized | 停止交易，通知用户检查 API Key |
| 403 Forbidden | 权限不足，通知用户开启对应权限 |
| 429 Too Many Requests | 降低频率，等待重试 |
| -1021 时间戳问题 | 同步服务器时间，重试 |
| -1022 签名无效 | 检查 API Secret，重新签名 |
| -2010 余额不足 | 调整下单量，通知用户 |
| -4003 合约余额不足 | 减仓或追加保证金提醒 |
| 网络超时 | 30秒后重试，最多3次 |
| 未知错误 | 记录日志，通知用户，暂停该操作 |

---

## 推送级别定义

| 级别 | emoji | 场景 | 方式 |
|------|-------|------|------|
| 🔴 紧急 | 🚨 | 风控触发/爆仓风险/黑天鹅/API异常 | 立即推送 |
| 🟡 重要 | ⚡ | 交易执行/止损止盈/策略切换/套利 | 即时推送 |
| 🟢 常规 | 📊 | 异动检测/新高新低/定期报告 | 汇总推送 |
| ⚪ 信息 | 📝 | 学习记录/参数调整/策略评估 | 写入日志 |

# Binance API 参考

## Base URL

```
https://api.binance.com
```

## 公开接口（无需签名）

### 最新价格
```
GET /api/v3/ticker/price
参数: symbol (可选，如 BNBUSDT)
无 symbol 返回所有交易对
```

### 24h 行情统计
```
GET /api/v3/ticker/24hr
参数: symbol (可选)
返回: priceChange, priceChangePercent, volume, quoteVolume, highPrice, lowPrice, lastPrice, openPrice
```

### K 线数据
```
GET /api/v3/klines
必选: symbol, interval
可选: limit (默认500, 最大1000), startTime, endTime
interval 值: 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M

返回数组，每条:
[0] openTime       [1] open         [2] high
[3] low            [4] close        [5] volume
[6] closeTime      [7] quoteVolume  [8] trades
[9] takerBuyBase   [10] takerBuyQuote [11] ignore
```

### 深度数据
```
GET /api/v3/depth
必选: symbol
可选: limit (5/10/20/50/100/500/1000/5000, 默认100)
返回: bids[], asks[]
```

### 最近成交
```
GET /api/v3/trades
必选: symbol
可选: limit (默认500, 最大1000)
```

### 最优挂单
```
GET /api/v3/ticker/bookTicker
参数: symbol (可选)
返回: bidPrice, bidQty, askPrice, askQty
```

## 签名接口（需 HMAC-SHA256）

所有签名接口需要:
- Header: `X-MBX-APIKEY: <api_key>`
- 查询参数: `timestamp=<unix_ms>` + `signature=<hmac_sha256>`

### 账户信息
```
GET /api/v3/account
参数: timestamp, recvWindow(可选)
返回: balances[{asset, free, locked}], ...
```

### 成交历史
```
GET /api/v3/myTrades
必选: symbol, timestamp
可选: limit, fromId, startTime, endTime
```

### 当前挂单
```
GET /api/v3/openOrders
可选: symbol, timestamp
```

## 签名计算

```bash
# 1. 构建查询字符串
QUERY="timestamp=$(date +%s000)&recvWindow=5000"

# 2. HMAC-SHA256 签名
SIG=$(echo -n "$QUERY" | openssl dgst -sha256 -hmac "$API_SECRET" | awk '{print $NF}')

# 3. 拼接
FULL="${QUERY}&signature=${SIG}"

# 4. 请求
curl -s -H "X-MBX-APIKEY: $API_KEY" "https://api.binance.com/api/v3/account?${FULL}"
```

## 常用交易对

| 交易对 | 说明 |
|--------|------|
| BTCUSDT | 比特币/USDT |
| ETHUSDT | 以太坊/USDT |
| BNBUSDT | BNB/USDT |
| SOLUSDT | Solana/USDT |
| DOGEUSDT | 狗狗币/USDT |
| XRPUSDT | XRP/USDT |

## 错误码

| 代码 | 含义 |
|------|------|
| -1000 | 未知错误 |
| -1002 | 未授权 |
| -1021 | 时间戳超出 recvWindow |
| -1022 | 签名无效 |
| -1100 | 非法参数 |
| -1121 | 无效交易对 |

## 频率限制

- 公开接口: 1200 次/分钟 (IP)
- 签名接口: 10 次/秒, 100000 次/天 (UID)
- K线: 单次最��� 1000 条

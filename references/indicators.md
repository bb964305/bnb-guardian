# 技术指标计算参考

## MA — 移动平均线

简单移动平均 (SMA):
```
MA(N) = (C1 + C2 + ... + CN) / N
```
- MA(7): 短期趋势
- MA(25): 中期趋势
- MA(99): 长期趋势

信号:
- 金叉: MA(7) 上穿 MA(25) → 看涨
- 死叉: MA(7) 下穿 MA(25) → 看跌
- 价格在 MA(99) 上方 → 长期多头
- 价格在 MA(99) 下方 → 长期空头

## RSI — 相对强弱指数

```
RS = 平均涨幅(N) / 平均跌幅(N)
RSI = 100 - 100 / (1 + RS)
```

计算步骤 (N=14):
1. 计算每根K线的涨跌: change = close[i] - close[i-1]
2. 分离涨幅(gain)和跌幅(loss)
3. 第一个周期: avgGain = sum(gains[0..13]) / 14, avgLoss = sum(losses[0..13]) / 14
4. 后续周期: avgGain = (prevAvgGain * 13 + currentGain) / 14 (指数平滑)
5. RS = avgGain / avgLoss
6. RSI = 100 - 100 / (1 + RS)

信号:
- RSI > 70: 超买区，可能回调
- RSI < 30: 超卖区，可能反弹
- RSI 50 附近: 中性

## MACD — 指数平滑异同移动平均线

```
EMA(N) 计算:
  multiplier = 2 / (N + 1)
  EMA_today = (close - EMA_yesterday) * multiplier + EMA_yesterday
  首个 EMA = SMA(N)

MACD 线 = EMA(12) - EMA(26)
信号线 (Signal) = EMA(9) of MACD线
柱状图 (Histogram) = MACD线 - 信号线
```

信号:
- MACD 上穿 Signal → 金叉，看涨
- MACD 下穿 Signal → 死叉，看跌
- Histogram 由负转正 → 多头动能增强
- Histogram 由正转负 → 空头动能增强
- MACD 与价格背离 → 趋势可能反转

## 布林带 (Bollinger Bands)

```
中轨 = MA(20)
上轨 = MA(20) + 2 * StdDev(20)
下轨 = MA(20) - 2 * StdDev(20)
```

信号:
- 价格触及上轨 → 可能超买
- 价格触及下轨 → 可能超卖
- 带宽收窄 → 即将突破

## 成交量分析

- 放量上涨: 趋势确认
- 缩量上涨: 动能不足
- 放量下跌: 恐慌抛售
- 缩量下跌: 抛压减弱

## 综合研判框架

1. 先看 MA 判断趋势方向
2. 用 RSI 判断超买超卖
3. 用 MACD 确认动能
4. 结合成交量验证
5. 多指标共振 → 信号更可靠

评级标准:
- 🟢 强烈看涨: MA金叉 + RSI<70上升 + MACD金叉 + 放量
- 🟡 震荡: 指标矛盾，无明确方向
- 🔴 强烈看跌: MA死叉 + RSI>30下降 + MACD死叉 + 放量

## 回测公式

### 双均线策略
```
买入条件: MA(short) 上穿 MA(long)
卖出条件: MA(short) 下穿 MA(long)
```

### 回测指标
```
胜率 = 盈利交易数 / 总交易数 * 100%
总收益率 = (最终资金 - 初始资金) / 初始资金 * 100%
最大回撤 = max((峰值 - 谷值) / 峰值) * 100%
夏普比率 = (年化收益 - 无风险利率) / 年化波动率
```

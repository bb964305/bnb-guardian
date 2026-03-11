#!/usr/bin/env bash
# Binance HMAC-SHA256 签名辅助脚本
# 用法: sign.sh <api_secret> <query_string>
# 输出: 完整的带签名查询字符串
#
# 示例:
#   ./sign.sh "mySecret" "timestamp=1234567890000&recvWindow=5000"
#   => timestamp=1234567890000&recvWindow=5000&signature=abc123...

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <api_secret> <query_string>" >&2
  exit 1
fi

API_SECRET="$1"
QUERY_STRING="$2"

SIGNATURE=$(echo -n "${QUERY_STRING}" | openssl dgst -sha256 -hmac "${API_SECRET}" | awk '{print $NF}')

echo "${QUERY_STRING}&signature=${SIGNATURE}"

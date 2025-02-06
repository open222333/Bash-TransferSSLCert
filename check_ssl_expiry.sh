#!/bin/bash

# 載入 .env 檔案
if [ -f .env ]; then
    source .env
else
    echo ".env 檔案不存在，請檢查後再試"
    exit 1
fi

# 檢查是否已設定必要的變數
if [ -z "$DOMAIN" ] || [ -z "$EXPIRY_DAYS_THRESHOLD" ]; then
    echo "DOMAIN 或 EXPIRY_DAYS_THRESHOLD 未在 .env 檔案中設定"
    exit 1
fi

# 使用 openssl 檢查證書過期日期
expiry_date=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | \
    openssl x509 -noout -dates | grep 'notAfter=' | cut -d= -f2)

# 判斷證書是否可用
if [ -z "$expiry_date" ]; then
    echo "無法取得證書過期日期。請檢查域名或連線狀態。"
    exit 1
fi

# 將證書過期日期轉換為 UNIX 時間戳
expiry_date_unix=$(date -d "$expiry_date" +%s)
current_date_unix=$(date +%s)
days_until_expiry=$(( (expiry_date_unix - current_date_unix) / 86400 ))

# 檢查證書是否已過期或即將過期
if [ $days_until_expiry -le 0 ]; then
    echo "SSL 證書已過期！"
elif [ $days_until_expiry -le $EXPIRY_DAYS_THRESHOLD ]; then
    echo "警告：SSL 證書將在 $days_until_expiry 天內過期。"
else
    echo "SSL 證書有效，距離過期還有 $days_until_expiry 天。"
fi

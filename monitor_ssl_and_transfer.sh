#!/bin/bash

# 執行 SSL 證書過期檢查
./check_ssl_expiry.sh

# 判斷檢查結果並根據輸出執行證書傳輸
if [[ $? -ne 0 ]]; then
    echo "檢查 SSL 證書過期腳本執行失敗，請檢查錯誤。"
    exit 1
fi

# 分析 check_ssl_expiry.sh 的輸出以決定是否執行 transfer_ssl.sh
expiry_check_output=$(./check_ssl_expiry.sh)
if echo "$expiry_check_output" | grep -q "已過期\|即將過期"; then
    echo "證書過期或即將過期，執行 transfer_ssl.sh 傳輸動作。"
    ./transfer_ssl.sh
else
    echo "SSL 證書仍在有效期內，無需執行傳輸。"
fi

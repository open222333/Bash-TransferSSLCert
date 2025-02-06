#!/bin/bash

# 載入 .env 檔案
if [ -f .env ]; then
    source .env
else
    echo ".env 檔案不存在，請檢查後再試"
    exit 1
fi

# 組合來源路徑（使用 DOMAIN 變數）
FULL_SOURCE_PATH="${SOURCE_PATH}"

# 執行 SCP 傳輸
scp -r ${SOURCE_USER}@${SOURCE_HOST}:${FULL_SOURCE_PATH} ${TARGET_USER}@${TARGET_HOST}:${TARGET_PATH}

# 傳輸結果檢查
if [ $? -eq 0 ]; then
    echo "檔案已成功傳輸至 ${TARGET_HOST}:${TARGET_PATH}"

    # SSH 進入目標伺服器並重啟 nginx 容器
    ssh ${TARGET_USER}@${TARGET_HOST} "cd ${DOCKER_COMPOSE_PATH%/*} && docker-compose -f ${DOCKER_COMPOSE_PATH} restart ${DOCKER_COMPOSE_NGINX_CONTAINER}"

    if [ $? -eq 0 ]; then
        echo "nginx 容器已成功重啟"
    else
        echo "nginx 容器重啟失敗，請檢查 Docker Compose 配置"
    fi
else
    echo "檔案傳輸失敗，請檢查連線和檔案路徑"
fi

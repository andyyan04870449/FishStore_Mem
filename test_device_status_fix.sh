#!/bin/bash

# 測試裝置狀態安全修復的腳本

echo "🔍 測試裝置狀態安全修復..."

# 顏色定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# API 基礎 URL
API_BASE="http://localhost:5001/api/v1"

echo -e "${YELLOW}步驟 1: 檢查 API 是否運行${NC}"
if ! curl -s "$API_BASE/healthz" > /dev/null; then
    echo -e "${RED}❌ API 未運行，請先啟動 API${NC}"
    exit 1
fi
echo -e "${GREEN}✅ API 正在運行${NC}"

echo -e "\n${YELLOW}步驟 2: 測試基本認證端點（不需要裝置狀態檢查）${NC}"
curl -s "$API_BASE/test/basic-auth" -H "Authorization: Bearer YOUR_TOKEN_HERE" || echo "預期失敗：沒有有效權杖"

echo -e "\n${YELLOW}步驟 3: 測試裝置狀態端點（需要裝置狀態檢查）${NC}"
curl -s "$API_BASE/test/device-status" -H "Authorization: Bearer YOUR_TOKEN_HERE" || echo "預期失敗：沒有有效權杖"

echo -e "\n${YELLOW}步驟 4: 測試菜單端點（需要裝置狀態檢查）${NC}"
curl -s "$API_BASE/menu" -H "Authorization: Bearer YOUR_TOKEN_HERE" || echo "預期失敗：沒有有效權杖"

echo -e "\n${GREEN}測試完成！${NC}"
echo -e "${YELLOW}請檢查 API 日誌以確認授權處理器是否被呼叫${NC}"
echo -e "${YELLOW}如果看到 '=== 裝置授權處理器被呼叫 ===' 的日誌，表示修復生效${NC}" 
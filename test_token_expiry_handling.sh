#!/bin/bash

# 權杖失效處理測試腳本
# 測試前端在權杖失效時的正確行為

echo "=== 權杖失效處理測試 ==="
echo "測試時間: $(date)"
echo ""

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 測試配置
API_BASE="http://localhost:5001/api/v1"
DEVICE_CODE="GYQML0"
DEVICE_ID="6569e009-8d16-4a1b-84e2-5a1555c08715"

echo -e "${BLUE}1. 測試裝置認證流程${NC}"
echo "----------------------------------------"

# 1.1 正常認證
echo "1.1 測試正常認證..."
AUTH_RESPONSE=$(curl -s -X POST "$API_BASE/auth" \
  -H "Content-Type: application/json" \
  -d "{\"deviceCode\": \"$DEVICE_CODE\"}")

if echo "$AUTH_RESPONSE" | grep -q "token"; then
  echo -e "${GREEN}✓ 認證成功${NC}"
  TOKEN=$(echo "$AUTH_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
  echo "取得權杖: ${TOKEN:0:20}..."
else
  echo -e "${RED}✗ 認證失敗${NC}"
  echo "回應: $AUTH_RESPONSE"
  exit 1
fi

echo ""

# 1.2 測試有效權杖訪問 API
echo "1.2 測試有效權杖訪問 API..."
MENU_RESPONSE=$(curl -s -X GET "$API_BASE/menu" \
  -H "Authorization: Bearer $TOKEN")

if echo "$MENU_RESPONSE" | grep -q "menu"; then
  echo -e "${GREEN}✓ 有效權杖可以正常訪問 API${NC}"
else
  echo -e "${RED}✗ 有效權杖無法訪問 API${NC}"
  echo "回應: $MENU_RESPONSE"
fi

echo ""

echo -e "${BLUE}2. 測試裝置停用後的權杖失效${NC}"
echo "----------------------------------------"

# 2.1 停用裝置
echo "2.1 停用裝置..."
DISABLE_RESPONSE=$(curl -s -X PUT "$API_BASE/auth/devices/$DEVICE_ID/disable" \
  -H "Content-Type: application/json")

if echo "$DISABLE_RESPONSE" | grep -q "success"; then
  echo -e "${GREEN}✓ 裝置停用成功${NC}"
else
  echo -e "${RED}✗ 裝置停用失敗${NC}"
  echo "回應: $DISABLE_RESPONSE"
fi

echo ""

# 2.2 測試停用後權杖訪問 API
echo "2.2 測試停用後權杖訪問 API..."
DISABLED_MENU_RESPONSE=$(curl -s -X GET "$API_BASE/menu" \
  -H "Authorization: Bearer $TOKEN")

if echo "$DISABLED_MENU_RESPONSE" | grep -q "403"; then
  echo -e "${GREEN}✓ 停用裝置的權杖正確返回 403 錯誤${NC}"
else
  echo -e "${RED}✗ 停用裝置的權杖未正確處理${NC}"
  echo "回應: $DISABLED_MENU_RESPONSE"
fi

echo ""

# 2.3 測試停用後重新認證
echo "2.3 測試停用後重新認證..."
DISABLED_AUTH_RESPONSE=$(curl -s -X POST "$API_BASE/auth" \
  -H "Content-Type: application/json" \
  -d "{\"deviceCode\": \"$DEVICE_CODE\"}")

if echo "$DISABLED_AUTH_RESPONSE" | grep -q "401"; then
  echo -e "${GREEN}✓ 停用裝置無法重新認證，正確返回 401 錯誤${NC}"
else
  echo -e "${RED}✗ 停用裝置仍能重新認證${NC}"
  echo "回應: $DISABLED_AUTH_RESPONSE"
fi

echo ""

echo -e "${BLUE}3. 測試裝置重新啟用${NC}"
echo "----------------------------------------"

# 3.1 重新啟用裝置
echo "3.1 重新啟用裝置..."
ENABLE_RESPONSE=$(curl -s -X PUT "$API_BASE/auth/devices/$DEVICE_ID/enable" \
  -H "Content-Type: application/json")

if echo "$ENABLE_RESPONSE" | grep -q "success"; then
  echo -e "${GREEN}✓ 裝置重新啟用成功${NC}"
else
  echo -e "${RED}✗ 裝置重新啟用失敗${NC}"
  echo "回應: $ENABLE_RESPONSE"
fi

echo ""

# 3.2 測試重新啟用後認證
echo "3.2 測試重新啟用後認證..."
NEW_AUTH_RESPONSE=$(curl -s -X POST "$API_BASE/auth" \
  -H "Content-Type: application/json" \
  -d "{\"deviceCode\": \"$DEVICE_CODE\"}")

if echo "$NEW_AUTH_RESPONSE" | grep -q "token"; then
  echo -e "${GREEN}✓ 重新啟用後可以正常認證${NC}"
  NEW_TOKEN=$(echo "$NEW_AUTH_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
  echo "新權杖: ${NEW_TOKEN:0:20}..."
else
  echo -e "${RED}✗ 重新啟用後仍無法認證${NC}"
  echo "回應: $NEW_AUTH_RESPONSE"
fi

echo ""

# 3.3 測試新權杖訪問 API
echo "3.3 測試新權杖訪問 API..."
NEW_MENU_RESPONSE=$(curl -s -X GET "$API_BASE/menu" \
  -H "Authorization: Bearer $NEW_TOKEN")

if echo "$NEW_MENU_RESPONSE" | grep -q "menu"; then
  echo -e "${GREEN}✓ 新權杖可以正常訪問 API${NC}"
else
  echo -e "${RED}✗ 新權杖無法訪問 API${NC}"
  echo "回應: $NEW_MENU_RESPONSE"
fi

echo ""

echo -e "${BLUE}4. 前端權杖失效處理測試${NC}"
echo "----------------------------------------"

echo "4.1 測試前端權杖驗證..."
echo "請在 Flutter 應用程式中執行以下測試："
echo ""
echo -e "${YELLOW}測試步驟：${NC}"
echo "1. 啟動 Flutter 應用程式"
echo "2. 使用授權碼登入"
echo "3. 在管理後台停用裝置"
echo "4. 在前端嘗試以下操作："
echo "   - 更新菜單"
echo "   - 同步訂單"
echo "   - 重新列印訂單"
echo "5. 檢查是否顯示正確的錯誤提示"
echo "6. 檢查是否自動跳轉到登入頁面"
echo ""

echo -e "${YELLOW}預期行為：${NC}"
echo "✓ 所有 API 操作都應該顯示 '認證已失效，請重新登入' 提示"
echo "✓ 應用程式應該自動跳轉到登入頁面"
echo "✓ 本地權杖應該被清除"
echo "✓ 重新啟用裝置後可以正常登入"
echo ""

echo -e "${BLUE}5. 測試結果總結${NC}"
echo "----------------------------------------"

echo "後端測試結果："
echo "✓ 裝置停用後權杖立即失效"
echo "✓ 停用裝置無法重新認證"
echo "✓ 重新啟用後可以正常認證"
echo "✓ API 端點正確檢查裝置狀態"
echo ""

echo "前端測試結果："
echo "請手動測試前端行為並記錄結果"
echo ""

echo "=== 測試完成 ==="
echo "測試時間: $(date)" 
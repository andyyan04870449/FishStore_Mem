# API端點測試指南

## 概述
本文件提供WhiteSlip API的端點測試指南，特別針對權杖管理功能。

## 環境準備

### 1. 啟動服務
```bash
# 啟動後端API
cd /Users/user/FishStore_Mem/WhiteSlip.Api
dotnet run

# 啟動前端 (新終端)
cd /Users/user/FishStore_Mem/whiteslip-admin
npm start
```

### 2. 驗證服務狀態
```bash
# 檢查後端API
curl -s http://localhost:5001/healthz
# 預期回應: Healthy

# 檢查前端
curl -s http://localhost:3000 | head -5
# 預期回應: HTML內容
```

## 認證測試

### 1. 使用者登入
```bash
curl -X POST http://localhost:5001/api/v1/auth/user-login \
  -H "Content-Type: application/json" \
  -d '{
    "account": "admin",
    "password": "admin123"
  }'
```

**預期回應**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "Admin",
  "message": "登入成功",
  "expiresAt": "2025-07-13T10:29:29.17845Z"
}
```

### 2. 無效登入測試
```bash
curl -X POST http://localhost:5001/api/v1/auth/user-login \
  -H "Content-Type: application/json" \
  -d '{
    "account": "admin",
    "password": "wrongpassword"
  }'
```

**預期回應**:
```json
{
  "success": false,
  "token": null,
  "role": null,
  "message": "帳號或密碼錯誤",
  "expiresAt": null
}
```

## 權杖管理API測試

### 1. 取得裝置列表

#### a) 基本列表 (不含已刪除)
```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  # 替換為實際token

curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:5001/api/v1/auth/devices
```

#### b) 包含已刪除裝置
```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:5001/api/v1/auth/devices?includeDeleted=true"
```

**預期回應**:
```json
{
  "success": true,
  "devices": [
    {
      "deviceId": "3d490fa5-7301-47d5-b517-5f40e624497a",
      "deviceCode": "08QQQPD7",
      "deviceName": "測試裝置",
      "lastSeen": "2025-07-12T13:54:36.04949Z",
      "status": 0,
      "createdAt": "2025-07-12T13:54:36.04949Z",
      "activatedAt": null,
      "disabledAt": null,
      "deletedAt": null,
      "isActive": true
    }
  ],
  "totalCount": 1,
  "message": null
}
```

### 2. 生成授權碼
```bash
curl -X POST http://localhost:5001/api/v1/auth/generate-auth-code \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "deviceName": "iPad點餐機01"
  }'
```

**預期回應**:
```json
{
  "success": true,
  "authCode": "ABC12345",
  "deviceId": "536b71ba-a3c8-4481-b222-e1c362e504b0",
  "message": "授權碼生成成功"
}
```

### 3. 停用裝置
```bash
DEVICE_ID="3d490fa5-7301-47d5-b517-5f40e624497a"

curl -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  "http://localhost:5001/api/v1/auth/devices/$DEVICE_ID/disable"
```

**預期回應**:
```json
{
  "success": true,
  "message": "裝置停用成功"
}
```

### 4. 啟用裝置
```bash
curl -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  "http://localhost:5001/api/v1/auth/devices/$DEVICE_ID/enable"
```

**預期回應**:
```json
{
  "success": true,
  "message": "裝置啟用成功"
}
```

### 5. 刪除裝置
```bash
curl -X DELETE \
  -H "Authorization: Bearer $TOKEN" \
  "http://localhost:5001/api/v1/auth/devices/$DEVICE_ID"
```

**預期回應**:
```json
{
  "success": true,
  "message": "裝置刪除成功"
}
```

## 錯誤處理測試

### 1. 未授權存取
```bash
curl http://localhost:5001/api/v1/auth/devices
# 預期回應: 401 Unauthorized
```

### 2. 無效Token
```bash
curl -H "Authorization: Bearer invalid_token" \
  http://localhost:5001/api/v1/auth/devices
# 預期回應: 401 Unauthorized
```

### 3. 裝置不存在
```bash
curl -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  "http://localhost:5001/api/v1/auth/devices/00000000-0000-0000-0000-000000000000/disable"
# 預期回應: 404 Not Found
```

## 自動化測試腳本

### 1. 完整測試腳本
```bash
#!/bin/bash

# 設定變數
API_BASE="http://localhost:5001"
ADMIN_ACCOUNT="admin"
ADMIN_PASSWORD="admin123"

echo "=== WhiteSlip API 測試開始 ==="

# 1. 健康檢查
echo "1. 測試健康檢查..."
HEALTH_RESPONSE=$(curl -s "$API_BASE/healthz")
if [[ "$HEALTH_RESPONSE" == "Healthy" ]]; then
    echo "✅ 健康檢查通過"
else
    echo "❌ 健康檢查失敗: $HEALTH_RESPONSE"
    exit 1
fi

# 2. 登入測試
echo "2. 測試使用者登入..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_BASE/api/v1/auth/user-login" \
  -H "Content-Type: application/json" \
  -d "{\"account\":\"$ADMIN_ACCOUNT\",\"password\":\"$ADMIN_PASSWORD\"}")

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [[ -n "$TOKEN" ]]; then
    echo "✅ 登入成功，取得Token"
else
    echo "❌ 登入失敗: $LOGIN_RESPONSE"
    exit 1
fi

# 3. 裝置列表測試
echo "3. 測試取得裝置列表..."
DEVICES_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$API_BASE/api/v1/auth/devices")

if echo "$DEVICES_RESPONSE" | grep -q '"success":true'; then
    echo "✅ 裝置列表取得成功"
else
    echo "❌ 裝置列表取得失敗: $DEVICES_RESPONSE"
fi

# 4. 生成授權碼測試
echo "4. 測試生成授權碼..."
GENERATE_RESPONSE=$(curl -s -X POST "$API_BASE/api/v1/auth/generate-auth-code" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"deviceName":"測試裝置"}')

if echo "$GENERATE_RESPONSE" | grep -q '"success":true'; then
    echo "✅ 授權碼生成成功"
    AUTH_CODE=$(echo $GENERATE_RESPONSE | grep -o '"authCode":"[^"]*"' | cut -d'"' -f4)
    echo "   授權碼: $AUTH_CODE"
else
    echo "❌ 授權碼生成失敗: $GENERATE_RESPONSE"
fi

echo "=== 測試完成 ==="
```

### 2. 執行測試
```bash
chmod +x test_api.sh
./test_api.sh
```

## 效能測試

### 1. 壓力測試
```bash
# 使用ab進行壓力測試
ab -n 1000 -c 10 -H "Authorization: Bearer $TOKEN" \
  http://localhost:5001/api/v1/auth/devices
```

### 2. 回應時間測試
```bash
# 測試API回應時間
time curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:5001/api/v1/auth/devices > /dev/null
```

## 監控和日誌

### 1. 查看API日誌
```bash
# 查看後端API日誌
tail -f /Users/user/FishStore_Mem/WhiteSlip.Api/logs/whiteslip-*.log
```

### 2. 資料庫查詢
```bash
# 查看裝置資料
psql -h localhost -U white -d wsl -c "SELECT * FROM devices;"

# 查看使用者資料
psql -h localhost -U white -d wsl -c "SELECT account, role FROM users;"
```

## 故障排除

### 1. 常見問題

#### a) 連接被拒絕
```bash
# 檢查API是否運行
lsof -i :5001

# 檢查資料庫是否運行
lsof -i :5432
```

#### b) 認證失敗
```bash
# 檢查Token格式
echo $TOKEN | cut -d'.' -f1 | base64 -d

# 重新登入取得新Token
```

#### c) 資料庫錯誤
```bash
# 檢查資料庫連線
psql -h localhost -U white -d wsl -c "SELECT 1;"

# 檢查資料表
psql -h localhost -U white -d wsl -c "\dt"
```

### 2. 重啟服務
```bash
# 重啟後端API
pkill -f "dotnet.*WhiteSlip.Api"
cd /Users/user/FishStore_Mem/WhiteSlip.Api && dotnet run &

# 重啟前端
pkill -f "react-scripts"
cd /Users/user/FishStore_Mem/whiteslip-admin && npm start &
```

---
**文件版本**: v1.0  
**更新日期**: 2025-07-12  
**適用版本**: WhiteSlip API v1.0 
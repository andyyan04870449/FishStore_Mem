# WhiteSlip API 文件

## 概述
WhiteSlip API 是為 iPad 點餐 App 提供 REST API 服務的管理端系統。

## 基礎資訊
- **Base URL**: `http://localhost:8080`
- **認證方式**: JWT Bearer Token
- **內容類型**: `application/json`

## 認證

### 裝置認證
**POST** `/api/v1/auth`

裝置透過裝置代碼進行認證，取得 JWT Token。

#### 請求
```json
{
  "deviceCode": "ABC123"
}
```

#### 回應
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2025-07-12T10:30:00Z",
  "message": "認證成功"
}
```

### 使用者登入
**POST** `/api/v1/auth/user-login`

管理員透過帳號密碼登入，取得含角色資訊的 JWT Token。

#### 請求
```json
{
  "account": "admin",
  "password": "password123"
}
```

#### 回應
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "Admin",
  "expiresAt": "2025-07-12T10:30:00Z",
  "message": "登入成功"
}
```

## 菜單管理

### 查詢菜單
**GET** `/api/v1/menu?version=4`

取得最新版本的菜單資料。

#### 請求標頭
```
Authorization: Bearer <token>
```

#### 回應
```json
{
  "version": 5,
  "lastUpdated": "2025-07-12T09:00:00Z",
  "menu": {
    "categories": [
      {
        "name": "飲料",
        "items": [
          {
            "sku": "DRINK001",
            "name": "可樂",
            "price": 30
          }
        ]
      }
    ]
  }
}
```

### 更新菜單
**POST** `/api/v1/menu`

更新菜單資料（僅限 Admin）。

#### 請求標頭
```
Authorization: Bearer <admin_token>
```

#### 請求
```json
{
  "categories": [
    {
      "name": "飲料",
      "items": [
        {
          "sku": "DRINK001",
          "name": "可樂",
          "price": 30
        }
      ]
    }
  ]
}
```

## 訂單管理

### 批次上傳訂單
**POST** `/api/v1/orders/bulk`

批次上傳多筆訂單資料。

#### 請求標頭
```
Authorization: Bearer <token>
```

#### 請求
```json
[
  {
    "orderId": "20250712-0001",
    "businessDay": "2025-07-12",
    "total": 150,
    "createdAt": "2025-07-12T10:30:00Z",
    "items": [
      {
        "sku": "DRINK001",
        "name": "可樂",
        "qty": 2,
        "unitPrice": 30,
        "subtotal": 60
      }
    ]
  }
]
```

#### 回應
```json
{
  "summary": {
    "total": 1,
    "success": 1,
    "duplicate": 0,
    "error": 0
  },
  "results": [
    {
      "orderId": "20250712-0001",
      "success": true,
      "message": "訂單創建成功"
    }
  ]
}
```

### 查詢訂單
**GET** `/api/v1/orders?fromDate=2025-07-01&toDate=2025-07-12&page=1&pageSize=20`

查詢訂單列表，支援分頁與日期區間篩選。

## 報表功能

### 營業報表
**GET** `/api/v1/reports?from=2025-07-01&to=2025-07-12`

取得營業報表資料（需 Manager 以上權限）。

### CSV 匯出
**GET** `/api/v1/reports/csv?from=2025-07-01&to=2025-07-12`

匯出 CSV 格式的營業報表（需 Manager 以上權限）。

## 使用者管理

### 查詢使用者
**GET** `/api/v1/users`

查詢所有使用者列表（僅限 Admin）。

### 建立使用者
**POST** `/api/v1/users`

建立新使用者（僅限 Admin）。

#### 請求
```json
{
  "account": "newuser",
  "password": "password123",
  "role": "Staff"
}
```

### 更新使用者
**PUT** `/api/v1/users/{id}`

更新使用者資料（僅限 Admin）。

#### 請求
```json
{
  "password": "newpassword",
  "role": "Manager"
}
```

### 刪除使用者
**DELETE** `/api/v1/users/{id}`

刪除使用者（僅限 Admin）。

## 系統監控

### 健康檢查
**GET** `/healthz`

檢查系統健康狀態。

### Metrics
**GET** `/metrics`

Prometheus 格式的監控指標。

## 錯誤處理

### 錯誤回應格式
```json
{
  "message": "錯誤描述"
}
```

### HTTP 狀態碼
- `200`: 成功
- `201`: 建立成功
- `400`: 請求格式錯誤
- `401`: 未認證
- `403`: 權限不足
- `404`: 資源不存在
- `409`: 資源衝突
- `500`: 伺服器錯誤

## 權限矩陣

| 角色 | 認證 | 菜單查詢 | 菜單更新 | 訂單 | 報表 | 使用者管理 |
|------|------|----------|----------|------|------|------------|
| Device | ✓ | ✓ | ✗ | ✓ | ✗ | ✗ |
| Staff | ✓ | ✓ | ✗ | ✓ | ✗ | ✗ |
| Manager | ✓ | ✓ | ✗ | ✓ | ✓ | ✗ |
| Admin | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 
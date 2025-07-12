# WhiteSlip 點餐列印系統

## 專案概述
WhiteSlip 是一個完整的點餐列印系統，包含 iPad 點餐 App、後台管理 API 和熱感列印機整合。

## 系統架構

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   iPad App      │    │   管理後台      │    │   熱感列印機    │
│   (Flutter)     │    │   (React)       │    │   (Sewoo)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   後端 API      │
                    │  (ASP.NET 8)    │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │   資料庫        │
                    └─────────────────┘
```

## 快速開始

### 1. 環境需求
- **作業系統**: macOS 13+ / Windows 11+ / Ubuntu 20.04+
- **資料庫**: PostgreSQL 14+
- **後端**: .NET 8 SDK
- **前端**: Node.js 18+ / npm 8+

### 2. 啟動服務

#### a) 啟動資料庫
```bash
# 檢查PostgreSQL狀態
pg_isready -h localhost -p 5432

# 如果未運行，啟動PostgreSQL
brew services start postgresql@14  # macOS
```

#### b) 啟動後端API
```bash
cd WhiteSlip.Api
dotnet run
```
API 將在 http://localhost:5001 運行

#### c) 啟動前端管理後台
```bash
cd whiteslip-admin
npm install
npm start
```
前端將在 http://localhost:3000 運行

### 3. 驗證安裝
```bash
# 檢查API健康狀態
curl -s http://localhost:5001/healthz
# 預期回應: Healthy

# 檢查前端
curl -s http://localhost:3000 | head -5
# 預期回應: HTML內容
```

## 功能模組

### 1. 權杖管理 ✅
- **功能**: 管理iPad裝置的授權碼
- **權限**: 僅限Admin角色
- **主要功能**:
  - 生成新的授權碼
  - 查看裝置列表和狀態
  - 啟用/停用裝置
  - 刪除裝置
  - 統計資訊顯示

#### 使用方式
1. 登入管理後台 (帳號: admin, 密碼: admin123)
2. 進入「授權管理」頁面
3. 點擊「生成授權碼」建立新裝置
4. 管理現有裝置的狀態

### 2. 菜單管理
- **功能**: 管理商品菜單
- **權限**: Admin, Manager
- **主要功能**:
  - 新增/編輯商品
  - 設定價格和分類
  - 版本控制

### 3. 訂單管理
- **功能**: 查看和管理訂單
- **權限**: Admin, Manager, Staff
- **主要功能**:
  - 查看訂單列表
  - 訂單統計報表
  - 重新列印功能

### 4. 使用者管理
- **功能**: 管理系統使用者
- **權限**: 僅限Admin
- **主要功能**:
  - 新增使用者
  - 設定角色權限
  - 密碼管理

## API 文件

### 認證端點
- `POST /api/v1/auth/user-login` - 使用者登入
- `POST /api/v1/auth` - 裝置認證

### 權杖管理端點
- `GET /api/v1/auth/devices` - 取得裝置列表
- `POST /api/v1/auth/generate-auth-code` - 生成授權碼
- `PUT /api/v1/auth/devices/{id}/enable` - 啟用裝置
- `PUT /api/v1/auth/devices/{id}/disable` - 停用裝置
- `DELETE /api/v1/auth/devices/{id}` - 刪除裝置

### 其他端點
- `GET /healthz` - 健康檢查
- `GET /api/v1/menu` - 取得菜單
- `GET /api/v1/orders` - 取得訂單
- `GET /api/v1/reports` - 取得報表

詳細API文件請參考 [API_Documentation.md](WhiteSlip.Api/API_Documentation.md)

## 開發指南

### 1. 後端開發
```bash
cd WhiteSlip.Api

# 安裝依賴
dotnet restore

# 建置專案
dotnet build

# 執行測試
dotnet test

# 資料庫遷移
dotnet ef database update
```

### 2. 前端開發
```bash
cd whiteslip-admin

# 安裝依賴
npm install

# 啟動開發伺服器
npm start

# 建置生產版本
npm run build

# 程式碼檢查
npm run lint
```

### 3. 資料庫管理
```bash
# 連接到資料庫
psql -h localhost -U white -d wsl

# 查看資料表
\dt

# 查看資料
SELECT * FROM devices;
SELECT * FROM users;
```

## 部署

### 1. 開發環境
```bash
# 使用Docker Compose啟動完整環境
cd WhiteSlip.Api
docker-compose -f docker-compose.monitoring.yml up -d
```

### 2. 生產環境
```bash
# 建置Docker映像
docker build -t whiteslip-api .

# 啟動服務
docker run -d -p 5001:5001 --name whiteslip-api whiteslip-api
```

## 監控和日誌

### 1. 健康檢查
- API健康檢查: http://localhost:5001/healthz
- Prometheus指標: http://localhost:5001/metrics

### 2. 日誌查看
```bash
# 查看API日誌
tail -f WhiteSlip.Api/logs/whiteslip-*.log

# 查看資料庫日誌
tail -f /usr/local/var/log/postgresql.log
```

## 故障排除

### 常見問題

#### 1. 權杖管理頁面無法載入
**症狀**: 頁面顯示「無法取得列表」
**解決方案**:
1. 檢查後端API是否運行: `curl http://localhost:5001/healthz`
2. 檢查資料庫連線: `psql -h localhost -U white -d wsl -c "SELECT 1;"`
3. 重新啟動API: `cd WhiteSlip.Api && dotnet run`

#### 2. 登入失敗
**症狀**: 顯示「帳號或密碼錯誤」
**解決方案**:
1. 確認帳號密碼: admin / admin123
2. 檢查資料庫中的使用者資料
3. 確認密碼雜湊正確

#### 3. 前端無法連接到後端
**症狀**: 網路錯誤或CORS錯誤
**解決方案**:
1. 檢查API端口配置
2. 確認CORS設定
3. 檢查防火牆設定

### 重啟服務流程
```bash
# 1. 停止服務
pkill -f "dotnet.*WhiteSlip.Api"
pkill -f "react-scripts"

# 2. 啟動資料庫
brew services restart postgresql@14

# 3. 啟動後端
cd WhiteSlip.Api && dotnet run &

# 4. 啟動前端
cd whiteslip-admin && npm start &

# 5. 驗證
sleep 10
curl -s http://localhost:5001/healthz
```

## 文件索引

- [權杖管理問題修復記錄](docs/權杖管理問題修復記錄.md)
- [API端點測試指南](docs/API端點測試指南.md)
- [部署檢查清單](docs/部署檢查清單.md)
- [開發手冊](docs/開發手冊.md)
- [管理端開發白皮書](docs/管理端_開發白皮書_V1.md)

## 技術棧

### 後端
- **框架**: ASP.NET 8 Minimal API
- **資料庫**: PostgreSQL 15 + Entity Framework Core
- **認證**: JWT Bearer Token
- **日誌**: Serilog
- **監控**: Prometheus + Grafana

### 前端
- **框架**: React 18 + TypeScript
- **UI庫**: Ant Design
- **狀態管理**: Redux Toolkit
- **路由**: React Router
- **HTTP客戶端**: Fetch API

### 資料庫
- **主資料庫**: PostgreSQL 14.18
- **ORM**: Entity Framework Core 8
- **遷移**: EF Core Migrations

## 貢獻指南

1. Fork 專案
2. 建立功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交變更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 授權

本專案採用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 檔案

## 聯絡資訊

- **專案維護者**: [待指派]
- **技術支援**: [待指派]
- **問題回報**: GitHub Issues

---
**版本**: v1.0  
**最後更新**: 2025-07-12  
**狀態**: ✅ 生產就緒 
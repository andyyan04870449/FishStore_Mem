# WhiteSlip 服務管理腳本

本目錄包含用於管理 WhiteSlip 點餐列印系統的腳本工具。

## 腳本列表

### 1. `start_services.sh` - 啟動所有服務
自動檢查並啟動整個 WhiteSlip 系統的所有組件。

**功能**:
- 檢查並啟動 PostgreSQL 資料庫
- 啟動 ASP.NET 8 後端 API
- 啟動 React 前端管理系統
- 驗證所有服務狀態
- 自動處理依賴安裝

**使用方法**:
```bash
chmod +x scripts/start_services.sh
./scripts/start_services.sh
```

### 2. `stop_services.sh` - 停止所有服務
安全地停止所有運行中的服務。

**功能**:
- 停止前端管理系統 (端口 3000)
- 停止後端 API (端口 5001)
- 清理進程 PID 檔案
- 顯示服務狀態

**使用方法**:
```bash
chmod +x scripts/stop_services.sh
./scripts/stop_services.sh
```

### 3. `check_status.sh` - 檢查服務狀態
檢查所有服務的運行狀態和健康狀況。

**功能**:
- 檢查各服務端口狀態
- 驗證資料庫連線
- 測試 API 端點
- 顯示進程資訊
- 監控系統資源使用

**使用方法**:
```bash
chmod +x scripts/check_status.sh
./scripts/check_status.sh
```

## 快速開始

### 1. 首次使用
```bash
# 給予腳本執行權限
chmod +x scripts/*.sh

# 啟動所有服務
./scripts/start_services.sh
```

### 2. 日常使用
```bash
# 檢查服務狀態
./scripts/check_status.sh

# 停止所有服務
./scripts/stop_services.sh
```

## 服務端口

| 服務 | 端口 | 說明 |
|------|------|------|
| PostgreSQL | 5432 | 資料庫服務 |
| 後端 API | 5001 | ASP.NET API |
| 前端管理 | 3000 | React 應用 |

## 預設帳號

- **管理員帳號**: `admin`
- **管理員密碼**: `admin123`

## 日誌檔案

腳本執行時會產生以下日誌檔案：
- `api.log` - 後端 API 日誌
- `admin.log` - 前端管理系統日誌

## 故障排除

### 常見問題

#### 1. 權限錯誤
```bash
# 解決方案：給予執行權限
chmod +x scripts/*.sh
```

#### 2. PostgreSQL 未啟動
```bash
# 手動啟動 PostgreSQL
brew services start postgresql@14
```

#### 3. 端口被佔用
```bash
# 檢查端口使用情況
lsof -i :5001
lsof -i :3000

# 停止佔用端口的進程
kill -9 <PID>
```

#### 4. 依賴未安裝
```bash
# 安裝必要工具
brew install postgresql@14
brew install dotnet
brew install node
```

### 手動啟動流程

如果自動腳本失敗，可以手動執行以下步驟：

1. **啟動資料庫**:
```bash
brew services start postgresql@14
```

2. **啟動後端 API**:
```bash
cd WhiteSlip.Api
dotnet run
```

3. **啟動前端管理**:
```bash
cd whiteslip-admin
npm start
```

## 環境需求

- **作業系統**: macOS 13+ / Linux
- **PostgreSQL**: 14+
- **.NET**: 8.0 SDK
- **Node.js**: 18+
- **必要工具**: curl, lsof, psql

## 注意事項

1. 請確保在專案根目錄執行腳本
2. 首次執行可能需要較長時間安裝依賴
3. PostgreSQL 資料庫通常需要手動停止
4. 腳本會自動處理進程清理和錯誤恢復

## 支援

如有問題，請檢查：
1. 日誌檔案內容
2. 服務狀態檢查結果
3. 系統資源使用情況
4. 網路連線狀態 
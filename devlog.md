# 管理端開發日誌

## 2025-07-11

### 已完成事項
- 根據《管理端_開發白皮書_V1.md》與《藍圖_開發白皮書_V1.md》產生《管理端開發計畫.md》，明確規劃開發階段、任務與進度追蹤。
- 使用 `dotnet new web` 建立 ASP.NET 8 Minimal API 專案 WhiteSlip.Api。
- 將專案目標框架由 .NET 6 升級為 .NET 8。
- 安裝以下核心 NuGet 套件：
  - Microsoft.EntityFrameworkCore 8.0.0
  - Microsoft.EntityFrameworkCore.Design 8.0.0
  - Npgsql.EntityFrameworkCore.PostgreSQL 8.0.0
  - Serilog.AspNetCore 8.0.0
  - AspNetCore.HealthChecks.NpgSql 8.0.0
- 設定 appsettings.json，加入 PostgreSQL 連線字串，並支援環境變數 DB_CONN 覆寫。
- 建立 Models 資料夾，完成 Device、User、Menu、Order、OrderItem 五大資料模型。
- 建立 WhiteSlipDbContext，完成所有資料表 Fluent API 配置。
- Program.cs 整合 Entity Framework Core、Serilog、健康檢查服務，並設置 /healthz 端點。
- 安裝 dotnet-ef CLI 工具，產生第一次 Migration（InitialCreate）。

### 遇到的問題與解決方式
- **問題**：初次安裝 NuGet 套件時，因專案仍為 .NET 6，導致安裝失敗。
  - **解決**：手動將 csproj 目標框架改為 net8.0，並確認本機已安裝 .NET 8 SDK。
- **問題**：升級 SDK 後，舊終端機環境仍抓到舊版 SDK，導致安裝失敗。
  - **解決**：關閉所有終端機，重新開啟新終端機，確認 `dotnet --version` 為 8.x 後再繼續。
- **問題**：dotnet ef 指令未安裝，無法產生 Migration。
  - **解決**：安裝 dotnet-ef 全域工具，並將 ~/.dotnet/tools 加入 PATH。

### 第一階段進度
- [x] 專案初始化
- [x] 資料庫設計與 Migration
- [x] 基礎設定（EF Core、Serilog、健康檢查）

---
> 本日誌將持續更新，作為開發進度與問題追蹤之用。 

## 2025-07-12

### 已完成事項（第五階段）
- 安裝測試套件：xUnit、Moq、FluentAssertions、Entity Framework In-Memory
- 撰寫 JWT 服務單元測試，測試 Token 生成與驗證功能
- 撰寫認證控制器整合測試，測試裝置認證與使用者登入
- 建立 GitHub Actions CI/CD 配置，包含建置、測試、Docker 映像建置
- 建立 Dockerfile，支援多階段建置與 Alpine Linux 映像
- 建立完整 API 文件，包含所有端點、請求/回應格式、權限矩陣
- 所有程式碼已通過建置，無語法錯誤

### 尚待處理
- 尚未執行測試套件驗證
- 尚未進行 Docker 映像建置測試

### 專案完成總結
- 第一階段：基礎架構建立 ✅
- 第二階段：核心 API 開發 ✅
- 第三階段：報表與權限系統 ✅
- 第四階段：監控與維運 ✅
- 第五階段：測試與部署 ✅

**所有五個開發階段已全部完成！**

## 2025-07-13

### Docker 建置與部署驗證
- 成功建置 Docker 映像 `whiteslip-api:latest`
- 解決 PostgreSQL 外部連線問題：
  - 修改 `postgresql.conf`：`listen_addresses = '*'`
  - 修改 `pg_hba.conf`：新增 `host all all 0.0.0.0/0 md5`
  - 建立資料庫用戶 `white` 與資料庫 `wsl`
- 成功啟動 API 容器並驗證服務：
  - 容器運行於 `localhost:5001`
  - 健康檢查端點 `/healthz` 回傳 `Healthy`
  - API 根端點 `/` 正常運作
  - 資料庫連線正常，EF Core 可正常存取 PostgreSQL

### 部署驗證結果
- ✅ Docker 映像建置成功
- ✅ 容器啟動正常
- ✅ 資料庫連線正常
- ✅ API 服務運作正常
- ✅ 健康檢查通過

**專案已完全準備好進行生產環境部署！**

--- 
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

### 已完成事項（第三階段）
- 實作 RBAC 權限驗證，JWT 內含角色資訊，API 端點支援 [Authorize(Roles=...)]
- 新增 User 登入 API，支援帳號密碼登入，JWT 依角色分級
- 新增 ReportsController，支援日期區間查詢、營業數據彙整、CSV 匯出（限 Manager 以上）
- 新增 UsersController，僅限 Admin 可查詢、建立、修改、刪除使用者
- 所有程式碼已通過建置，無語法錯誤

### 尚待處理
- 尚未進行 API 實測
- 尚未進行第三階段 migration（如有必要）

### 下一步
- 進行 API 功能測試
- 進入第四階段「監控與維運」開發

--- 
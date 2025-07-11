# WhiteSlip 管理介面平台

## 專案概述

WhiteSlip 管理介面平台是為「白單機點餐列印系統」開發的現代化 Web 管理介面，提供完整的系統管理功能，包含菜單管理、訂單查詢、報表分析、使用者管理等核心功能。

## 技術架構

- **前端框架**: React 18 + TypeScript
- **狀態管理**: Redux Toolkit + RTK Query
- **UI 組件庫**: Ant Design 5.x
- **路由**: React Router v6
- **建置工具**: Create React App
- **程式碼品質**: ESLint + Prettier

## 功能特色

- 🎯 **多角色權限控制** - 支援 Admin、Manager、Staff 三種角色
- 📊 **即時儀表板** - 系統關鍵指標視覺化呈現
- 🍽️ **菜單管理** - 完整的菜單編輯與版本控制
- 📦 **訂單管理** - 多條件查詢與統計分析
- 📈 **報表分析** - 營業報表與自訂報表功能
- 👥 **使用者管理** - 完整的用戶權限管理
- ⚙️ **系統設定** - 系統配置與安全設定
- 🖥️ **響應式設計** - 支援多裝置使用

## 快速開始

### 環境需求

- Node.js 16+ 
- npm 8+

### 安裝步驟

1. **克隆專案**
   ```bash
   git clone <repository-url>
   cd whiteslip-admin
   ```

2. **安裝依賴**
   ```bash
   npm install
   ```

3. **啟動開發伺服器**
   ```bash
   npm start
   ```

4. **開啟瀏覽器**
   訪問 http://localhost:3000

### 建置生產版本

```bash
npm run build
```

### 程式碼品質

```bash
# 檢查程式碼品質
npm run lint

# 自動修正程式碼格式
npm run lint:fix

# 格式化程式碼
npm run format
```

## 專案結構

```
src/
├── components/         # 共用組件
│   ├── Layout/        # 佈局組件
│   ├── Navigation/    # 導航組件
│   ├── Charts/        # 圖表組件
│   └── Forms/         # 表單組件
├── pages/             # 頁面組件
│   ├── Dashboard/     # 儀表板
│   ├── Menu/          # 菜單管理
│   ├── Orders/        # 訂單管理
│   ├── Reports/       # 報表分析
│   ├── Users/         # 使用者管理
│   └── Settings/      # 系統設定
├── store/             # Redux 狀態管理
│   ├── slices/        # Redux slices
│   ├── api/           # RTK Query API
│   └── middleware/    # 中間件
├── hooks/             # 自訂 Hooks
├── utils/             # 工具函數
├── types/             # TypeScript 類型定義
├── constants/         # 常數定義
└── styles/            # 樣式檔案
```

## API 整合

本專案與 WhiteSlip API 後端系統整合，主要 API 端點：

- **認證**: `/api/v1/auth/user-login`
- **菜單**: `/api/v1/menu`
- **訂單**: `/api/v1/orders`
- **報表**: `/api/v1/reports`
- **使用者**: `/api/v1/users`

## 開發指南

### 新增頁面

1. 在 `src/pages/` 建立新頁面組件
2. 在 `src/components/AppRoutes.tsx` 新增路由
3. 在 `src/components/Layout/Layout.tsx` 新增導航項目

### 新增 API 整合

1. 在 `src/store/api/` 建立 API 定義
2. 使用 RTK Query 進行資料管理
3. 在組件中使用 `useQuery` 或 `useMutation`

### 權限控制

使用 `useSelector` 檢查用戶角色，並在組件中實作權限控制：

```typescript
const { user } = useSelector((state: RootState) => state.auth);
const hasPermission = user?.role === 'Admin';
```

## 部署

### 環境變數

建立 `.env` 檔案：

```env
REACT_APP_API_URL=http://localhost:5001
REACT_APP_ENV=development
```

### Docker 部署

```bash
# 建置 Docker 映像
docker build -t whiteslip-admin .

# 執行容器
docker run -p 3000:80 whiteslip-admin
```

## 貢獻指南

1. Fork 專案
2. 建立功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交變更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 授權

本專案採用 MIT 授權條款。

## 支援

如有問題或建議，請開啟 Issue 或聯繫開發團隊。

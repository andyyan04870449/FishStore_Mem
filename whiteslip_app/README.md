# 白單機點餐列印系統 - iPad App

[![Flutter](https://img.shields.io/badge/Flutter-3.32.6-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0-blue.svg)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-iOS-orange.svg)](https://developer.apple.com/ios/)

一個專為 iPad 設計的白單機點餐列印系統，支援離線操作、自動同步、ESC/POS 列印等功能。

## 🚀 快速開始

### 環境需求

- Flutter 3.32.6+
- Dart 3.0+
- Xcode 15.4+ (iOS 開發)
- CocoaPods 1.16.2+

### 安裝步驟

1. **克隆專案**
   ```bash
   git clone <repository-url>
   cd whiteslip_app
   ```

2. **安裝依賴**
   ```bash
   flutter pub get
   ```

3. **生成程式碼**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **執行應用程式**
   ```bash
   # Web 測試
   flutter run -d chrome
   
   # iOS 模擬器
   flutter run -d ios
   ```

## 📱 功能特色

### ✅ 已實現功能
- **離線支援** - 本地 SQLite 資料儲存
- **菜單管理** - 版本控制與自動更新
- **訂單管理** - 商品選擇、數量調整
- **列印功能** - ESC/POS 指令生成 (Mock)
- **認證系統** - JWT 裝置認證
- **自動同步** - 網路恢復時批次同步

### 🚧 開發中功能
- **實體列印** - Sewoo SLK-TS400 印表機整合
- **iOS 平台** - 模擬器與真機測試
- **UI 資源** - 字型與圖片資源

## 🏗️ 專案架構

```
lib/
├── models/          # 資料模型
├── services/        # 服務層
├── providers/       # 狀態管理
├── screens/         # 畫面
├── widgets/         # 組件
└── main.dart        # 入口
```

## 📚 文件

- [開發手冊](./開發手冊.md) - 詳細開發文件
- [專案狀態](./專案狀態.md) - 開發進度追蹤
- [藍圖白皮書](../docs/藍圖_開發白皮書_V1.md) - 系統需求文件

## 🔧 開發指南

### 程式碼規範
- 使用 Provider 進行狀態管理
- 所有 API 呼叫都要有錯誤處理
- 離線功能優先考慮
- 使用 JSON 序列化處理資料

### 測試策略
- Web 平台用於功能測試
- iOS 模擬器用於 UI 測試
- 真機測試用於列印功能

## 🐛 已知問題

### 已解決
- ✅ JSON 序列化程式碼生成
- ✅ 依賴版本衝突
- ✅ Web 平台支援
- ✅ 型別錯誤修正

### 待解決
- ⚠️ iOS 模擬器設定
- ⚠️ 實體列印功能
- ⚠️ 字型資源缺失

## 📞 支援

如有問題或建議，請：
1. 查看 [開發手冊](./開發手冊.md)
2. 檢查 [專案狀態](./專案狀態.md)
3. 提交 GitHub Issue

## 📄 授權

本專案採用 MIT 授權條款。

---

**版本：** v1.0.0-alpha  
**最後更新：** 2025-01-27

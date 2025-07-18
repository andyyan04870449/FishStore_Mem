#!/bin/bash

# WhiteSlip Flutter Web 快速啟動腳本

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 啟動 WhiteSlip Flutter Web 版本...${NC}"

# 檢查是否在正確目錄
if [ ! -f "whiteslip_app/pubspec.yaml" ]; then
    echo -e "${RED}❌ 錯誤: 請在專案根目錄執行此腳本${NC}"
    exit 1
fi

# 檢查 Flutter 是否安裝
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter 未安裝，請先安裝 Flutter${NC}"
    exit 1
fi

cd whiteslip_app

# 檢查是否需要安裝依賴
if [ ! -d "build" ] || [ ! -d ".dart_tool" ]; then
    echo -e "${YELLOW}📦 安裝 Flutter 依賴...${NC}"
    flutter pub get
fi

# 檢查 Web 支援
if ! flutter devices | grep -q "Chrome"; then
    echo -e "${YELLOW}⚠️  啟用 Web 支援...${NC}"
    flutter config --enable-web
fi

# 啟動 Flutter Web
echo -e "${GREEN}🌐 啟動 Flutter Web 應用...${NC}"
flutter run -d chrome --web-port=8080 --web-hostname=0.0.0.0 
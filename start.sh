#!/bin/bash

# WhiteSlip 一鍵啟動腳本
# 快速啟動所有服務

echo "🚀 啟動 WhiteSlip 點餐列印系統..."
echo ""

# 檢查腳本是否存在
if [ ! -f "scripts/start_services.sh" ]; then
    echo "❌ 錯誤: 找不到啟動腳本，請確保在專案根目錄執行"
    exit 1
fi

# 執行啟動腳本
./scripts/start_services.sh

echo ""
echo "✅ 啟動完成！"
echo ""
echo "📱 前端管理系統: http://localhost:3000"
echo "🔧 後端 API: http://localhost:5001"
echo "🗄️  資料庫: localhost:5432"
echo ""
echo "👤 管理員帳號: admin"
echo "🔑 管理員密碼: admin123"
echo ""
echo "📋 其他命令:"
echo "  檢查狀態: ./scripts/check_status.sh"
echo "  停止服務: ./scripts/stop_services.sh" 
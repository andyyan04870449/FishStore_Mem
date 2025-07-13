#!/bin/bash

echo "🛑 停止 WhiteSlip Docker 服務..."

# 停止並移除容器
docker-compose -f docker-compose.simple.yml down

echo "✅ 服務已停止"
echo ""
echo "📝 其他命令："
echo "   完全清理（包含資料）: docker-compose -f docker-compose.simple.yml down -v"
echo "   查看日誌: docker-compose -f docker-compose.simple.yml logs"
echo "" 
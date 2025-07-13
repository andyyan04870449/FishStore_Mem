#!/bin/bash

echo "🚀 啟動 WhiteSlip Docker 服務..."

# 檢查 Docker 是否運行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未運行，請先啟動 Docker Desktop"
    exit 1
fi

# 停止現有容器
echo "🛑 停止現有容器..."
docker-compose -f docker-compose.simple.yml down

# 構建並啟動服務
echo "🔨 構建並啟動服務..."
docker-compose -f docker-compose.simple.yml up --build -d

# 等待服務啟動
echo "⏳ 等待服務啟動..."
sleep 10

# 檢查服務狀態
echo "📊 服務狀態："
docker-compose -f docker-compose.simple.yml ps

# 檢查 API 健康狀態
echo "🏥 檢查 API 健康狀態..."
for i in {1..10}; do
    if curl -s http://localhost:5001/healthz > /dev/null; then
        echo "✅ API 服務正常運行"
        break
    fi
    echo "⏳ 等待 API 啟動... ($i/30)"
    sleep 2
done

# 檢查資料庫連線
echo "🗄️ 檢查資料庫連線..."
if docker exec whiteslip_postgres pg_isready -U white -d wsl > /dev/null 2>&1; then
    echo "✅ 資料庫連線正常"
else
    echo "❌ 資料庫連線失敗"
fi

echo ""
echo "🎉 服務啟動完成！"
echo ""
echo "📋 服務資訊："
echo "   API: http://localhost:5001"
echo "   資料庫: localhost:5432 (wsl/white/slip)"
echo ""
echo "📝 管理命令："
echo "   查看日誌: docker-compose -f docker-compose.simple.yml logs -f"
echo "   停止服務: docker-compose -f docker-compose.simple.yml down"
echo "   重啟服務: docker-compose -f docker-compose.simple.yml restart"
echo "" 
# WhiteSlip Docker 部署指南

## 系統需求
- Docker Desktop
- Docker Compose

## 快速開始

### 1. 啟動所有服務
```bash
docker-compose up -d
```

### 2. 查看服務狀態
```bash
docker-compose ps
```

### 3. 查看日誌
```bash
# 查看所有服務日誌
docker-compose logs

# 查看特定服務日誌
docker-compose logs api
docker-compose logs postgres
docker-compose logs admin
```

## 服務說明

### PostgreSQL 資料庫
- **容器名稱**: whiteslip_postgres
- **端口**: 5432
- **資料庫**: wsl
- **用戶名**: white
- **密碼**: slip

### .NET API
- **容器名稱**: whiteslip_api
- **端口**: 5001
- **API 端點**: http://localhost:5001

### React 管理端
- **容器名稱**: whiteslip_admin
- **端口**: 3000
- **網址**: http://localhost:3000

## 管理命令

### 停止服務
```bash
docker-compose down
```

### 重新啟動服務
```bash
docker-compose restart
```

### 重建服務
```bash
docker-compose up --build
```

### 清理資料
```bash
# 停止並移除所有容器、網路
docker-compose down

# 同時移除資料卷（會清除資料庫資料）
docker-compose down -v
```

## 資料庫管理

### 連接到資料庫
```bash
docker exec -it whiteslip_postgres psql -U white -d wsl
```

### 備份資料庫
```bash
docker exec whiteslip_postgres pg_dump -U white wsl > backup.sql
```

### 還原資料庫
```bash
docker exec -i whiteslip_postgres psql -U white -d wsl < backup.sql
```

## 故障排除

### 1. 端口衝突
如果端口被佔用，可以修改 `docker-compose.yml` 中的端口映射：
```yaml
ports:
  - "5433:5432"  # 改為 5433
```

### 2. 權限問題
在 macOS/Linux 上可能需要調整檔案權限：
```bash
sudo chown -R $USER:$USER .
```

### 3. 記憶體不足
如果遇到記憶體不足，可以在 Docker Desktop 設定中增加記憶體分配。

## 開發模式

### 啟用開發模式
```bash
# 使用開發模式啟動（會掛載本地檔案）
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

### 即時重新載入
開發模式下，程式碼變更會自動重新載入。

## 生產環境部署

### 1. 修改環境變數
編輯 `docker-compose.yml` 中的環境變數：
```yaml
environment:
  - ASPNETCORE_ENVIRONMENT=Production
```

### 2. 設定反向代理
建議使用 Nginx 作為反向代理：
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location /api {
        proxy_pass http://localhost:5001;
    }
    
    location / {
        proxy_pass http://localhost:3000;
    }
}
```

### 3. 啟用 HTTPS
使用 Let's Encrypt 或其他 SSL 憑證。

## 監控和日誌

### 查看即時日誌
```bash
docker-compose logs -f
```

### 監控資源使用
```bash
docker stats
```

### 健康檢查
```bash
# API 健康檢查
curl http://localhost:5001/healthz

# 資料庫連線檢查
docker exec whiteslip_postgres pg_isready -U white
``` 
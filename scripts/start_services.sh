#!/bin/bash

# WhiteSlip 點餐列印系統 - 自動啟動腳本
# 作者: AI Assistant
# 版本: 1.0
# 日期: 2025-07-14

set -e  # 遇到錯誤時停止執行

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日誌函數
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 未安裝，請先安裝 $1"
        exit 1
    fi
}

# 檢查端口是否被佔用
check_port() {
    local port=$1
    local service_name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "$service_name 已在端口 $port 運行"
        return 0
    else
        log_info "$service_name 端口 $port 可用"
        return 1
    fi
}

# 檢查服務是否正在運行
check_service() {
    local service_name=$1
    local check_command=$2
    
    if eval $check_command >/dev/null 2>&1; then
        log_success "$service_name 正在運行"
        return 0
    else
        log_warning "$service_name 未運行"
        return 1
    fi
}

# 等待服務啟動
wait_for_service() {
    local service_name=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    log_info "等待 $service_name 啟動..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s $url >/dev/null 2>&1; then
            log_success "$service_name 已成功啟動"
            return 0
        fi
        
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_error "$service_name 啟動超時"
    return 1
}

# 主函數
main() {
    echo "=========================================="
    echo "  WhiteSlip 點餐列印系統 - 自動啟動腳本"
    echo "=========================================="
    echo ""
    
    # 檢查必要命令
    log_info "檢查必要工具..."
    check_command "psql"
    check_command "dotnet"
    check_command "npm"
    check_command "curl"
    check_command "lsof"
    
    # 檢查工作目錄
    if [ ! -d "WhiteSlip.Api" ] || [ ! -d "whiteslip-admin" ]; then
        log_error "請在專案根目錄執行此腳本"
        exit 1
    fi
    
    # 1. 檢查並啟動 PostgreSQL 資料庫
    log_info "步驟 1: 檢查 PostgreSQL 資料庫..."
    
    if check_port 5432 "PostgreSQL"; then
        log_success "PostgreSQL 已在運行"
    else
        log_info "嘗試啟動 PostgreSQL..."
        
        # 檢查是否使用 Homebrew 安裝的 PostgreSQL
        if command -v brew &> /dev/null; then
            if brew services list | grep -q "postgresql"; then
                brew services start postgresql@14 2>/dev/null || brew services start postgresql 2>/dev/null
                sleep 3
            else
                log_warning "未找到 Homebrew PostgreSQL 服務，請手動啟動"
            fi
        else
            log_warning "未找到 Homebrew，請手動啟動 PostgreSQL"
        fi
    fi
    
    # 檢查資料庫連線
    log_info "檢查資料庫連線..."
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        log_success "PostgreSQL 連線正常"
    else
        log_error "PostgreSQL 連線失敗，請檢查資料庫設定"
        exit 1
    fi
    
    # 檢查資料庫是否存在
    if psql -h localhost -U white -d wsl -c "SELECT 1;" >/dev/null 2>&1; then
        log_success "資料庫 'wsl' 連線正常"
    else
        log_warning "資料庫 'wsl' 不存在或連線失敗，嘗試建立..."
        createdb -h localhost -U white wsl 2>/dev/null || log_warning "無法建立資料庫，請手動建立"
    fi
    
    # 2. 檢查並啟動後端 API
    log_info "步驟 2: 檢查後端 API..."
    
    if check_port 5001 "後端 API"; then
        log_success "後端 API 已在運行"
    else
        log_info "啟動後端 API..."
        cd WhiteSlip.Api
        
        # 檢查是否需要還原套件
        if [ ! -d "bin" ] || [ ! -d "obj" ]; then
            log_info "還原 .NET 套件..."
            dotnet restore
        fi
        
        # 啟動 API
        log_info "啟動 ASP.NET API..."
        dotnet run > ../api.log 2>&1 &
        API_PID=$!
        echo $API_PID > ../api.pid
        
        cd ..
        
        # 等待 API 啟動
        if wait_for_service "後端 API" "http://localhost:5001/healthz"; then
            log_success "後端 API 啟動成功"
        else
            log_error "後端 API 啟動失敗"
            exit 1
        fi
    fi
    
    # 3. 檢查並啟動前端管理系統
    log_info "步驟 3: 檢查前端管理系統..."
    
    if check_port 3000 "前端管理系統"; then
        log_success "前端管理系統已在運行"
    else
        log_info "啟動前端管理系統..."
        cd whiteslip-admin
        
        # 檢查是否需要安裝依賴
        if [ ! -d "node_modules" ]; then
            log_info "安裝 npm 依賴..."
            npm install
        fi
        
        # 啟動前端
        log_info "啟動 React 應用..."
        npm start > ../admin.log 2>&1 &
        ADMIN_PID=$!
        echo $ADMIN_PID > ../admin.pid
        
        cd ..
        
        # 等待前端啟動
        if wait_for_service "前端管理系統" "http://localhost:3000"; then
            log_success "前端管理系統啟動成功"
        else
            log_error "前端管理系統啟動失敗"
            exit 1
        fi
    fi
    
    # 4. 驗證所有服務
    log_info "步驟 4: 驗證所有服務..."
    
    echo ""
    echo "=========================================="
    echo "  服務狀態檢查"
    echo "=========================================="
    
    # 檢查資料庫
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} PostgreSQL 資料庫: 運行中 (localhost:5432)"
    else
        echo -e "${RED}✗${NC} PostgreSQL 資料庫: 未運行"
    fi
    
    # 檢查後端 API
    if curl -s http://localhost:5001/healthz >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} 後端 API: 運行中 (http://localhost:5001)"
    else
        echo -e "${RED}✗${NC} 後端 API: 未運行"
    fi
    
    # 檢查前端
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} 前端管理系統: 運行中 (http://localhost:3000)"
    else
        echo -e "${RED}✗${NC} 前端管理系統: 未運行"
    fi
    
    echo ""
    echo "=========================================="
    echo "  服務資訊"
    echo "=========================================="
    echo "資料庫:     http://localhost:5432"
    echo "後端 API:   http://localhost:5001"
    echo "前端管理:   http://localhost:3000"
    echo ""
    echo "管理員帳號: admin"
    echo "管理員密碼: admin123"
    echo ""
    echo "日誌檔案:"
    echo "  - API 日誌: api.log"
    echo "  - 前端日誌: admin.log"
    echo ""
    echo "停止服務: ./scripts/stop_services.sh"
    echo "=========================================="
    
    log_success "所有服務啟動完成！"
}

# 清理函數
cleanup() {
    log_info "清理程序..."
    if [ -f "api.pid" ]; then
        kill $(cat api.pid) 2>/dev/null || true
        rm -f api.pid
    fi
    if [ -f "admin.pid" ]; then
        kill $(cat admin.pid) 2>/dev/null || true
        rm -f admin.pid
    fi
}

# 設置信號處理
trap cleanup EXIT INT TERM

# 執行主函數
main "$@" 
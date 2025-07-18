#!/bin/bash

# WhiteSlip 點餐列印系統 - 服務狀態檢查腳本
# 作者: AI Assistant
# 版本: 1.0
# 日期: 2025-07-14

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

# 檢查服務狀態
check_service_status() {
    local service_name=$1
    local port=$2
    local health_url=$3
    
    echo -n "檢查 $service_name... "
    
    # 檢查端口
    if lsof -i :$port >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} 端口 $port 正在監聽"
        
        # 如果有健康檢查 URL，進行檢查
        if [ ! -z "$health_url" ]; then
            if curl -s $health_url >/dev/null 2>&1; then
                echo -e "  ${GREEN}✓${NC} 健康檢查通過"
            else
                echo -e "  ${YELLOW}⚠${NC} 健康檢查失敗"
            fi
        fi
    else
        echo -e "${RED}✗${NC} 端口 $port 未監聽"
    fi
}

# 檢查資料庫狀態
check_database_status() {
    echo -n "檢查 PostgreSQL 資料庫... "
    
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} 資料庫連線正常"
        
        # 檢查特定資料庫
        if psql -h localhost -U white -d wsl -c "SELECT 1;" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} 資料庫 'wsl' 連線正常"
            
            # 檢查資料表
            local table_count=$(psql -h localhost -U white -d wsl -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
            echo -e "  ${BLUE}ℹ${NC} 資料表數量: $table_count"
        else
            echo -e "  ${YELLOW}⚠${NC} 資料庫 'wsl' 連線失敗"
        fi
    else
        echo -e "${RED}✗${NC} 資料庫連線失敗"
    fi
}

# 檢查 API 端點
check_api_endpoints() {
    echo ""
    log_info "檢查 API 端點..."
    
    local base_url="http://localhost:5001"
    local endpoints=(
        "/healthz:健康檢查"
        "/api/v1/auth/devices:裝置列表"
        "/api/v1/menu:菜單資料"
    )
    
    for endpoint in "${endpoints[@]}"; do
        local url=$(echo $endpoint | cut -d: -f1)
        local name=$(echo $endpoint | cut -d: -f2)
        
        echo -n "  $name ($url)... "
        if curl -s "$base_url$url" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
    done
}

# 檢查進程資訊
check_process_info() {
    echo ""
    log_info "進程資訊..."
    
    # 檢查 API 進程
    local api_pids=$(lsof -ti:5001 2>/dev/null)
    if [ ! -z "$api_pids" ]; then
        echo "  後端 API 進程:"
        for pid in $api_pids; do
            local cmd=$(ps -p $pid -o command= 2>/dev/null)
            echo "    PID $pid: $cmd"
        done
    fi
    
    # 檢查前端進程
    local admin_pids=$(lsof -ti:3000 2>/dev/null)
    if [ ! -z "$admin_pids" ]; then
        echo "  前端管理系統進程:"
        for pid in $admin_pids; do
            local cmd=$(ps -p $pid -o command= 2>/dev/null)
            echo "    PID $pid: $cmd"
        done
    fi
}

# 檢查系統資源
check_system_resources() {
    echo ""
    log_info "系統資源使用..."
    
    # 檢查記憶體使用
    local memory_info=$(ps aux | grep -E "(dotnet|node)" | grep -v grep | awk '{sum+=$6} END {print sum/1024 " MB"}')
    if [ ! -z "$memory_info" ]; then
        echo "  記憶體使用: $memory_info"
    else
        echo "  記憶體使用: 無相關進程"
    fi
    
    # 檢查磁碟空間
    local disk_usage=$(df -h . | tail -1 | awk '{print $5}')
    echo "  磁碟使用率: $disk_usage"
}

# 主函數
main() {
    echo "=========================================="
    echo "  WhiteSlip 點餐列印系統 - 服務狀態檢查"
    echo "=========================================="
    echo ""
    
    # 檢查各服務狀態
    check_service_status "PostgreSQL 資料庫" 5432
    check_service_status "後端 API" 5001 "http://localhost:5001/healthz"
    check_service_status "前端管理系統" 3000 "http://localhost:3000"
    
    echo ""
    check_database_status
    
    # 檢查 API 端點
    check_api_endpoints
    
    # 檢查進程資訊
    check_process_info
    
    # 檢查系統資源
    check_system_resources
    
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
    echo "啟動服務: ./scripts/start_services.sh"
    echo "停止服務: ./scripts/stop_services.sh"
    echo "=========================================="
    
    # 總結
    echo ""
    local all_services_running=true
    
    if ! lsof -i :5432 >/dev/null 2>&1; then
        all_services_running=false
    fi
    
    if ! lsof -i :5001 >/dev/null 2>&1; then
        all_services_running=false
    fi
    
    if ! lsof -i :3000 >/dev/null 2>&1; then
        all_services_running=false
    fi
    
    if [ "$all_services_running" = true ]; then
        log_success "所有服務正在運行！"
    else
        log_warning "部分服務未運行，請檢查上述狀態"
    fi
}

# 執行主函數
main "$@" 
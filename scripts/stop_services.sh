#!/bin/bash

# WhiteSlip 點餐列印系統 - 停止服務腳本
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

# 停止進程函數
stop_process() {
    local process_name=$1
    local port=$2
    
    log_info "停止 $process_name..."
    
    # 查找並停止進程
    local pids=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$pids" ]; then
        echo "$pids" | xargs kill -TERM 2>/dev/null
        sleep 2
        
        # 檢查是否還有進程在運行
        local remaining_pids=$(lsof -ti:$port 2>/dev/null)
        if [ ! -z "$remaining_pids" ]; then
            log_warning "$process_name 仍在運行，強制停止..."
            echo "$remaining_pids" | xargs kill -KILL 2>/dev/null
        fi
        
        log_success "$process_name 已停止"
    else
        log_warning "$process_name 未在運行"
    fi
}

# 主函數
main() {
    echo "=========================================="
    echo "  WhiteSlip 點餐列印系統 - 停止服務"
    echo "=========================================="
    echo ""
    
    # 停止前端管理系統
    stop_process "前端管理系統" 3000
    
    # 停止後端 API
    stop_process "後端 API" 5001
    
    # 清理 PID 檔案
    if [ -f "api.pid" ]; then
        rm -f api.pid
        log_info "已清理 API PID 檔案"
    fi
    
    if [ -f "admin.pid" ]; then
        rm -f admin.pid
        log_info "已清理前端 PID 檔案"
    fi
    
    echo ""
    echo "=========================================="
    echo "  服務狀態檢查"
    echo "=========================================="
    
    # 檢查服務狀態
    if lsof -i :3000 >/dev/null 2>&1; then
        echo -e "${RED}✗${NC} 前端管理系統: 仍在運行"
    else
        echo -e "${GREEN}✓${NC} 前端管理系統: 已停止"
    fi
    
    if lsof -i :5001 >/dev/null 2>&1; then
        echo -e "${RED}✗${NC} 後端 API: 仍在運行"
    else
        echo -e "${GREEN}✓${NC} 後端 API: 已停止"
    fi
    
    if lsof -i :5432 >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠${NC} PostgreSQL 資料庫: 仍在運行 (建議手動停止)"
    else
        echo -e "${GREEN}✓${NC} PostgreSQL 資料庫: 已停止"
    fi
    
    echo ""
    echo "=========================================="
    echo "  停止服務完成"
    echo "=========================================="
    echo ""
    echo "注意: PostgreSQL 資料庫通常需要手動停止"
    echo "停止 PostgreSQL: brew services stop postgresql@14"
    echo ""
    
    log_success "服務停止完成！"
}

# 執行主函數
main "$@" 
#!/bin/bash

# WhiteSlip API 自動化測試腳本
# 用於測試權杖管理功能的API端點

# 設定變數
API_BASE="http://localhost:5001"
ADMIN_ACCOUNT="admin"
ADMIN_PASSWORD="admin123"
LOG_FILE="api_test_$(date +%Y%m%d_%H%M%S).log"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日誌函數
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

# 清理函數
cleanup() {
    log "清理測試資料..."
    # 這裡可以添加清理測試資料的邏輯
}

# 錯誤處理
trap cleanup EXIT

# 主測試函數
main() {
    log "=== WhiteSlip API 自動化測試開始 ==="
    log "測試時間: $(date)"
    log "API基礎URL: $API_BASE"
    log "日誌檔案: $LOG_FILE"
    echo

    # 1. 健康檢查
    log "1. 測試健康檢查..."
    HEALTH_RESPONSE=$(curl -s -w "%{http_code}" "$API_BASE/healthz")
    HTTP_CODE="${HEALTH_RESPONSE: -3}"
    RESPONSE_BODY="${HEALTH_RESPONSE%???}"
    
    if [[ "$HTTP_CODE" == "200" && "$RESPONSE_BODY" == "Healthy" ]]; then
        success "健康檢查通過 (HTTP $HTTP_CODE)"
    else
        error "健康檢查失敗 (HTTP $HTTP_CODE): $RESPONSE_BODY"
        return 1
    fi

    # 2. 使用者登入測試
    log "2. 測試使用者登入..."
    LOGIN_RESPONSE=$(curl -s -X POST "$API_BASE/api/v1/auth/user-login" \
        -H "Content-Type: application/json" \
        -d "{\"account\":\"$ADMIN_ACCOUNT\",\"password\":\"$ADMIN_PASSWORD\"}")

    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

    if [[ -n "$TOKEN" ]]; then
        success "登入成功，取得Token"
        log "Token: ${TOKEN:0:50}..."
    else
        error "登入失敗: $LOGIN_RESPONSE"
        return 1
    fi

    # 3. 裝置列表測試
    log "3. 測試取得裝置列表..."
    DEVICES_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
        "$API_BASE/api/v1/auth/devices")

    if echo "$DEVICES_RESPONSE" | grep -q '"success":true'; then
        success "裝置列表取得成功"
        DEVICE_COUNT=$(echo "$DEVICES_RESPONSE" | grep -o '"totalCount":[0-9]*' | cut -d':' -f2)
        log "裝置數量: $DEVICE_COUNT"
    else
        error "裝置列表取得失敗: $DEVICES_RESPONSE"
    fi

    # 4. 生成授權碼測試
    log "4. 測試生成授權碼..."
    GENERATE_RESPONSE=$(curl -s -X POST "$API_BASE/api/v1/auth/generate-auth-code" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"deviceName":"自動測試裝置"}')

    if echo "$GENERATE_RESPONSE" | grep -q '"success":true'; then
        success "授權碼生成成功"
        AUTH_CODE=$(echo "$GENERATE_RESPONSE" | grep -o '"authCode":"[^"]*"' | cut -d'"' -f4)
        DEVICE_ID=$(echo "$GENERATE_RESPONSE" | grep -o '"deviceId":"[^"]*"' | cut -d'"' -f4)
        log "授權碼: $AUTH_CODE"
        log "裝置ID: $DEVICE_ID"
    else
        error "授權碼生成失敗: $GENERATE_RESPONSE"
    fi

    # 5. 停用裝置測試
    if [[ -n "$DEVICE_ID" ]]; then
        log "5. 測試停用裝置..."
        DISABLE_RESPONSE=$(curl -s -X PUT \
            -H "Authorization: Bearer $TOKEN" \
            "$API_BASE/api/v1/auth/devices/$DEVICE_ID/disable")

        if echo "$DISABLE_RESPONSE" | grep -q '"success":true'; then
            success "裝置停用成功"
        else
            error "裝置停用失敗: $DISABLE_RESPONSE"
        fi
    else
        warning "跳過停用裝置測試 (無裝置ID)"
    fi

    # 6. 啟用裝置測試
    if [[ -n "$DEVICE_ID" ]]; then
        log "6. 測試啟用裝置..."
        ENABLE_RESPONSE=$(curl -s -X PUT \
            -H "Authorization: Bearer $TOKEN" \
            "$API_BASE/api/v1/auth/devices/$DEVICE_ID/enable")

        if echo "$ENABLE_RESPONSE" | grep -q '"success":true'; then
            success "裝置啟用成功"
        else
            error "裝置啟用失敗: $ENABLE_RESPONSE"
        fi
    else
        warning "跳過啟用裝置測試 (無裝置ID)"
    fi

    # 7. 刪除裝置測試
    if [[ -n "$DEVICE_ID" ]]; then
        log "7. 測試刪除裝置..."
        DELETE_RESPONSE=$(curl -s -X DELETE \
            -H "Authorization: Bearer $TOKEN" \
            "$API_BASE/api/v1/auth/devices/$DEVICE_ID")

        if echo "$DELETE_RESPONSE" | grep -q '"success":true'; then
            success "裝置刪除成功"
        else
            error "裝置刪除失敗: $DELETE_RESPONSE"
        fi
    else
        warning "跳過刪除裝置測試 (無裝置ID)"
    fi

    # 8. 錯誤處理測試
    log "8. 測試錯誤處理..."
    
    # 測試無效Token
    INVALID_TOKEN_RESPONSE=$(curl -s -H "Authorization: Bearer invalid_token" \
        "$API_BASE/api/v1/auth/devices")
    
    if echo "$INVALID_TOKEN_RESPONSE" | grep -q "401"; then
        success "無效Token處理正確"
    else
        warning "無效Token處理可能異常: $INVALID_TOKEN_RESPONSE"
    fi

    # 測試不存在的裝置
    if [[ -n "$DEVICE_ID" ]]; then
        NOT_FOUND_RESPONSE=$(curl -s -X PUT \
            -H "Authorization: Bearer $TOKEN" \
            "$API_BASE/api/v1/auth/devices/00000000-0000-0000-0000-000000000000/disable")
        
        if echo "$NOT_FOUND_RESPONSE" | grep -q '"success":false'; then
            success "不存在裝置處理正確"
        else
            warning "不存在裝置處理可能異常: $NOT_FOUND_RESPONSE"
        fi
    fi

    # 9. 效能測試
    log "9. 測試API效能..."
    
    # 測試回應時間
    START_TIME=$(date +%s%N)
    curl -s -H "Authorization: Bearer $TOKEN" "$API_BASE/api/v1/auth/devices" > /dev/null
    END_TIME=$(date +%s%N)
    
    RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 ))  # 轉換為毫秒
    
    if [[ $RESPONSE_TIME -lt 1000 ]]; then
        success "API回應時間正常: ${RESPONSE_TIME}ms"
    else
        warning "API回應時間較慢: ${RESPONSE_TIME}ms"
    fi

    # 10. 資料庫連線測試
    log "10. 測試資料庫連線..."
    DB_TEST=$(psql -h localhost -U white -d wsl -c "SELECT COUNT(*) FROM devices;" 2>/dev/null | tail -n 1 | tr -d ' ')
    
    if [[ "$DB_TEST" =~ ^[0-9]+$ ]]; then
        success "資料庫連線正常，裝置數量: $DB_TEST"
    else
        error "資料庫連線失敗"
    fi

    echo
    log "=== 測試完成 ==="
    log "測試結果已記錄到: $LOG_FILE"
    
    # 顯示測試摘要
    echo
    log "測試摘要:"
    success "✅ 所有核心功能測試完成"
    log "📊 詳細結果請查看日誌檔案"
    log "🔧 如有問題請檢查服務狀態和配置"
}

# 檢查依賴
check_dependencies() {
    log "檢查依賴..."
    
    # 檢查curl
    if ! command -v curl &> /dev/null; then
        error "curl 未安裝"
        return 1
    fi
    
    # 檢查psql
    if ! command -v psql &> /dev/null; then
        warning "psql 未安裝，將跳過資料庫測試"
    fi
    
    # 檢查API是否運行
    if ! curl -s "$API_BASE/healthz" &> /dev/null; then
        error "API服務未運行，請先啟動後端API"
        return 1
    fi
    
    success "依賴檢查完成"
}

# 顯示使用說明
show_usage() {
    echo "WhiteSlip API 自動化測試腳本"
    echo
    echo "用法: $0 [選項]"
    echo
    echo "選項:"
    echo "  -h, --help     顯示此說明"
    echo "  -v, --verbose  詳細輸出"
    echo "  -q, --quiet    安靜模式"
    echo
    echo "範例:"
    echo "  $0             執行完整測試"
    echo "  $0 -v          詳細模式測試"
    echo
}

# 主程式
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -v|--verbose)
        set -x
        ;;
    -q|--quiet)
        exec 1>/dev/null
        ;;
esac

# 執行測試
if check_dependencies; then
    main
else
    error "依賴檢查失敗，請檢查環境配置"
    exit 1
fi 
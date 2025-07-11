#!/bin/bash

# WhiteSlip 資料庫備份腳本
# 使用方式: ./backup-script.sh [backup|restore] [backup_file]

set -e

# 配置
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"5432"}
DB_NAME=${DB_NAME:-"wsl"}
DB_USER=${DB_USER:-"white"}
BACKUP_DIR=${BACKUP_DIR:-"./backups"}
S3_BUCKET=${S3_BUCKET:-"whiteslip-backups"}
RETENTION_DAYS=${RETENTION_DAYS:-"30"}

# 建立備份目錄
mkdir -p $BACKUP_DIR

backup() {
    echo "開始備份資料庫..."
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/whiteslip_$timestamp.sql"
    
    # PostgreSQL 備份
    PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME > $backup_file
    
    if [ $? -eq 0 ]; then
        echo "備份成功: $backup_file"
        
        # 壓縮備份檔
        gzip $backup_file
        echo "備份檔已壓縮: $backup_file.gz"
        
        # 上傳到 S3 (如果配置了 AWS CLI)
        if command -v aws &> /dev/null; then
            aws s3 cp "$backup_file.gz" "s3://$S3_BUCKET/$(basename $backup_file.gz)"
            echo "備份檔已上傳到 S3"
        fi
        
        # 清理舊備份
        find $BACKUP_DIR -name "whiteslip_*.sql.gz" -mtime +$RETENTION_DAYS -delete
        echo "已清理 $RETENTION_DAYS 天前的備份檔"
    else
        echo "備份失敗"
        exit 1
    fi
}

restore() {
    local backup_file=$1
    if [ -z "$backup_file" ]; then
        echo "請指定要恢復的備份檔"
        exit 1
    fi
    
    echo "開始恢復資料庫..."
    
    # 解壓縮 (如果是 .gz 檔案)
    if [[ $backup_file == *.gz ]]; then
        gunzip -c $backup_file | PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
    else
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME < $backup_file
    fi
    
    if [ $? -eq 0 ]; then
        echo "恢復成功"
    else
        echo "恢復失敗"
        exit 1
    fi
}

# 主程式
case $1 in
    "backup")
        backup
        ;;
    "restore")
        restore $2
        ;;
    *)
        echo "使用方式: $0 [backup|restore] [backup_file]"
        echo "範例:"
        echo "  $0 backup                    # 建立備份"
        echo "  $0 restore backup_file.sql   # 恢復備份"
        exit 1
        ;;
esac 
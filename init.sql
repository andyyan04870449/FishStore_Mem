-- 初始化資料庫結構
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account VARCHAR(100) UNIQUE NOT NULL,
    hashed_pw VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'User',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS devices (
    device_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_code VARCHAR(50) UNIQUE NOT NULL,
    jwt TEXT NOT NULL,
    last_seen TIMESTAMPTZ NOT NULL DEFAULT now(),
    status INTEGER NOT NULL DEFAULT 0,
    device_name VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    activated_at TIMESTAMPTZ,
    disabled_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS menus (
    id SERIAL PRIMARY KEY,
    version INTEGER NOT NULL,
    menu_data TEXT NOT NULL,
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(20) PRIMARY KEY,
    business_day DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(20) REFERENCES orders(order_id) ON DELETE CASCADE,
    line_no INTEGER,
    sku VARCHAR(50) NOT NULL,
    name VARCHAR(200) NOT NULL,
    qty INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, line_no)
);

-- 插入預設管理員帳號
INSERT INTO users (account, hashed_pw, role) 
VALUES ('admin', '$2a$11$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin')
ON CONFLICT (account) DO NOTHING;

-- 插入範例菜單
INSERT INTO menus (version, menu_data) VALUES (
    1,
    '{
        "categories": [
            {
                "name": "飲料",
                "items": [
                    {
                        "sku": "DRINK001",
                        "name": "可樂",
                        "price": 30,
                        "available": true
                    },
                    {
                        "sku": "DRINK002",
                        "name": "雪碧",
                        "price": 30,
                        "available": true
                    },
                    {
                        "sku": "DRINK003",
                        "name": "檸檬茶",
                        "price": 35,
                        "available": true
                    }
                ]
            },
            {
                "name": "主食",
                "items": [
                    {
                        "sku": "MAIN001",
                        "name": "牛肉麵",
                        "price": 120,
                        "available": true
                    },
                    {
                        "sku": "MAIN002",
                        "name": "雞肉飯",
                        "price": 80,
                        "available": true
                    }
                ]
            },
            {
                "name": "甜點",
                "items": [
                    {
                        "sku": "DESSERT001",
                        "name": "布丁",
                        "price": 45,
                        "available": true
                    },
                    {
                        "sku": "DESSERT002",
                        "name": "蛋糕",
                        "price": 60,
                        "available": true
                    }
                ]
            }
        ]
    }'
) ON CONFLICT DO NOTHING; 
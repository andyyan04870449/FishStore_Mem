import React from 'react';
import { Card, Table, Tag, Empty } from 'antd';
import { MenuCategory } from '../../types';

interface MenuPreviewProps {
  categories: MenuCategory[];
}

const MenuPreview: React.FC<MenuPreviewProps> = ({ categories }) => {
  // 統計資訊
  const totalCategories = categories.length;
  const totalItems = categories.reduce((total, category) => total + category.items.length, 0);

  // 檢查是否有有效資料
  const hasValidData = categories.some(category => 
    category.name.trim() && category.items.some(item => 
      item.name.trim() && item.price > 0
    )
  );

  if (!hasValidData) {
    return (
      <Empty
        description="請先填寫分類和項目資訊以預覽菜單"
        image={Empty.PRESENTED_IMAGE_SIMPLE}
      />
    );
  }

  return (
    <div>
      {/* 統計資訊 */}
      <div style={{ marginBottom: 16, display: 'flex', gap: 16 }}>
        <Card size="small" style={{ flex: 1 }}>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#1890ff' }}>
              {totalCategories}
            </div>
            <div style={{ fontSize: '12px', color: '#666' }}>分類數量</div>
          </div>
        </Card>
        <Card size="small" style={{ flex: 1 }}>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#52c41a' }}>
              {totalItems}
            </div>
            <div style={{ fontSize: '12px', color: '#666' }}>項目總數</div>
          </div>
        </Card>
      </div>

      {/* 菜單預覽 */}
      {categories.map((category, categoryIndex) => {
        const validItems = category.items.filter(item => 
          item.name.trim() && item.price > 0
        );

        if (!category.name.trim() || validItems.length === 0) {
          return null;
        }

        return (
          <Card
            key={categoryIndex}
            title={
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span>{category.name}</span>
                <Tag color="blue">{validItems.length} 項</Tag>
              </div>
            }
            style={{ marginBottom: 16 }}
            size="small"
          >
            <Table
              dataSource={validItems}
              columns={[
                {
                  title: '名稱',
                  dataIndex: 'name',
                  key: 'name',
                },
                {
                  title: '價格',
                  dataIndex: 'price',
                  key: 'price',
                  width: 100,
                  render: (price: number) => (
                    <span style={{ fontWeight: 'bold', color: '#fa8c16' }}>
                      ${price.toFixed(2)}
                    </span>
                  )
                }
              ]}
              pagination={false}
              size="small"
              rowKey={(record, index) => `${categoryIndex}-${index}`}
            />
          </Card>
        );
      })}
    </div>
  );
};

export default MenuPreview; 
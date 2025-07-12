import React from 'react';
import { Table, Button, Input, InputNumber } from 'antd';
import { DeleteOutlined, PlusOutlined } from '@ant-design/icons';
import { MenuItem } from '../../types';

interface ItemListProps {
  items: MenuItem[];
  onChange: (items: MenuItem[]) => void;
}

const ItemList: React.FC<ItemListProps> = ({ items, onChange }) => {
  // 新增項目
  const addItem = () => {
    const newItem: MenuItem = {
      sku: '',
      name: '',
      price: 0
    };
    onChange([...items, newItem]);
  };

  // 更新項目
  const updateItem = (index: number, field: keyof MenuItem, value: string | number) => {
    const newItems = [...items];
    newItems[index] = { ...newItems[index], [field]: value };
    onChange(newItems);
  };

  // 刪除項目
  const removeItem = (index: number) => {
    const newItems = items.filter((_, i) => i !== index);
    onChange(newItems);
  };

  // 檢查 SKU 重複
  const checkDuplicateSku = (sku: string, currentIndex: number) => {
    return items.some((item, index) => index !== currentIndex && item.sku === sku);
  };

  // 表格欄位定義
  const columns = [
    {
      title: 'SKU',
      dataIndex: 'sku',
      key: 'sku',
      width: 120,
      render: (value: string, record: MenuItem, index: number) => (
        <Input
          value={value}
          onChange={(e) => {
            const newValue = e.target.value.toUpperCase();
            updateItem(index, 'sku', newValue);
          }}
          placeholder="SKU"
          status={checkDuplicateSku(value, index) ? 'error' : undefined}
        />
      )
    },
    {
      title: '名稱',
      dataIndex: 'name',
      key: 'name',
      render: (value: string, record: MenuItem, index: number) => (
        <Input
          value={value}
          onChange={(e) => updateItem(index, 'name', e.target.value)}
          placeholder="項目名稱"
        />
      )
    },
    {
      title: '價格',
      dataIndex: 'price',
      key: 'price',
      width: 120,
      render: (value: number, record: MenuItem, index: number) => (
        <InputNumber
          value={value}
          onChange={(value) => updateItem(index, 'price', value || 0)}
          placeholder="價格"
          min={0}
          precision={2}
          style={{ width: '100%' }}
        />
      )
    },
    {
      title: '操作',
      key: 'action',
      width: 80,
      render: (value: any, record: MenuItem, index: number) => (
        <Button
          type="text"
          danger
          icon={<DeleteOutlined />}
          onClick={() => removeItem(index)}
        />
      )
    }
  ];

  return (
    <div>
      <Table
        dataSource={items}
        columns={columns}
        pagination={false}
        size="small"
        rowKey={(record, index) => index?.toString() || '0'}
        style={{ marginBottom: 16 }}
      />
      
      <Button
        type="dashed"
        icon={<PlusOutlined />}
        onClick={addItem}
        block
      >
        新增項目
      </Button>
    </div>
  );
};

export default ItemList; 
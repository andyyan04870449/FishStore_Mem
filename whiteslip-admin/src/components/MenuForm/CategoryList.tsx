import React from 'react';
import { Card, Button, Input } from 'antd';
import { DeleteOutlined, PlusOutlined } from '@ant-design/icons';
import { MenuCategory, MenuItem } from '../../types';
import ItemList from './ItemList';

interface CategoryListProps {
  categories: MenuCategory[];
  onChange: (categories: MenuCategory[]) => void;
}

const CategoryList: React.FC<CategoryListProps> = ({ categories, onChange }) => {
  // 新增分類
  const addCategory = () => {
    const newCategory: MenuCategory = {
      name: '',
      items: []
    };
    onChange([...categories, newCategory]);
  };



  // 刪除分類
  const removeCategory = (index: number) => {
    const newCategories = categories.filter((_, i) => i !== index);
    onChange(newCategories);
  };

  // 更新分類名稱
  const updateCategoryName = (index: number, name: string) => {
    const newCategories = [...categories];
    newCategories[index] = { ...newCategories[index], name };
    onChange(newCategories);
  };

  // 更新分類項目
  const updateCategoryItems = (index: number, items: MenuItem[]) => {
    const newCategories = [...categories];
    newCategories[index] = { ...newCategories[index], items };
    onChange(newCategories);
  };

  return (
    <div>
      {categories.map((category, index) => (
        <Card
          key={index}
          title={
            <Input
              value={category.name}
              onChange={(e) => updateCategoryName(index, e.target.value)}
              placeholder="請輸入分類名稱"
              style={{ width: 200 }}
            />
          }
          extra={
            <Button
              type="text"
              danger
              icon={<DeleteOutlined />}
              onClick={() => removeCategory(index)}
            >
              刪除分類
            </Button>
          }
          style={{ marginBottom: 16 }}
        >
          <ItemList
            items={category.items}
            onChange={(items) => updateCategoryItems(index, items)}
          />
        </Card>
      ))}
      
      <Button
        type="dashed"
        icon={<PlusOutlined />}
        onClick={addCategory}
        block
      >
        新增分類
      </Button>
    </div>
  );
};

export default CategoryList; 
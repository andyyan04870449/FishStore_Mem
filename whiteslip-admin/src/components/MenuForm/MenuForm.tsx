import React, { useState, useEffect, useCallback } from 'react';
import { Form, Input, InputNumber, Button, Space, Card, message, Spin, Alert } from 'antd';
import { PlusOutlined, SaveOutlined } from '@ant-design/icons';
import { MenuCategory } from '../../types';
import { api } from '../../services/api';
import { API_ENDPOINTS } from '../../constants';
import CategoryList from './CategoryList';
import MenuPreview from './MenuPreview';

const { TextArea } = Input;

interface MenuFormProps {
  initialData?: {
    version?: number;
    description?: string;
    categories?: MenuCategory[];
  };
  onSubmit: (data: any) => Promise<void>;
  onCancel: () => void;
  loading?: boolean;
}

const MenuForm: React.FC<MenuFormProps> = ({
  initialData,
  onSubmit,
  onCancel,
  loading = false
}) => {
  const [form] = Form.useForm();
  const [categories, setCategories] = useState<MenuCategory[]>(initialData?.categories || []);
  const [versionLoading, setVersionLoading] = useState(false);
  const [latestVersion, setLatestVersion] = useState<number>(0);

  // 自動取得最新版本號
  const fetchLatestVersion = useCallback(async () => {
    try {
      setVersionLoading(true);
      const response = await api.get(API_ENDPOINTS.MENU_LATEST_VERSION) as any;
      const nextVersion = response.version + 1;
      setLatestVersion(response.version);
      
      // 如果是新增菜單，自動設定版本號
      if (!initialData?.version) {
        form.setFieldsValue({ version: nextVersion });
      }
    } catch (error: any) {
      console.error('取得最新版本號失敗:', error);
      // 如果無法取得版本號，預設為 1
      if (!initialData?.version) {
        form.setFieldsValue({ version: 1 });
      }
    } finally {
      setVersionLoading(false);
    }
  }, [initialData?.version, form]);

  useEffect(() => {
    fetchLatestVersion();
  }, [fetchLatestVersion]);



  // 處理表單提交
  const handleSubmit = async (values: any) => {
    try {
      if (categories.length === 0) {
        message.error('至少需要一個分類');
        return;
      }

      const menuData = {
        version: values.version,
        description: values.description,
        categories: categories
      };

      await onSubmit(menuData);
    } catch (error: any) {
      message.error('建立菜單失敗');
    }
  };

  // 更新分類列表
  const handleCategoriesChange = (newCategories: MenuCategory[]) => {
    setCategories(newCategories);
  };

  return (
    <div>
      <Form
        form={form}
        layout="vertical"
        onFinish={handleSubmit}
        initialValues={{
          version: initialData?.version,
          description: initialData?.description || ''
        }}
      >
        {/* 基本資訊 */}
        <Card title="基本資訊" style={{ marginBottom: 16 }}>
          <Form.Item
            name="version"
            label="版本號"
            rules={[{ required: true, message: '請輸入版本號' }]}
          >
            <InputNumber
              min={1}
              style={{ width: '100%' }}
              disabled={versionLoading}
              addonAfter={
                versionLoading ? (
                  <Spin size="small" />
                ) : (
                  latestVersion > 0 && (
                    <span style={{ fontSize: '12px', color: '#666' }}>
                      當前最新版本: {latestVersion}
                    </span>
                  )
                )
              }
            />
          </Form.Item>

          <Form.Item
            name="description"
            label="描述"
          >
            <TextArea
              rows={3}
              placeholder="請輸入菜單描述（可選）"
            />
          </Form.Item>
        </Card>

        {/* 分類管理 */}
        <Card 
          title="分類管理" 
          style={{ marginBottom: 16 }}
          extra={
            <Button
              type="dashed"
              icon={<PlusOutlined />}
              onClick={() => {
                const newCategory: MenuCategory = {
                  name: '',
                  items: []
                };
                setCategories([...categories, newCategory]);
              }}
            >
              新增分類
            </Button>
          }
        >
          {categories.length === 0 ? (
            <Alert
              message="尚未建立分類"
              description="請點擊「新增分類」開始建立菜單內容"
              type="info"
              showIcon
            />
          ) : (
            <CategoryList
              categories={categories}
              onChange={handleCategoriesChange}
            />
          )}
        </Card>

        {/* 菜單預覽 */}
        {categories.length > 0 && (
          <Card title="菜單預覽" style={{ marginBottom: 16 }}>
            <MenuPreview categories={categories} />
          </Card>
        )}

        {/* 操作按鈕 */}
        <Form.Item>
          <Space>
            <Button
              type="primary"
              htmlType="submit"
              icon={<SaveOutlined />}
              loading={loading}
            >
              建立菜單
            </Button>
            <Button onClick={onCancel}>
              取消
            </Button>
          </Space>
        </Form.Item>
      </Form>
    </div>
  );
};

export default MenuForm; 
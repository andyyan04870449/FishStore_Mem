import React, { useState, useEffect, useCallback } from 'react';
import { Form, Input, Button, Space, Card, message, Spin, Alert } from 'antd';
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
      
      // 只有在沒有 initialData 且沒有預填資料時才自動設定版本號
      if (!initialData?.version && categories.length === 0) {
        form.setFieldsValue({ version: nextVersion });
      }
    } catch (error: any) {
      console.error('取得最新版本號失敗:', error);
      // 如果無法取得版本號，預設為 1
      if (!initialData?.version && categories.length === 0) {
        form.setFieldsValue({ version: 1 });
      }
    } finally {
      setVersionLoading(false);
    }
  }, [initialData?.version, form, categories.length]);

  useEffect(() => {
    fetchLatestVersion();
  }, [fetchLatestVersion]);

  // 監聽預填菜單資料事件
  useEffect(() => {
    const handlePrefillMenu = (event: CustomEvent) => {
      const { version, description, categories } = event.detail;
      
      // 立即設定表單值
      form.setFieldsValue({ 
        version: version,
        description: description || ''
      });
      
      // 設定分類資料
      setCategories(categories || []);
      
    };

    document.addEventListener('prefill-menu-form', handlePrefillMenu as EventListener);
    
    return () => {
      document.removeEventListener('prefill-menu-form', handlePrefillMenu as EventListener);
    };
  }, [form]);


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
            label="版本號"
            style={{ marginBottom: 0 }}
          >
            <span style={{ fontSize: '16px', fontWeight: 'bold' }}>
              <Form.Item name="version" noStyle>
                {/* 隱藏 input，送出時仍帶 version */}
                <input type="hidden" />
              </Form.Item>
              <span data-testid="menu-version">
                {form.getFieldValue('version')}
              </span>
              {versionLoading ? (
                <Spin size="small" style={{ marginLeft: 8 }} />
              ) : (
                latestVersion > 0 && (
                  <span style={{ fontSize: '12px', color: '#666', marginLeft: 8 }}>
                    當前最新版本: {latestVersion}
                  </span>
                )
              )}
            </span>
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
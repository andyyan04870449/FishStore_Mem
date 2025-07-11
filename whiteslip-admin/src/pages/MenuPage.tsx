import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Modal, Form, Input, InputNumber, message, Card, Tag } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, EyeOutlined } from '@ant-design/icons';
import { Menu, MenuItem, MenuCategory } from '../types';
import { api } from '../services/api';
import { API_ENDPOINTS } from '../constants';

const { TextArea } = Input;

const MenuPage: React.FC = () => {
  const [menus, setMenus] = useState<Menu[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingMenu, setEditingMenu] = useState<Menu | null>(null);
  const [form] = Form.useForm();

  // 取得菜單列表
  const fetchMenus = async () => {
    try {
      setLoading(true);
      const response = await api.get<Menu[]>(API_ENDPOINTS.MENU);
      setMenus(response);
    } catch (error) {
      message.error('取得菜單失敗');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMenus();
  }, []);

  // 處理表單提交
  const handleSubmit = async (values: any) => {
    try {
      if (editingMenu) {
        await api.put(`${API_ENDPOINTS.MENU}/${editingMenu.id}`, values);
        message.success('菜單更新成功');
      } else {
        await api.post(API_ENDPOINTS.MENU, values);
        message.success('菜單新增成功');
      }
      setModalVisible(false);
      form.resetFields();
      fetchMenus();
    } catch (error) {
      message.error('操作失敗');
    }
  };

  // 刪除菜單
  const handleDelete = async (id: string) => {
    Modal.confirm({
      title: '確認刪除',
      content: '確定要刪除這個菜單嗎？',
      onOk: async () => {
        try {
          await api.delete(`${API_ENDPOINTS.MENU}/${id}`);
          message.success('刪除成功');
          fetchMenus();
        } catch (error) {
          message.error('刪除失敗');
        }
      },
    });
  };

  // 表格欄位定義
  const columns = [
    {
      title: '版本',
      dataIndex: 'version',
      key: 'version',
      width: 80,
    },
    {
      title: '最後更新',
      dataIndex: 'lastUpdated',
      key: 'lastUpdated',
      width: 180,
    },
    {
      title: '分類數量',
      key: 'categoryCount',
      width: 100,
      render: (text: string, record: Menu) => record.menu.categories.length,
    },
    {
      title: '項目總數',
      key: 'itemCount',
      width: 100,
      render: (text: string, record: Menu) => 
        record.menu.categories.reduce((total, category) => total + category.items.length, 0),
    },
    {
      title: '操作',
      key: 'action',
      width: 200,
      render: (text: string, record: Menu) => (
        <Space size="small">
          <Button
            type="link"
            icon={<EyeOutlined />}
            onClick={() => handleView(record)}
          >
            查看
          </Button>
          <Button
            type="link"
            icon={<EditOutlined />}
            onClick={() => handleEdit(record)}
          >
            編輯
          </Button>
          <Button
            type="link"
            danger
            icon={<DeleteOutlined />}
            onClick={() => handleDelete(record.id)}
          >
            刪除
          </Button>
        </Space>
      ),
    },
  ];

  // 查看菜單詳情
  const handleView = (menu: Menu) => {
    Modal.info({
      title: `菜單版本 ${menu.version}`,
      width: 800,
      content: (
        <div>
          <p><strong>最後更新：</strong>{menu.lastUpdated}</p>
          <p><strong>分類數量：</strong>{menu.menu.categories.length}</p>
          <p><strong>項目總數：</strong>
            {menu.menu.categories.reduce((total, category) => total + category.items.length, 0)}
          </p>
          <div style={{ marginTop: 16 }}>
            {menu.menu.categories.map((category, index) => (
              <Card key={index} title={category.name} style={{ marginBottom: 16 }}>
                <Table
                  dataSource={category.items}
                  columns={[
                    { title: 'SKU', dataIndex: 'sku', key: 'sku' },
                    { title: '名稱', dataIndex: 'name', key: 'name' },
                    { 
                      title: '價格', 
                      dataIndex: 'price', 
                      key: 'price',
                      render: (price: number) => `$${price}`
                    },
                  ]}
                  pagination={false}
                  size="small"
                />
              </Card>
            ))}
          </div>
        </div>
      ),
    });
  };

  // 編輯菜單
  const handleEdit = (menu: Menu) => {
    setEditingMenu(menu);
    form.setFieldsValue({
      version: menu.version,
      categories: menu.menu.categories,
    });
    setModalVisible(true);
  };

  // 新增菜單
  const handleAdd = () => {
    setEditingMenu(null);
    form.resetFields();
    setModalVisible(true);
  };

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between' }}>
        <h1>菜單管理</h1>
        <Button
          type="primary"
          icon={<PlusOutlined />}
          onClick={handleAdd}
        >
          新增菜單
        </Button>
      </div>

      <Table
        columns={columns}
        dataSource={menus}
        loading={loading}
        rowKey="id"
        pagination={{
          showSizeChanger: true,
          showQuickJumper: true,
          showTotal: (total) => `共 ${total} 筆資料`,
        }}
      />

      <Modal
        title={editingMenu ? '編輯菜單' : '新增菜單'}
        open={modalVisible}
        onCancel={() => setModalVisible(false)}
        footer={null}
        width={800}
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={handleSubmit}
        >
          <Form.Item
            name="version"
            label="版本號"
            rules={[{ required: true, message: '請輸入版本號' }]}
          >
            <InputNumber min={1} style={{ width: '100%' }} />
          </Form.Item>

          <Form.Item
            name="description"
            label="描述"
          >
            <TextArea rows={3} />
          </Form.Item>

          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit">
                {editingMenu ? '更新' : '新增'}
              </Button>
              <Button onClick={() => setModalVisible(false)}>
                取消
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default MenuPage; 
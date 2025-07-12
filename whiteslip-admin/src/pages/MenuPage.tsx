import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Modal, message, Card, Tag, Alert } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, EyeOutlined } from '@ant-design/icons';
import { Menu } from '../types';
import { api } from '../services/api';
import { API_ENDPOINTS } from '../constants';
import { MenuForm } from '../components/MenuForm';

const MenuPage: React.FC = () => {
  const [menus, setMenus] = useState<Menu[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingMenu, setEditingMenu] = useState<Menu | null>(null);
  const [noMenu, setNoMenu] = useState(false);
  const [submitLoading, setSubmitLoading] = useState(false);

  // 取得菜單列表
  const fetchMenus = async () => {
    try {
      setLoading(true);
      setNoMenu(false);
      const response = await api.get<Menu[]>(API_ENDPOINTS.MENU);
      setMenus(response);
    } catch (error: any) {
      // 檢查 404 狀態
      if (error.message && (error.message.includes('404') || error.message.includes('菜單不存在'))) {
        setNoMenu(true);
        setMenus([]);
      } else {
        message.error('取得菜單失敗');
      }
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
      setSubmitLoading(true);
      if (editingMenu) {
        await api.put(`${API_ENDPOINTS.MENU}/${editingMenu.id}`, values);
        message.success('菜單更新成功');
      } else {
        await api.post(API_ENDPOINTS.MENU, values);
        message.success('菜單新增成功');
      }
      setModalVisible(false);
      fetchMenus();
    } catch (error: any) {
      message.error(error.message || '操作失敗');
    } finally {
      setSubmitLoading(false);
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
    setModalVisible(true);
  };

  // 新增菜單
  const handleAdd = () => {
    setEditingMenu(null);
    setModalVisible(true);
  };

  // 關閉模態框
  const handleCancel = () => {
    setModalVisible(false);
    setEditingMenu(null);
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

      {noMenu ? (
        <Alert
          message="尚未建立菜單"
          description="目前尚無任何菜單資料，請點擊右上方「新增菜單」建立第一份菜單。"
          type="info"
          showIcon
          style={{ marginBottom: 24 }}
        />
      ) : (
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
      )}

      <Modal
        title={editingMenu ? '編輯菜單' : '新增菜單'}
        open={modalVisible}
        onCancel={handleCancel}
        footer={null}
        width={1000}
        destroyOnClose
      >
        <MenuForm
          initialData={editingMenu ? {
            version: editingMenu.version,
            description: '',
            categories: editingMenu.menu.categories
          } : undefined}
          onSubmit={handleSubmit}
          onCancel={handleCancel}
          loading={submitLoading}
        />
      </Modal>
    </div>
  );
};

export default MenuPage; 
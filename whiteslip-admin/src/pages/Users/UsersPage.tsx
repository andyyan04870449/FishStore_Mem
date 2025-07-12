import React, { useEffect, useState } from 'react';
import { Table, Card, Button, Tag, message, Modal, Form, Input, Select, Space } from 'antd';
import { api } from '../../services/api';
import { API_ENDPOINTS, ROLES } from '../../constants';
import { User } from '../../types';
import { useSelector } from 'react-redux';
import { RootState } from '../../store';
import { hasPermission } from '../../utils/permission';

const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [form] = Form.useForm();

  const { user } = useSelector((state: RootState) => state.auth);
  const role = user?.role;

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const data = await api.get<User[]>(API_ENDPOINTS.USERS);
      setUsers(data);
    } catch (err) {
      message.error('取得使用者列表失敗');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleAdd = () => {
    setEditingUser(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleEdit = (user: User) => {
    setEditingUser(user);
    form.setFieldsValue({
      account: user.account,
      role: user.role,
      name: user.name,
    });
    setModalVisible(true);
  };

  const handleDelete = (user: User) => {
    Modal.confirm({
      title: `確定要刪除使用者「${user.account}」嗎？`,
      onOk: async () => {
        try {
          await api.delete(`${API_ENDPOINTS.USERS}/${user.id}`);
          message.success('刪除成功');
          fetchUsers();
        } catch {
          message.error('刪除失敗');
        }
      },
    });
  };

  const handleSubmit = async (values: any) => {
    try {
      if (editingUser) {
        await api.put(`${API_ENDPOINTS.USERS}/${editingUser.id}`, values);
        message.success('更新成功');
      } else {
        await api.post(API_ENDPOINTS.USERS, values);
        message.success('新增成功');
      }
      setModalVisible(false);
      fetchUsers();
    } catch {
      message.error(editingUser ? '更新失敗' : '新增失敗');
    }
  };

  const columns = [
    { title: '帳號', dataIndex: 'account', key: 'account' },
    { title: '角色', dataIndex: 'role', key: 'role', render: (role: string) => <Tag color={role === 'Admin' ? 'red' : role === 'Manager' ? 'blue' : 'green'}>{role}</Tag> },
    { title: '建立時間', dataIndex: 'createdAt', key: 'createdAt' },
    ...(role && hasPermission(role, 'Admin') ? [{
      title: '操作',
      key: 'action',
      render: (_: any, user: User) => (
        <Space>
          <Button type="link" onClick={() => handleEdit(user)}>編輯</Button>
          <Button type="link" danger onClick={() => handleDelete(user)}>刪除</Button>
        </Space>
      ),
    }] : []),
  ];

  return (
    <div style={{ padding: 24 }}>
      <h1>使用者管理</h1>
      <Card>
        {role && hasPermission(role, 'Admin') && (
          <Button type="primary" style={{ marginBottom: 16 }} onClick={handleAdd}>新增使用者</Button>
        )}
        <Table
          columns={columns}
          dataSource={users}
          loading={loading}
          rowKey="id"
          pagination={{ pageSize: 10 }}
        />
      </Card>
      <Modal
        title={editingUser ? '編輯使用者' : '新增使用者'}
        open={modalVisible}
        onCancel={() => setModalVisible(false)}
        footer={null}
        destroyOnClose
      >
        <Form form={form} layout="vertical" onFinish={handleSubmit} initialValues={{ role: ROLES.STAFF }}>
          <Form.Item name="account" label="帳號" rules={[{ required: true, message: '請輸入帳號' }]}>
            <Input disabled={!!editingUser} />
          </Form.Item>
          <Form.Item name="password" label="密碼" rules={editingUser ? [] : [{ required: true, message: '請輸入密碼' }] }>
            <Input.Password placeholder={editingUser ? '不修改請留空' : ''} />
          </Form.Item>
          <Form.Item name="role" label="角色" rules={[{ required: true, message: '請選擇角色' }] }>
            <Select>
              <Select.Option value={ROLES.ADMIN}>Admin</Select.Option>
              <Select.Option value={ROLES.MANAGER}>Manager</Select.Option>
              <Select.Option value={ROLES.STAFF}>Staff</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="name" label="姓名">
            <Input />
          </Form.Item>
          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit">{editingUser ? '更新' : '新增'}</Button>
              <Button onClick={() => setModalVisible(false)}>取消</Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default UsersPage; 
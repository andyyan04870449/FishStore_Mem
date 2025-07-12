import React, { useEffect, useState } from 'react';
import { 
  Card, 
  Button, 
  Table, 
  Tag, 
  message, 
  Modal, 
  Form, 
  Input, 
  Space, 
  Typography,
  Popconfirm,
  Tooltip,
  Row,
  Col,
  Statistic
} from 'antd';
import { 
  PlusOutlined, 
  DeleteOutlined, 
  CopyOutlined, 
  ReloadOutlined,
  KeyOutlined,
  DesktopOutlined
} from '@ant-design/icons';
import { api } from '../../services/api';
import { API_ENDPOINTS } from '../../constants';
import { 
  GenerateAuthCodeRequest, 
  AuthCodeResponse, 
  DeviceInfo, 
  DeviceListResponse,
  BaseResponse 
} from '../../types';
import dayjs from 'dayjs';

const { Title, Text } = Typography;

const AuthManagementPage: React.FC = () => {
  const [devices, setDevices] = useState<DeviceInfo[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [generatedCode, setGeneratedCode] = useState<string>('');
  const [form] = Form.useForm();

  const fetchDevices = async () => {
    setLoading(true);
    try {
      const response = await api.get<DeviceListResponse>(API_ENDPOINTS.AUTH_DEVICES);
      if (response.success) {
        setDevices(response.devices);
      } else {
        message.error(response.message || '取得裝置列表失敗');
      }
    } catch (err) {
      message.error('取得裝置列表失敗');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDevices();
  }, []);

  const handleGenerateCode = async (values: GenerateAuthCodeRequest) => {
    try {
      const response = await api.post<AuthCodeResponse>(API_ENDPOINTS.AUTH_GENERATE_CODE, values);
      if (response.success && response.authCode) {
        setGeneratedCode(response.authCode);
        message.success('授權碼生成成功');
        form.resetFields();
        fetchDevices(); // 重新載入裝置列表
      } else {
        message.error(response.message || '生成授權碼失敗');
      }
    } catch (err) {
      message.error('生成授權碼失敗');
    }
  };

  const handleDeleteDevice = async (deviceId: string) => {
    try {
      const response = await api.delete<BaseResponse>(`${API_ENDPOINTS.AUTH_DEVICES}/${deviceId}`);
      if (response.success) {
        message.success('裝置刪除成功');
        fetchDevices();
      } else {
        message.error(response.message || '刪除裝置失敗');
      }
    } catch (err) {
      message.error('刪除裝置失敗');
    }
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text).then(() => {
      message.success('已複製到剪貼簿');
    }).catch(() => {
      message.error('複製失敗');
    });
  };

  const columns = [
    {
      title: '授權碼',
      dataIndex: 'deviceCode',
      key: 'deviceCode',
      render: (code: string) => (
        <Space>
          <Text code>{code}</Text>
          <Tooltip title="複製授權碼">
            <Button 
              type="text" 
              size="small" 
              icon={<CopyOutlined />} 
              onClick={() => copyToClipboard(code)}
            />
          </Tooltip>
        </Space>
      ),
    },
    {
      title: '狀態',
      dataIndex: 'isActive',
      key: 'isActive',
      render: (isActive: boolean) => (
        <Tag color={isActive ? 'green' : 'red'}>
          {isActive ? '活躍' : '離線'}
        </Tag>
      ),
    },
    {
      title: '最後活動',
      dataIndex: 'lastSeen',
      key: 'lastSeen',
      render: (lastSeen: string) => dayjs(lastSeen).format('YYYY-MM-DD HH:mm:ss'),
    },
    {
      title: '操作',
      key: 'action',
      render: (_: any, record: DeviceInfo) => (
        <Popconfirm
          title="確定要刪除此裝置嗎？"
          description="刪除後，該裝置將無法再使用此授權碼登入系統。"
          onConfirm={() => handleDeleteDevice(record.deviceId)}
          okText="確定"
          cancelText="取消"
        >
          <Button type="text" danger icon={<DeleteOutlined />}>
            刪除
          </Button>
        </Popconfirm>
      ),
    },
  ];

  const activeDevices = devices.filter(d => d.isActive).length;
  const totalDevices = devices.length;

  return (
    <div style={{ padding: 24 }}>
      <Title level={2}>
        <KeyOutlined /> 授權管理
      </Title>
      
      {/* 統計資訊 */}
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={6}>
          <Card>
            <Statistic
              title="總裝置數"
              value={totalDevices}
              prefix={<DesktopOutlined />}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="活躍裝置"
              value={activeDevices}
              valueStyle={{ color: '#3f8600' }}
              prefix={<DesktopOutlined />}
            />
          </Card>
        </Col>
      </Row>

      <Card
        title="裝置管理"
        extra={
          <Space>
            <Button 
              icon={<ReloadOutlined />} 
              onClick={fetchDevices}
              loading={loading}
            >
              重新整理
            </Button>
            <Button 
              type="primary" 
              icon={<PlusOutlined />} 
              onClick={() => setModalVisible(true)}
            >
              生成授權碼
            </Button>
          </Space>
        }
      >
        <Table
          columns={columns}
          dataSource={devices}
          loading={loading}
          rowKey="deviceId"
          pagination={{ 
            pageSize: 10,
            showSizeChanger: true,
            showQuickJumper: true,
            showTotal: (total) => `共 ${total} 個裝置`
          }}
        />
      </Card>

      {/* 生成授權碼對話框 */}
      <Modal
        title="生成新授權碼"
        open={modalVisible}
        onCancel={() => {
          setModalVisible(false);
          setGeneratedCode('');
        }}
        footer={null}
        destroyOnClose
      >
        {!generatedCode ? (
          <Form form={form} layout="vertical" onFinish={handleGenerateCode}>
            <Form.Item
              name="deviceName"
              label="裝置名稱"
              rules={[{ required: true, message: '請輸入裝置名稱' }]}
            >
              <Input placeholder="例如：iPad 點餐機 1" />
            </Form.Item>
            <Form.Item>
              <Space>
                <Button type="primary" htmlType="submit">
                  生成授權碼
                </Button>
                <Button onClick={() => setModalVisible(false)}>
                  取消
                </Button>
              </Space>
            </Form.Item>
          </Form>
        ) : (
          <div>
            <div style={{ 
              background: '#f6f8fa', 
              padding: 16, 
              borderRadius: 6, 
              marginBottom: 16,
              border: '1px solid #d0d7de'
            }}>
              <Text strong>生成的授權碼：</Text>
              <br />
              <Text code style={{ fontSize: 18, marginTop: 8, display: 'inline-block' }}>
                {generatedCode}
              </Text>
              <br />
              <Button 
                type="link" 
                icon={<CopyOutlined />} 
                onClick={() => copyToClipboard(generatedCode)}
                style={{ padding: 0, marginTop: 8 }}
              >
                複製授權碼
              </Button>
            </div>
            <div style={{ 
              background: '#fff7e6', 
              padding: 12, 
              borderRadius: 6, 
              border: '1px solid #ffd591',
              marginBottom: 16
            }}>
              <Text type="warning">
                <strong>重要提醒：</strong>
                <br />
                • 請將此授權碼安全地提供給前端 App 使用
                <br />
                • 授權碼生成後無法修改，請妥善保管
                <br />
                • 如需撤銷授權，請在裝置列表中刪除對應裝置
              </Text>
            </div>
            <Button type="primary" onClick={() => {
              setModalVisible(false);
              setGeneratedCode('');
            }}>
              完成
            </Button>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default AuthManagementPage; 
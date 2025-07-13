import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Modal, Form, Input, DatePicker, message, Card, Statistic, Row, Col } from 'antd';
import { SearchOutlined, EyeOutlined, DownloadOutlined, ReloadOutlined } from '@ant-design/icons';
import { Order } from '../types';
import { api } from '../services/api';
import { API_ENDPOINTS, API_BASE_URL } from '../constants';
import dayjs from 'dayjs';

const { RangePicker } = DatePicker;

const OrdersPage: React.FC = () => {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchForm] = Form.useForm();
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 20,
    total: 0,
  });

  // 取得今天的日期
  const today = dayjs();

  // 取得訂單列表
  const fetchOrders = async (params: any = {}) => {
    try {
      setLoading(true);
      const queryParams = new URLSearchParams({
        page: params.current || pagination.current.toString(),
        pageSize: params.pageSize || pagination.pageSize.toString(),
        ...params,
      });

      const response = await api.get<{
        data: Order[];
        total: number;
        page: number;
        pageSize: number;
      }>(`${API_ENDPOINTS.ORDERS}?${queryParams}`);

      setOrders(response.data);
      setPagination({
        current: response.page,
        pageSize: response.pageSize,
        total: response.total,
      });
    } catch (error) {
      message.error('取得訂單失敗');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // 初始化搜尋表單，設定預設值為今天
    searchForm.setFieldsValue({
      businessDay: today,
      dateRange: [today, today],
    });
    
    // 載入今天的訂單
    fetchOrders({
      businessDay: today.format('YYYY-MM-DD'),
      startDate: today.format('YYYY-MM-DD'),
      endDate: today.format('YYYY-MM-DD'),
    });
  }, []);

  // 搜尋訂單
  const handleSearch = async (values: any) => {
    const searchParams: any = {};
    
    if (values.orderId) {
      searchParams.orderId = values.orderId;
    }
    
    if (values.businessDay) {
      searchParams.businessDay = values.businessDay.format('YYYY-MM-DD');
    }
    
    if (values.dateRange && values.dateRange.length === 2) {
      searchParams.startDate = values.dateRange[0].format('YYYY-MM-DD');
      searchParams.endDate = values.dateRange[1].format('YYYY-MM-DD');
    }

    await fetchOrders({ ...searchParams, current: 1 });
  };

  // 重置搜尋
  const handleReset = () => {
    // 重置為今天的日期
    searchForm.setFieldsValue({
      orderId: undefined,
      businessDay: today,
      dateRange: [today, today],
    });
    
    // 重新載入今天的訂單
    fetchOrders({
      businessDay: today.format('YYYY-MM-DD'),
      startDate: today.format('YYYY-MM-DD'),
      endDate: today.format('YYYY-MM-DD'),
      current: 1,
    });
  };

  // 查看訂單詳情
  const handleView = (order: Order) => {
    Modal.info({
      title: `訂單詳情 - ${order.orderId}`,
      width: 800,
      content: (
        <div>
          <Row gutter={16} style={{ marginBottom: 16 }}>
            <Col span={8}>
              <Statistic title="訂單編號" value={order.orderId} />
            </Col>
            <Col span={8}>
              <Statistic title="營業日期" value={order.businessDay} />
            </Col>
            <Col span={8}>
              <Statistic title="總金額" value={order.total} prefix="$" />
            </Col>
          </Row>
          
          <Card title="訂單項目" size="small">
            <Table
              dataSource={order.items}
              columns={[
                { title: '商品名稱', dataIndex: 'name', key: 'name' },
                { title: '數量', dataIndex: 'qty', key: 'qty', width: 80 },
                { 
                  title: '單價', 
                  dataIndex: 'unitPrice', 
                  key: 'unitPrice',
                  width: 100,
                  render: (price: number) => `$${price}`
                },
                { 
                  title: '小計', 
                  dataIndex: 'subtotal', 
                  key: 'subtotal',
                  width: 100,
                  render: (subtotal: number) => `$${subtotal}`
                },
              ]}
              pagination={false}
              size="small"
              summary={() => (
                <Table.Summary.Row>
                  <Table.Summary.Cell index={0} colSpan={3}>
                    <strong>總計</strong>
                  </Table.Summary.Cell>
                  <Table.Summary.Cell index={1}>
                    <strong>${order.total}</strong>
                  </Table.Summary.Cell>
                </Table.Summary.Row>
              )}
            />
          </Card>
          
          <div style={{ marginTop: 16 }}>
            <p><strong>建立時間：</strong>{order.createdAt}</p>
          </div>
        </div>
      ),
    });
  };

  // 匯出訂單
  const handleExport = async () => {
    try {
      const values = searchForm.getFieldsValue();
      const queryParams = new URLSearchParams();
      
      if (values.dateRange && values.dateRange.length === 2) {
        queryParams.append('startDate', values.dateRange[0].format('YYYY-MM-DD'));
        queryParams.append('endDate', values.dateRange[1].format('YYYY-MM-DD'));
      }

      const response = await fetch(`${API_BASE_URL}/api/v1/orders/export?${queryParams}`, {
        headers: {
          'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
        },
      });

      if (!response.ok) {
        throw new Error('匯出失敗');
      }

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `orders_${dayjs().format('YYYY-MM-DD')}.xlsx`;
      link.click();
      window.URL.revokeObjectURL(url);

      message.success('匯出成功');
    } catch (error) {
      message.error('匯出失敗');
    }
  };

  // 表格欄位定義
  const columns = [
    {
      title: '訂單編號',
      dataIndex: 'orderId',
      key: 'orderId',
      width: 150,
    },
    {
      title: '營業日期',
      dataIndex: 'businessDay',
      key: 'businessDay',
      width: 120,
    },
    {
      title: '項目數量',
      key: 'itemCount',
      width: 100,
      render: (text: string, record: Order) => record.items.length,
    },
    {
      title: '總金額',
      dataIndex: 'total',
      key: 'total',
      width: 120,
      render: (total: number) => `$${total}`,
    },
    {
      title: '建立時間',
      dataIndex: 'createdAt',
      key: 'createdAt',
      width: 180,
      render: (date: string) => dayjs(date).format('YYYY-MM-DD HH:mm:ss'),
    },
    {
      title: '操作',
      key: 'action',
      width: 120,
      render: (text: string, record: Order) => (
        <Space size="small">
          <Button
            type="link"
            icon={<EyeOutlined />}
            onClick={() => handleView(record)}
          >
            查看
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between' }}>
        <h1>訂單管理</h1>
        <Space>
          <Button
            icon={<DownloadOutlined />}
            onClick={handleExport}
          >
            匯出訂單
          </Button>
          <Button
            icon={<ReloadOutlined />}
            onClick={() => fetchOrders()}
          >
            重新整理
          </Button>
        </Space>
      </div>

      {/* 搜尋表單 */}
      <Card style={{ marginBottom: 16 }}>
        <Form
          form={searchForm}
          layout="inline"
          onFinish={handleSearch}
        >
          <Form.Item name="orderId" label="訂單編號">
            <Input placeholder="請輸入訂單編號" style={{ width: 200 }} />
          </Form.Item>
          
          <Form.Item name="businessDay" label="營業日期">
            <DatePicker placeholder="選擇日期" />
          </Form.Item>
          
          <Form.Item name="dateRange" label="日期範圍">
            <RangePicker />
          </Form.Item>
          
          <Form.Item>
            <Space>
              <Button type="primary" icon={<SearchOutlined />} htmlType="submit">
                搜尋
              </Button>
              <Button onClick={handleReset}>
                重置
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Card>

      {/* 訂單列表 */}
      <Table
        columns={columns}
        dataSource={orders}
        loading={loading}
        rowKey="id"
        pagination={{
          ...pagination,
          showSizeChanger: true,
          showQuickJumper: true,
          showTotal: (total) => `共 ${total} 筆資料`,
          onChange: (page, pageSize) => {
            fetchOrders({ current: page, pageSize });
          },
        }}
      />
    </div>
  );
};

export default OrdersPage; 
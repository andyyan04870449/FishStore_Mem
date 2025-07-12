import React, { useEffect, useState } from 'react';
import { Card, Row, Col, Statistic, Spin, message } from 'antd';
import { ShoppingCartOutlined, DollarOutlined, UserOutlined, FileTextOutlined } from '@ant-design/icons';
import dayjs from 'dayjs';
import { api } from '../services/api';
import { API_ENDPOINTS } from '../constants';

const DashboardPage: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [revenue, setRevenue] = useState<number>(0);
  const [orderCount, setOrderCount] = useState<number>(0);
  const [menuItemCount, setMenuItemCount] = useState<number>(0);
  const [lastUpdated, setLastUpdated] = useState<string>('');

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        // 今日日期
        const today = dayjs().format('YYYY-MM-DD');
        // 取得今日營業額與訂單數
        const report = await api.get<any>(`${API_ENDPOINTS.REPORTS}?from=${today}&to=${today}`);
        setRevenue(report.total || 0);
        setOrderCount(report.count || 0);
        // 取得菜單項目數
        try {
          const menu = await api.get<any>(API_ENDPOINTS.MENU);
          // 統計所有品項數量
          let count = 0;
          if (menu.menu && Array.isArray(menu.menu.categories)) {
            menu.menu.categories.forEach((cat: any) => {
              if (Array.isArray(cat.items)) count += cat.items.length;
            });
          }
          setMenuItemCount(count);
          setLastUpdated(menu.lastUpdated ? dayjs(menu.lastUpdated).format('YYYY-MM-DD HH:mm:ss') : '');
        } catch (err: any) {
          setMenuItemCount(0);
          setLastUpdated('');
        }
      } catch (err: any) {
        message.error('取得儀表板資料失敗');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  return (
    <div style={{ padding: '24px' }}>
      <h1>儀表板</h1>
      <Spin spinning={loading}>
        <Row gutter={[16, 16]}>
          <Col xs={24} sm={12} lg={6}>
            <Card>
              <Statistic
                title="今日營業額"
                value={revenue}
                prefix={<DollarOutlined />}
                suffix="元"
              />
            </Card>
          </Col>
          <Col xs={24} sm={12} lg={6}>
            <Card>
              <Statistic
                title="今日訂單數"
                value={orderCount}
                prefix={<ShoppingCartOutlined />}
                suffix="筆"
              />
            </Card>
          </Col>
          <Col xs={24} sm={12} lg={6}>
            <Card>
              <Statistic
                title="活躍使用者"
                value={0}
                prefix={<UserOutlined />}
                suffix="人"
              />
            </Card>
          </Col>
          <Col xs={24} sm={12} lg={6}>
            <Card>
              <Statistic
                title="菜單項目"
                value={menuItemCount}
                prefix={<FileTextOutlined />}
                suffix="項"
              />
            </Card>
          </Col>
        </Row>
        <Row gutter={[16, 16]} style={{ marginTop: '24px' }}>
          <Col xs={24} lg={12}>
            <Card title="系統狀態">
              <p>API 服務：正常</p>
              <p>資料庫連線：正常</p>
              <p>最後更新：{lastUpdated || '尚無資料'}</p>
            </Card>
          </Col>
          <Col xs={24} lg={12}>
            <Card title="快速操作">
              <p>• 查看今日訂單</p>
              <p>• 管理菜單</p>
              <p>• 生成報表</p>
              <p>• 系統設定</p>
            </Card>
          </Col>
        </Row>
      </Spin>
    </div>
  );
};

export default DashboardPage; 
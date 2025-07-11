import React from 'react';
import { Card, Row, Col, Statistic } from 'antd';
import { ShoppingCartOutlined, DollarOutlined, UserOutlined, FileTextOutlined } from '@ant-design/icons';

const DashboardPage: React.FC = () => {
  return (
    <div style={{ padding: '24px' }}>
      <h1>儀表板</h1>
      
      <Row gutter={[16, 16]}>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="今日營業額"
              value={12580}
              prefix={<DollarOutlined />}
              suffix="元"
            />
          </Card>
        </Col>
        
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="今日訂單數"
              value={45}
              prefix={<ShoppingCartOutlined />}
              suffix="筆"
            />
          </Card>
        </Col>
        
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="活躍使用者"
              value={12}
              prefix={<UserOutlined />}
              suffix="人"
            />
          </Card>
        </Col>
        
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="菜單項目"
              value={156}
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
            <p>最後更新：2025-07-11 17:45:00</p>
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
    </div>
  );
};

export default DashboardPage; 
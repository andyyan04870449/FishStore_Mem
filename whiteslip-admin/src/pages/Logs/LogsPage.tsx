import React from 'react';
import { Table, Card } from 'antd';

const data = [
  { time: '2025-07-12 10:00:00', account: 'admin', action: '登入', desc: '成功登入系統' },
  { time: '2025-07-12 10:05:00', account: 'admin', action: '新增使用者', desc: '建立帳號 manager1' },
  { time: '2025-07-12 10:10:00', account: 'manager1', action: '查詢報表', desc: '查詢 7/1~7/12 營業額' },
  { time: '2025-07-12 10:15:00', account: 'admin', action: '刪除訂單', desc: '刪除訂單 20250712-0001' },
];

const columns = [
  { title: '操作時間', dataIndex: 'time', key: 'time' },
  { title: '帳號', dataIndex: 'account', key: 'account' },
  { title: '動作', dataIndex: 'action', key: 'action' },
  { title: '描述', dataIndex: 'desc', key: 'desc' },
];

const LogsPage: React.FC = () => (
  <div style={{ padding: 24 }}>
    <h1>操作日誌</h1>
    <Card>
      <Table columns={columns} dataSource={data} rowKey="time" pagination={{ pageSize: 10 }} />
    </Card>
  </div>
);

export default LogsPage; 
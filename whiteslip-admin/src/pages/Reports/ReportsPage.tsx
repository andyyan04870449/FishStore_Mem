import React, { useState, useEffect } from 'react';
import { Card, Row, Col, DatePicker, Button, Tabs, message } from 'antd';
import { Bar, Line, Pie } from '@ant-design/charts';
import dayjs from 'dayjs';
import { api } from '../../services/api';
import { API_ENDPOINTS } from '../../constants';
import { useSelector } from 'react-redux';
import { RootState } from '../../store';
import { hasPermission } from '../../utils/permission';

const { RangePicker } = DatePicker;

const ReportsPage: React.FC = () => {
  // 預設查詢本月
  const [dateRange, setDateRange] = useState<any>([
    dayjs().startOf('month'),
    dayjs().endOf('month'),
  ]);
  const [loading, setLoading] = useState(false);
  const [salesData, setSalesData] = useState<any[]>([]);
  const [orderTrend, setOrderTrend] = useState<any[]>([]);

  const { user } = useSelector((state: RootState) => state.auth);
  const role = user?.role;

  // 商品排行暫以假資料
  const productRank = [
    { name: '可樂', sales: 120 },
    { name: '奶茶', sales: 98 },
    { name: '漢堡', sales: 80 },
    { name: '薯條', sales: 75 },
    { name: '雞塊', sales: 60 },
  ];

  const fetchReport = async () => {
    if (!dateRange || dateRange.length !== 2) return;
    setLoading(true);
    try {
      const from = dateRange[0].format('YYYY-MM-DD');
      const to = dateRange[1].format('YYYY-MM-DD');
      const report = await api.get<any>(`${API_ENDPOINTS.REPORTS}?from=${from}&to=${to}`);
      // 依據回傳的 orders 產生圖表資料
      const sales = report.orders.map((o: any) => ({ date: o.businessDay, revenue: o.total }));
      setSalesData(sales);
      const trend = report.orders.map((o: any) => ({ date: o.businessDay, orders: 1 }));
      // 將同一天的訂單數加總
      const trendMap: Record<string, number> = {};
      trend.forEach((item: any) => {
        trendMap[item.date] = (trendMap[item.date] || 0) + 1;
      });
      setOrderTrend(Object.entries(trendMap).map(([date, orders]) => ({ date, orders })));
    } catch (err: any) {
      message.error('取得報表資料失敗');
      setSalesData([]);
      setOrderTrend([]);
    } finally {
      setLoading(false);
    }
  };

  const handleExport = async () => {
    if (!dateRange || dateRange.length !== 2) return;
    try {
      const from = dateRange[0].format('YYYY-MM-DD');
      const to = dateRange[1].format('YYYY-MM-DD');
      const token = localStorage.getItem('token');
      const url = `${process.env.REACT_APP_API_URL || 'http://localhost:5001'}${API_ENDPOINTS.REPORTS}/csv?from=${from}&to=${to}`;
      const response = await fetch(url, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      if (!response.ok) throw new Error('匯出失敗');
      const blob = await response.blob();
      const link = document.createElement('a');
      link.href = window.URL.createObjectURL(blob);
      link.download = `report_${from}_${to}.csv`;
      link.click();
    } catch (err) {
      message.error('匯出失敗');
    }
  };

  useEffect(() => {
    fetchReport();
    // eslint-disable-next-line
  }, []);

  return (
    <div style={{ padding: 24 }}>
      <h1>報表分析</h1>
      <Card style={{ marginBottom: 24 }}>
        <Row gutter={16} align="middle">
          <Col>
            <span>查詢區間：</span>
            <RangePicker
              value={dateRange}
              onChange={setDateRange}
              style={{ marginRight: 16 }}
              allowClear={false}
            />
          </Col>
          <Col>
            <Button type="primary" loading={loading} onClick={fetchReport}>查詢</Button>
          </Col>
          <Col>
            {role && hasPermission(role, 'Manager') && (
              <Button onClick={handleExport} loading={loading}>匯出 CSV</Button>
            )}
          </Col>
        </Row>
      </Card>
      <Tabs defaultActiveKey="1" destroyInactiveTabPane items={[
        {
          key: '1',
          label: '營業額統計',
          children: (
            <Card title="營業額統計圖表" style={{ marginBottom: 24 }}>
              <Bar
                key="bar-chart"
                data={salesData}
                xField="date"
                yField="revenue"
                xAxis={{ title: { text: '日期' } }}
                yAxis={{ title: { text: '營業額' } }}
                height={300}
                loading={loading}
              />
            </Card>
          ),
        },
        {
          key: '2',
          label: '訂單趨勢',
          children: (
            <Card title="訂單趨勢圖表" style={{ marginBottom: 24 }}>
              <Line
                key="line-chart"
                data={orderTrend}
                xField="date"
                yField="orders"
                xAxis={{ title: { text: '日期' } }}
                yAxis={{ title: { text: '訂單數' } }}
                height={300}
                loading={loading}
              />
            </Card>
          ),
        },
        {
          key: '3',
          label: '商品排行',
          children: (
            <Card title="商品銷售排行" style={{ marginBottom: 24 }}>
              <Pie
                key="pie-chart"
                data={productRank}
                angleField="sales"
                colorField="name"
                radius={0.8}
                label={{ type: 'outer', content: '{name} {percentage}' }}
                height={300}
              />
            </Card>
          ),
        },
      ]} />
    </div>
  );
};

export default ReportsPage; 
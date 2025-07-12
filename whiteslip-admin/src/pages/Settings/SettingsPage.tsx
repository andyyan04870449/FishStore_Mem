import React, { useState } from 'react';
import { Card, Tabs, Form, Input, Button, Select, Switch, message, Space } from 'antd';

const { TabPane } = Tabs;

const SettingsPage: React.FC = () => {
  // 本地狀態模擬
  const [basicForm] = Form.useForm();
  const [securityForm] = Form.useForm();
  const [notifyForm] = Form.useForm();
  const [backupForm] = Form.useForm();

  const handleSave = (type: string, values: any) => {
    message.success(`${type} 已儲存（僅本地模擬）`);
  };

  return (
    <div style={{ padding: 24 }}>
      <h1>系統設定</h1>
      <Card>
        <Tabs defaultActiveKey="basic">
          <TabPane tab="基本設定" key="basic">
            <Form form={basicForm} layout="vertical" onFinish={v => handleSave('基本設定', v)} initialValues={{ systemName: 'WhiteSlip', timezone: 'Asia/Taipei', language: 'zh-TW', theme: 'light' }}>
              <Form.Item name="systemName" label="系統名稱" rules={[{ required: true, message: '請輸入系統名稱' }]}> <Input /> </Form.Item>
              <Form.Item name="timezone" label="時區" rules={[{ required: true }]}> <Select><Select.Option value="Asia/Taipei">台北</Select.Option><Select.Option value="Asia/Tokyo">東京</Select.Option></Select> </Form.Item>
              <Form.Item name="language" label="語言" rules={[{ required: true }]}> <Select><Select.Option value="zh-TW">繁體中文</Select.Option><Select.Option value="en-US">English</Select.Option></Select> </Form.Item>
              <Form.Item name="theme" label="主題"> <Select><Select.Option value="light">淺色</Select.Option><Select.Option value="dark">深色</Select.Option></Select> </Form.Item>
              <Form.Item> <Button type="primary" htmlType="submit">儲存</Button> </Form.Item>
            </Form>
          </TabPane>
          <TabPane tab="安全設定" key="security">
            <Form form={securityForm} layout="vertical" onFinish={v => handleSave('安全設定', v)} initialValues={{ passwordPolicy: 'medium', loginLimit: 5, sessionTimeout: 30 }}>
              <Form.Item name="passwordPolicy" label="密碼強度" rules={[{ required: true }]}> <Select><Select.Option value="low">低</Select.Option><Select.Option value="medium">中</Select.Option><Select.Option value="high">高</Select.Option></Select> </Form.Item>
              <Form.Item name="loginLimit" label="登入失敗次數上限" rules={[{ required: true }]}> <Input type="number" min={1} max={10} /> </Form.Item>
              <Form.Item name="sessionTimeout" label="Session 逾時（分鐘）" rules={[{ required: true }]}> <Input type="number" min={5} max={120} /> </Form.Item>
              <Form.Item> <Button type="primary" htmlType="submit">儲存</Button> </Form.Item>
            </Form>
          </TabPane>
          <TabPane tab="通知設定" key="notify">
            <Form form={notifyForm} layout="vertical" onFinish={v => handleSave('通知設定', v)} initialValues={{ email: '', enableNotify: false }}>
              <Form.Item name="email" label="通知 Email"> <Input type="email" /> </Form.Item>
              <Form.Item name="enableNotify" label="啟用通知" valuePropName="checked"> <Switch /> </Form.Item>
              <Form.Item> <Button type="primary" htmlType="submit">儲存</Button> </Form.Item>
            </Form>
          </TabPane>
          <TabPane tab="備份設定" key="backup">
            <Form form={backupForm} layout="vertical" onFinish={v => handleSave('備份設定', v)} initialValues={{ backupTime: '03:00', keepDays: 7 }}>
              <Form.Item name="backupTime" label="備份時間"> <Input placeholder="03:00" /> </Form.Item>
              <Form.Item name="keepDays" label="保留天數" rules={[{ required: true }]}> <Input type="number" min={1} max={365} /> </Form.Item>
              <Form.Item> <Button type="primary" htmlType="submit">儲存</Button> </Form.Item>
            </Form>
          </TabPane>
        </Tabs>
      </Card>
    </div>
  );
};

export default SettingsPage; 
import React from 'react';
import { Form, Input, Button, Card, message } from 'antd';
import { UserOutlined, LockOutlined } from '@ant-design/icons';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '../store';
import { loginStart, loginSuccess, loginFailure } from '../store/slices/authSlice';
import { LoginRequest } from '../types';
import { authService } from '../services/authService';

const LoginPage: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { isLoading, error } = useSelector((state: RootState) => state.auth);

  const onFinish = async (values: LoginRequest) => {
    try {
      dispatch(loginStart());
      
      const response = await authService.login(values);

      if (response.success) {
        dispatch(loginSuccess({
          user: {
            id: '1',
            account: values.account,
            role: response.role as 'Admin' | 'Manager' | 'Staff',
          },
          token: response.token,
        }));
        message.success('登入成功');
      } else {
        dispatch(loginFailure(response.message || '登入失敗'));
      }
    } catch (err) {
      dispatch(loginFailure('網路錯誤，請稍後再試'));
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: '#f0f2f5',
    }}>
      <Card
        title="白單機點餐系統 - 管理介面"
        style={{ width: 400 }}
        headStyle={{ textAlign: 'center', fontSize: '18px' }}
      >
        <Form
          name="login"
          onFinish={onFinish}
          autoComplete="off"
          size="large"
        >
          <Form.Item
            name="account"
            rules={[{ required: true, message: '請輸入帳號' }]}
          >
            <Input
              prefix={<UserOutlined />}
              placeholder="帳號"
            />
          </Form.Item>

          <Form.Item
            name="password"
            rules={[{ required: true, message: '請輸入密碼' }]}
          >
            <Input.Password
              prefix={<LockOutlined />}
              placeholder="密碼"
            />
          </Form.Item>

          {error && (
            <Form.Item>
              <div style={{ color: 'red', textAlign: 'center' }}>
                {error}
              </div>
            </Form.Item>
          )}

          <Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              loading={isLoading}
              style={{ width: '100%' }}
            >
              登入
            </Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
};

export default LoginPage; 
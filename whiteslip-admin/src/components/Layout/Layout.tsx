import React from 'react';
import { Layout as AntLayout, Menu, Button, Avatar, Dropdown } from 'antd';
import { MenuFoldOutlined, MenuUnfoldOutlined, UserOutlined, LogoutOutlined } from '@ant-design/icons';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { AppDispatch, RootState } from '../../store';
import { logout } from '../../store/slices/authSlice';
import { ROUTES } from '../../constants';

const { Header, Sider, Content } = AntLayout;

interface LayoutProps {
  children: React.ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const [collapsed, setCollapsed] = React.useState(false);
  const dispatch = useDispatch<AppDispatch>();
  const navigate = useNavigate();
  const { user } = useSelector((state: RootState) => state.auth);

  const handleLogout = () => {
    dispatch(logout());
    navigate('/login');
  };

  const userMenu = (
    <Menu>
      <Menu.Item key="profile" icon={<UserOutlined />}>
        個人資料
      </Menu.Item>
      <Menu.Divider />
      <Menu.Item key="logout" icon={<LogoutOutlined />} onClick={handleLogout}>
        登出
      </Menu.Item>
    </Menu>
  );

  const menuItems = [
    {
      key: ROUTES.DASHBOARD,
      icon: <UserOutlined />,
      label: '儀表板',
      onClick: () => navigate(ROUTES.DASHBOARD),
    },
    {
      key: ROUTES.MENU,
      icon: <UserOutlined />,
      label: '菜單管理',
      onClick: () => navigate(ROUTES.MENU),
    },
    {
      key: ROUTES.ORDERS,
      icon: <UserOutlined />,
      label: '訂單管理',
      onClick: () => navigate(ROUTES.ORDERS),
    },
    {
      key: ROUTES.REPORTS,
      icon: <UserOutlined />,
      label: '報表分析',
      onClick: () => navigate(ROUTES.REPORTS),
    },
    {
      key: ROUTES.USERS,
      icon: <UserOutlined />,
      label: '使用者管理',
      onClick: () => navigate(ROUTES.USERS),
    },
    {
      key: ROUTES.SETTINGS,
      icon: <UserOutlined />,
      label: '系統設定',
      onClick: () => navigate(ROUTES.SETTINGS),
    },
  ];

  return (
    <AntLayout style={{ minHeight: '100vh' }}>
      <Sider trigger={null} collapsible collapsed={collapsed}>
        <div style={{ 
          height: 32, 
          margin: 16, 
          background: 'rgba(255, 255, 255, 0.2)',
          borderRadius: 6,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: 'white',
          fontSize: collapsed ? '12px' : '16px',
          fontWeight: 'bold',
        }}>
          {collapsed ? 'WS' : 'WhiteSlip'}
        </div>
        <Menu
          theme="dark"
          mode="inline"
          defaultSelectedKeys={[ROUTES.DASHBOARD]}
          items={menuItems}
        />
      </Sider>
      
      <AntLayout>
        <Header style={{ 
          padding: '0 16px', 
          background: '#fff',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}>
          <Button
            type="text"
            icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
            onClick={() => setCollapsed(!collapsed)}
            style={{ fontSize: '16px', width: 64, height: 64 }}
          />
          
          <Dropdown overlay={userMenu} placement="bottomRight">
            <div style={{ cursor: 'pointer', display: 'flex', alignItems: 'center' }}>
              <Avatar icon={<UserOutlined />} />
              <span style={{ marginLeft: 8, color: '#333' }}>
                {user?.account || '使用者'}
              </span>
            </div>
          </Dropdown>
        </Header>
        
        <Content style={{ 
          margin: '24px 16px',
          padding: 24,
          background: '#fff',
          borderRadius: 6,
          minHeight: 280,
        }}>
          {children}
        </Content>
      </AntLayout>
    </AntLayout>
  );
};

export default Layout; 
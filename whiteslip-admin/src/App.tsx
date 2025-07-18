import React, { useEffect } from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { Provider, useDispatch } from 'react-redux';
import { ConfigProvider } from 'antd';
import zhTW from 'antd/locale/zh_TW';
import { store } from './store';
import AppRoutes from './components/AppRoutes';
import { initializeAuth } from './store/slices/authSlice';
import './App.css';

// 初始化組件
const AppInitializer: React.FC = () => {
  const dispatch = useDispatch();

  useEffect(() => {
    // 初始化認證狀態
    dispatch(initializeAuth());
  }, [dispatch]);

  return <AppRoutes />;
};

const App: React.FC = () => {
  return (
    <Provider store={store}>
      <ConfigProvider locale={zhTW}>
        <Router>
          <div className="App">
            <AppInitializer />
          </div>
        </Router>
      </ConfigProvider>
    </Provider>
  );
};

export default App;

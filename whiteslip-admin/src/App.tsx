import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { Provider } from 'react-redux';
import { ConfigProvider } from 'antd';
import zhTW from 'antd/locale/zh_TW';
import { store } from './store';
import AppRoutes from './components/AppRoutes';
import './App.css';

const App: React.FC = () => {
  return (
    <Provider store={store}>
      <ConfigProvider locale={zhTW}>
        <Router>
          <div className="App">
            <AppRoutes />
          </div>
        </Router>
      </ConfigProvider>
    </Provider>
  );
};

export default App;

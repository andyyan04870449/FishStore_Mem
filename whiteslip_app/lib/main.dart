import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: '白單機點餐系統',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[600],
          useMaterial3: true,
          fontFamily: 'NotoSansTC',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 避免在 build 階段調用 notifyListeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final appProvider = context.read<AppProvider>();
    
    // 初始化應用程式
    await appProvider.initialize();
    
    if (mounted) {
      // 根據認證狀態導航
      if (appProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Icon(
              Icons.receipt_long,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 32),
            
            // 標題
            Text(
              '白單機點餐系統',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // 副標題
            Text(
              'WhiteSlip Order System',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 64),
            
            // 載入指示器
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 24),
            
            // 載入文字
            Text(
              '系統初始化中...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

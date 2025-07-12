import 'dart:typed_data';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../models/order.dart';

class PrintService {
  static const int _paperWidth = 80; // 80mm 紙張寬度
  static const int _logoWidth = 256;
  static const int _logoHeight = 96;

  // 生成訂單流水號
  static String generateOrderId() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    // 這裡應該從本地儲存取得當日序號
    // 暫時使用時間戳作為序號
    final sequence = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    
    return '$dateStr-$sequence';
  }

  // 生成營業日
  static String generateBusinessDay() {
    DateTime now = DateTime.now();
    // 營業日切點為 02:00，如果當前時間在 00:00-02:00，則算前一天的營業日
    if (now.hour < 2) {
      now = now.subtract(const Duration(days: 1));
    }
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  // 生成 ESC/POS 指令
  static List<int> generatePrintCommands(Order order, {Uint8List? logoData}) {
    // Web/mock: 不產生 ESC/POS 指令
    return [];
  }

  // 列印 Logo
  static List<int> _printLogo(Uint8List logoData) {
    // 這裡應該使用 Sewoo SDK 的 Logo 列印功能
    // 暫時返回空指令
    return [];
  }

  // 列印訂單項目
  static List<int> _printOrderItem(OrderItem item) {
    // Web/mock: 不產生 ESC/POS 指令
    return [];
  }

  // 格式化日期時間
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // 模擬列印（用於測試）
  static Future<bool> simulatePrint(Order order) async {
    try {
      // 模擬列印延遲
      await Future.delayed(const Duration(seconds: 2));
      
      // 這裡應該實際發送指令到印表機
      // 暫時返回成功
      return true;
    } catch (e) {
      return false;
    }
  }

  // 檢查印表機連線狀態
  static Future<bool> checkPrinterConnection() async {
    try {
      // 這裡應該檢查 Sewoo 印表機的連線狀態
      // 暫時返回 true
      return true;
    } catch (e) {
      return false;
    }
  }
} 
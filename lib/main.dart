import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'dich_vu/xac_thuc.dart';
// Nếu bạn đã chạy `flutterfire configure` thì mở comment 2 dòng dưới:
// import 'firebase_options.dart';

import 'man_hinh/khung_chinh.dart'; // Giữ nguyên file khung chính của bạn

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cách A (khuyên dùng nếu đã có firebase_options.dart):
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Cách B (Android chỉ với google-services.json vẫn chạy được):
  await Firebase.initializeApp();

  // RẤT QUAN TRỌNG: đồng bộ trạng thái đăng nhập cho toàn app
  AuthService.I.khoiDong();

  runApp(const RestaurantBookingApp());
}

class RestaurantBookingApp extends StatelessWidget {
  const RestaurantBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đặt bàn nhà hàng',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const KhungChinh(), // màn hình gốc của bạn
    );
  }
}

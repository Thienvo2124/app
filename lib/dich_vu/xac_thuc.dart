import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// AuthService dạng singleton giúp UI lắng nghe trạng thái đăng nhập dễ dàng.
/// Dùng: AuthService.I.hienTai (ValueListenable<User?>)
class AuthService {
  AuthService._();
  static final AuthService I = AuthService._();

  final ValueNotifier<User?> hienTai = ValueNotifier<User?>(null);
  StreamSubscription<User?>? _sub;

  /// Gọi một lần khi khởi động app (main.dart đã gọi)
  void khoiDong() {
    _sub?.cancel();
    _sub = FirebaseAuth.instance.authStateChanges().listen((u) {
      hienTai.value = u;
    });
    // Gán ngay user hiện tại nếu có (tránh chờ tick đầu tiên)
    hienTai.value = FirebaseAuth.instance.currentUser;
  }

  Future<void> dangXuat() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Tuỳ UI của bạn: có thể thêm đăng nhập ẩn danh/dùng email & password
  Future<UserCredential> dangNhapAnDanh() async {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    return cred;
  }

  void dispose() {
    _sub?.cancel();
  }
}

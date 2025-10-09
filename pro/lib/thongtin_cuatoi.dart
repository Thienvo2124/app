import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThongTinCuaToi extends StatelessWidget {
  final VoidCallback onSignOut;

  const ThongTinCuaToi({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? 'Không có dữ liệu';
    final String uid = user?.uid ?? 'Không có dữ liệu';
    final String emailStatus = user != null && user.emailVerified ? 'Có' : 'Chưa';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('👤 Hồ sơ của bạn',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text('Email: $email'),
          SizedBox(height: 10),
          Text('UID: $uid'),
          SizedBox(height: 10),
          Text('Email đã xác thực: $emailStatus'),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              onSignOut(); // Gọi lại để cập nhật tab
            },
            icon: Icon(Icons.logout),
            label: Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

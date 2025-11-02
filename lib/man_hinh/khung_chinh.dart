import 'package:flutter/material.dart';
import 'danh_sach_nha_hang_page.dart';
import 'ban_da_dat_page.dart';
import 'tai_khoan_page.dart';

class KhungChinh extends StatefulWidget {
  const KhungChinh({super.key});

  @override
  State<KhungChinh> createState() => _KhungChinhState();
}

class _KhungChinhState extends State<KhungChinh> {
  int _index = 0;

  final _pages = const [
    DanhSachNhaHangPage(), // Trang chủ
    BanDaDatPage(),        // Bàn đã đặt
    TaiKhoanPage(),        // Tài khoản
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.event_seat_outlined), selectedIcon: Icon(Icons.event_seat), label: 'Bàn đã đặt'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}

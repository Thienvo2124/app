import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../man_hinh/tai_khoan_page.dart';
import '../man_hinh/dat_ban_page.dart';
import '../mo_hinh/nha_hang.dart';

class TheNhaHang extends StatelessWidget {
  final NhaHang nhaHang;
  const TheNhaHang({super.key, required this.nhaHang});

  void _moDangNhap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Yêu cầu đăng nhập'),
        action: SnackBarAction(
          label: 'Đăng nhập',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaiKhoanPage(nhaHangMuonDat: nhaHang),
              ),
            );
          },
        ),
      ),
    );
  }

  void _moDatBan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DatBanPage(
          restaurantId: nhaHang.id,     // CHẮC CHẮN CẦN
          restaurantName: nhaHang.ten,  // nếu model bạn dùng name -> đổi lại .name
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {}, // mở chi tiết nếu cần
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Không dựa vào anhUrl nữa -> placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image, size: 48)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nhaHang.ten,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(nhaHang.diaChi ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => user == null ? _moDangNhap(context) : _moDatBan(context),
                      child: const Text('Đặt bàn'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

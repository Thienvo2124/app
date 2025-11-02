import 'package:flutter/material.dart';
import '../mo_hinh/nha_hang.dart';
import 'dat_ban_page.dart';

class ChiTietNhaHangPage extends StatelessWidget {
  final NhaHang nhaHang;
  const ChiTietNhaHangPage({super.key, required this.nhaHang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nhaHang.ten)),
      body: ListView(
        children: [
          // Không dùng anhUrl -> placeholder
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.image, size: 64)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nhaHang.ten, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                if (nhaHang.diaChi != null) Text(nhaHang.diaChi!),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DatBanPage(
                            restaurantId: nhaHang.id,
                            restaurantName: nhaHang.ten,
                          ),
                        ),
                      );
                    },
                    child: const Text('Đặt bàn'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

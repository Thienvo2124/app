import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../mo_hinh/don_dat_ban.dart';

class BanDaDatPage extends StatefulWidget {
  const BanDaDatPage({super.key});

  @override
  State<BanDaDatPage> createState() => _BanDaDatPageState();
}

class _BanDaDatPageState extends State<BanDaDatPage> {
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;

  List<DonDatBan> _items = [];
  bool _loading = true;

  String get _storageKey {
    final uid = _auth.currentUser?.uid;
    return uid == null ? 'don_dat_ban_local_guest' : 'don_dat_ban_local_$uid';
  }

  @override
  void initState() {
    super.initState();
    _load();
    // Tự reload khi user đăng nhập/đăng xuất
    _sub = _auth.authStateChanges().listen((_) => _load());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_storageKey) ?? <String>[];
    _items = list.map((e) => DonDatBan.fromJson(e)).toList();
    setState(() => _loading = false);
  }

  Future<void> _deleteAt(int index) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_storageKey) ?? <String>[];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await sp.setStringList(_storageKey, list);
      await _load();
    }
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá tất cả'),
        content: const Text('Xoá toàn bộ đơn của người dùng hiện tại?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (ok == true) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_storageKey);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bàn đã đặt'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Xoá tất cả',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_items.isEmpty
          ? const _EmptyState()
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) =>
              _BookingCard(don: _items[i], onDelete: () => _deleteAt(i)),
        ),
      )),
      bottomNavigationBar: user == null
          ? const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Text(
          'Bạn đang xem các đơn lưu ở chế độ khách (guest). '
              'Hãy đăng nhập để xem đơn gắn với tài khoản của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      )
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.playlist_remove, size: 72, color: Colors.black45),
            SizedBox(height: 12),
            Text('Chưa có bàn nào được đặt.', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Hãy vào Trang chủ để đặt bàn nhé!', style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final DonDatBan don;
  final VoidCallback onDelete;
  const _BookingCard({required this.don, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final tg = don.thoiGian;
    final timeStr =
        '${tg.hour.toString().padLeft(2, '0')}:${tg.minute.toString().padLeft(2, '0')} '
        '${tg.day.toString().padLeft(2, '0')}/${tg.month.toString().padLeft(2, '0')}/${tg.year}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    don.nhaHangTen,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Xoá',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(don.diaDiem, style: const TextStyle(color: Colors.black54))),
                const SizedBox(width: 8),
                const Icon(Icons.schedule_outlined, size: 16),
                const SizedBox(width: 4),
                Text(timeStr, style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.groups_2_outlined, size: 16),
                const SizedBox(width: 4),
                Text('${don.soNguoi} người'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(don.tenKhachHang)),
                const SizedBox(width: 8),
                const Icon(Icons.phone_outlined, size: 16),
                const SizedBox(width: 4),
                Text(don.sdt),
              ],
            ),
            if (don.ghiChu.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Ghi chú: ${don.ghiChu}'),
            ],
          ],
        ),
      ),
    );
  }
}

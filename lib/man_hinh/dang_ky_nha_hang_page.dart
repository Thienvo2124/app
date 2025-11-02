import 'package:flutter/material.dart';

class DangKyNhaHangPage extends StatefulWidget {
  const DangKyNhaHangPage({super.key});

  @override
  State<DangKyNhaHangPage> createState() => _DangKyNhaHangPageState();
}

class _DangKyNhaHangPageState extends State<DangKyNhaHangPage> {
  final _formKey = GlobalKey<FormState>();
  final _tenCtl = TextEditingController();
  final _thanhPhoCtl = TextEditingController();
  final _amThucCtl = TextEditingController();
  final _diaChiCtl = TextEditingController();
  final _moTaCtl = TextEditingController();
  final _anhUrlCtl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _tenCtl.dispose();
    _thanhPhoCtl.dispose();
    _amThucCtl.dispose();
    _diaChiCtl.dispose();
    _moTaCtl.dispose();
    _anhUrlCtl.dispose();
    super.dispose();
  }

  Future<void> _guiDangKy() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 600)); // giả lập
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi đăng ký nhà hàng!')),
    );
    Navigator.pop(context); // quay lại trang Tài khoản
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký nhà hàng')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _tenCtl,
                decoration: const InputDecoration(
                  labelText: 'Tên nhà hàng',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên nhà hàng' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _thanhPhoCtl,
                decoration: const InputDecoration(
                  labelText: 'Thành phố',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập thành phố' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amThucCtl,
                decoration: const InputDecoration(
                  labelText: 'Ẩm thực (VD: Việt Nam, Nhật...)',
                  prefixIcon: Icon(Icons.rice_bowl_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diaChiCtl,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _anhUrlCtl,
                decoration: const InputDecoration(
                  labelText: 'Ảnh đại diện (URL)',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _moTaCtl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _busy ? null : _guiDangKy,
                icon: _busy
                    ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send),
                label: Text(_busy ? 'Đang gửi...' : 'Gửi đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

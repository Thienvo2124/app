import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatBanPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final TimeOfDay? moCua;   // nếu bạn có dữ liệu giờ mở cửa
  final TimeOfDay? dongCua; // nếu bạn có dữ liệu giờ đóng cửa

  const DatBanPage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    this.moCua,
    this.dongCua,
  });

  @override
  State<DatBanPage> createState() => _DatBanPageState();
}

class _DatBanPageState extends State<DatBanPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _ngay;
  TimeOfDay? _gio;
  int _soNguoi = 2;
  final _ghiChuCtrl = TextEditingController();

  @override
  void dispose() {
    _ghiChuCtrl.dispose();
    super.dispose();
  }

  Future<void> _chonNgay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() => _ngay = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _chonGio() async {
    final initial = widget.moCua ?? const TimeOfDay(hour: 11, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _gio = picked);
    }
  }

  bool _namTrongKhungGio(DateTime dt) {
    if (widget.moCua == null || widget.dongCua == null) return true; // không có dữ liệu thì bỏ qua
    final open = widget.moCua!;
    final close = widget.dongCua!;
    final afterOpen = dt.hour > open.hour ||
        (dt.hour == open.hour && dt.minute >= open.minute);
    final beforeClose = dt.hour < close.hour ||
        (dt.hour == close.hour && dt.minute <= close.minute);
    return afterOpen && beforeClose;
  }

  Future<void> _xacNhan() async {
    if (!_formKey.currentState!.validate()) return;

    // BẮT BUỘC: chặn người chưa đăng nhập
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yêu cầu đăng nhập trước khi đặt bàn.')),
      );
      return;
    }

    if (_ngay == null || _gio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa chọn ngày/giờ.')),
      );
      return;
    }

    final thoiDiem = DateTime(
      _ngay!.year,
      _ngay!.month,
      _ngay!.day,
      _gio!.hour,
      _gio!.minute,
    );

    if (!_namTrongKhungGio(thoiDiem)) {
      final open = widget.moCua?.format(context) ?? '--:--';
      final close = widget.dongCua?.format(context) ?? '--:--';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giờ đặt phải trong khoảng $open - $close')),
      );
      return;
    }

    // TODO: nếu đang lưu local SharedPreferences, gọi repo local của bạn tại đây
    // Ví dụ (giả lập):
    // await DonDatBanRepoLocal().them(
    //   uid: user.uid,
    //   restaurantId: widget.restaurantId,
    //   restaurantName: widget.restaurantName,
    //   thoiDiem: thoiDiem,
    //   soNguoi: _soNguoi,
    //   ghiChu: _ghiChuCtrl.text.trim(),
    // );

    if (!mounted) return;
    // Điều hướng sang trang thành công của bạn
    Navigator.pushReplacementNamed(
      context,
      '/dat_ban_thanh_cong',
      arguments: {
        'restaurantName': widget.restaurantName,
        'bookingTime': thoiDiem,
        'partySize': _soNguoi,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final btnEnable = _ngay != null && _gio != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Đặt bàn')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.restaurantName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _chonNgay,
                    child: Text(
                      _ngay == null
                          ? 'Chọn ngày'
                          : '${_ngay!.day}/${_ngay!.month}/${_ngay!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _chonGio,
                    child: Text(_gio == null ? 'Chọn giờ' : _gio!.format(context)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Số người:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _soNguoi,
                  items: [for (var i = 1; i <= 20; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                  onChanged: (v) => setState(() => _soNguoi = v ?? 2),
                ),
              ],
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _ghiChuCtrl,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: btnEnable ? _xacNhan : null, // Disable khi chưa chọn đủ
                child: const Text('Xác nhận đặt bàn'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

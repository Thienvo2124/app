import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mo_hinh/nha_hang.dart';
import 'dat_ban_page.dart';

class TaiKhoanPage extends StatefulWidget {
  final NhaHang? nhaHangMuonDat;
  const TaiKhoanPage({super.key, this.nhaHangMuonDat});

  @override
  State<TaiKhoanPage> createState() => _TaiKhoanPageState();
}

class _TaiKhoanPageState extends State<TaiKhoanPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailRegCtrl = TextEditingController();
  final _passRegCtrl = TextEditingController();
  bool _busyLogin = false;
  bool _busyReg = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailRegCtrl.dispose();
    _passRegCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLoginSuccess() async {
    final nh = widget.nhaHangMuonDat;
    if (!mounted) return;
    if (nh != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DatBanPage(
            restaurantId: nh.id,
            restaurantName: nh.ten, // đổi thành nh.name nếu model bạn dùng name
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập email và mật khẩu')),
      );
      return;
    }
    setState(() => _busyLogin = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      if (!mounted) return;
      await _onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Đăng nhập thất bại')),
      );
    } finally {
      if (mounted) setState(() => _busyLogin = false);
    }
  }

  Future<void> _register() async {
    final email = _emailRegCtrl.text.trim();
    final pass = _passRegCtrl.text;
    if (email.isEmpty || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email hợp lệ và mật khẩu ≥ 6 ký tự')),
      );
      return;
    }
    setState(() => _busyReg = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
      if (!mounted) return;
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo tài khoản thành công. Vui lòng đăng nhập.')),
      );
      _tab.animateTo(0);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Đăng ký thất bại')),
      );
    } finally {
      if (mounted) setState(() => _busyReg = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tài khoản')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Đang đăng nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Email: ${user.email ?? '(ẩn danh)'}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      setState(() {});
                    },
                    child: const Text('Đăng xuất'),
                  ),
                  const SizedBox(width: 12),
                  if (widget.nhaHangMuonDat != null)
                    OutlinedButton(
                      onPressed: () {
                        final nh = widget.nhaHangMuonDat!;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DatBanPage(
                              restaurantId: nh.id,
                              restaurantName: nh.ten,
                            ),
                          ),
                        );
                      },
                      child: const Text('Đặt bàn ngay'),
                    ),
                ],
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Đăng nhập'), Tab(text: 'Đăng ký')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // Đăng nhập
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busyLogin ? null : _login,
                    child: _busyLogin
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Đăng nhập'),
                  ),
                ),
              ],
            ),
          ),
          // Đăng ký
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _emailRegCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passRegCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu (≥ 6 ký tự)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _busyReg ? null : _register,
                    child: _busyReg
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Đăng ký'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

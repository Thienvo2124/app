import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthForm extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  AuthForm({required this.onLoginSuccess});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String _email = '';
  String _password = '';

  void _submitForm() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      setState(() => _isLoading = true);

      try {
        if (_isLogin) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Đăng nhập thành công')),
          );
          widget.onLoginSuccess();
        } else {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Đăng ký thành công. Vui lòng đăng nhập')),
          );
          setState(() {
            _isLogin = true;
            _emailController.clear();
            _passwordController.clear();
          });
        }
      } on FirebaseAuthException catch (e) {
        String message = switch (e.code) {
          'email-already-in-use' => 'Email đã được sử dụng. Vui lòng đăng nhập.',
          'invalid-email' => 'Email không hợp lệ.',
          'weak-password' => 'Mật khẩu quá yếu. Tối thiểu 6 ký tự.',
          'user-not-found' => 'Không tìm thấy tài khoản.',
          'wrong-password' => 'Sai mật khẩu.',
          _ => e.message ?? 'Lỗi không xác định',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $message')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _switchMode() {
    setState(() {
      _isLogin = !_isLogin;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập email hợp lệ để khôi phục mật khẩu')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📩 Email khôi phục mật khẩu đã được gửi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gửi email khôi phục')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _isLogin ? 'Đăng nhập' : 'Đăng ký',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _email = value ?? '',
                  validator: (value) =>
                  value != null && value.contains('@') ? null : 'Email không hợp lệ',
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onSaved: (value) => _password = value ?? '',
                  validator: (value) =>
                  value != null && value.length >= 6 ? null : 'Mật khẩu tối thiểu 6 ký tự',
                ),
                SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(Icons.check),
                  label: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
                TextButton(
                  onPressed: _switchMode,
                  child: Text(_isLogin
                      ? 'Chưa có tài khoản? Đăng ký'
                      : 'Đã có tài khoản? Đăng nhập'),
                ),
                if (_isLogin)
                  TextButton(
                    onPressed: _resetPassword,
                    child: Text('Quên mật khẩu?'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

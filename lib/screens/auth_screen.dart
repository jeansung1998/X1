import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text.trim();

    if (email.isEmpty || pw.isEmpty) {
      _showMessage('이메일과 비밀번호를 입력해주세요');
      return;
    }

    if (!_isLogin && pw != _pwConfirmCtrl.text.trim()) {
      _showMessage('비밀번호가 일치하지 않습니다');
      return;
    }

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email, password: pw);
      } else {
        await Supabase.instance.client.auth.signUp(
          email: email, password: pw);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('오류가 발생했습니다');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.josefinSans(fontSize: 12)),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FOLLOOK',
                  style: GoogleFonts.josefinSans(
                    fontSize: 28, fontWeight: FontWeight.w100,
                    letterSpacing: 12, color: Colors.white)),
                const SizedBox(height: 8),
                Text(_isLogin ? '로그인' : '회원가입',
                  style: GoogleFonts.josefinSans(
                    fontSize: 11, fontWeight: FontWeight.w300,
                    letterSpacing: 4, color: Colors.white70)),
                const SizedBox(height: 48),
                _buildInput(_emailCtrl, '이메일', false),
                const SizedBox(height: 16),
                _buildInput(_pwCtrl, '비밀번호', true),
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  _buildInput(_pwConfirmCtrl, '비밀번호 확인', true),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 16, width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1, color: Colors.black))
                        : Text(_isLogin ? '로그인' : '가입하기',
                            style: GoogleFonts.josefinSans(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              letterSpacing: 4)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _isLogin ? '계정이 없으신가요?  회원가입' : '이미 계정이 있으신가요?  로그인',
                        style: GoogleFonts.josefinSans(
                          fontSize: 11, fontWeight: FontWeight.w300,
                          letterSpacing: 2, color: Colors.white70)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, bool obscure) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: GoogleFonts.josefinSans(
        fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.josefinSans(
          fontSize: 13, color: Colors.white54,
          fontWeight: FontWeight.w300, letterSpacing: 2),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }
}
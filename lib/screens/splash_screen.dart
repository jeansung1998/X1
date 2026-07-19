import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _barExpand;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _barExpand = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: _GridPainter()),
          _buildCorners(),
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('RYKER',
                    style: GoogleFonts.josefinSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w100,
                      letterSpacing: 10,
                      color: Colors.white)),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _barExpand,
                    builder: (context, _) => Container(
                      width: 60 * _barExpand.value,
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('ANAMORPHIC WALLPAPERS',
                    style: GoogleFonts.josefinSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 5,
                      color: Colors.white.withValues(alpha: 0.4))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorners() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Stack(
        children: [
          Align(alignment: Alignment.topLeft, child: _corner(top: true, left: true)),
          Align(alignment: Alignment.topRight, child: _corner(top: true, left: false)),
          Align(alignment: Alignment.bottomLeft, child: _corner(top: false, left: true)),
          Align(alignment: Alignment.bottomRight, child: _corner(top: false, left: false)),
        ],
      ),
    );
  }

  Widget _corner({required bool top, required bool left}) {
    return SizedBox(
      width: 20, height: 20,
      child: CustomPaint(painter: _CornerPainter(top: top, left: left)),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.75, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width, size.height * 0.33), paint);
    canvas.drawLine(Offset(0, size.height * 0.66), Offset(size.width, size.height * 0.66), paint);
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.15);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.33), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.33), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.66), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.66), 2, dotPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CornerPainter extends CustomPainter {
  final bool top, left;
  _CornerPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
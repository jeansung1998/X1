import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallpaper.dart';
import '../services/supabase_service.dart';
import '../screens/settings_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Wallpaper> _purchases = [];
  bool _loading = true;
  bool _purchaseExpanded = false;
  int _wishlistCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'test_user';
      final results = await Future.wait([
        SupabaseService.getPurchasedWallpapers(userId),
        SupabaseService.getWishlistIds(userId),
      ]);
      setState(() {
        _purchases = results[0] as List<Wallpaper>;
        _wishlistCount = (results[1] as List<String>).length;
      });
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  int get _totalSpent => _purchases.length * 3900;

  bool get _isLight => ThemeNotifier().current.isLight;

  Color get _contentColor => ThemeNotifier().contentColor;

  Color get _subColor => _isLight
      ? const Color(0xFF333333)
      : Colors.white70;

  Color get _mutedColor => _isLight
      ? const Color(0xFF666666)
      : Colors.white54;

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeNotifier(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: ThemeNotifier().backgroundDecoration,
            child: SafeArea(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 1))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          _buildAvatar(),
                          _buildDivider(),
                          _buildStats(),
                          _buildDivider(),
                          _buildPurchaseSection(),
                          _buildDivider(),
                          _buildMenuSection(),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios, color: _contentColor, size: 18),
          ),
          const SizedBox(width: 16),
          Text('프로필',
            style: GoogleFonts.josefinSans(
              fontSize: 14, fontWeight: FontWeight.w600,
              letterSpacing: 4, color: _contentColor)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final user = Supabase.instance.client.auth.currentUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mutedColor.withValues(alpha: 0.1),
                border: Border.all(color: _mutedColor.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.person_outline, color: _mutedColor, size: 32),
            ),
          ),
          const SizedBox(height: 12),
          Text(user?.email?.split('@')[0].toUpperCase() ?? 'FOLLOOK USER',
            style: GoogleFonts.josefinSans(
              fontSize: 15, fontWeight: FontWeight.w600,
              letterSpacing: 3, color: _contentColor)),
          const SizedBox(height: 4),
          Text(user?.email ?? '',
            style: GoogleFonts.josefinSans(
              fontSize: 10, fontWeight: FontWeight.w300,
              letterSpacing: 1, color: _subColor)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: _isLight ? const Color(0xFFCCCCCC) : Colors.white24,
    );
  }

  Widget _buildStats() {
    final totalStr = '₩${_totalSpent.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          _statCard('${_purchases.length}', '구매'),
          const SizedBox(width: 2),
          _statCard('$_wishlistCount', '찜'),
          const SizedBox(width: 2),
          _statCard(totalStr, '총 결제'),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _isLight ? const Color(0xFFF0F0F0) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
              style: GoogleFonts.josefinSans(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: _contentColor, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(label,
              style: GoogleFonts.josefinSans(
                fontSize: 9, fontWeight: FontWeight.w300,
                color: _subColor, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _purchaseExpanded = !_purchaseExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('구매 내역',
                  style: GoogleFonts.josefinSans(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    letterSpacing: 3, color: _contentColor)),
                Row(
                  children: [
                    Text('${_purchases.length}건',
                      style: GoogleFonts.josefinSans(
                        fontSize: 11, fontWeight: FontWeight.w300,
                        color: _subColor, letterSpacing: 1)),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _purchaseExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.arrow_forward_ios, color: _subColor, size: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _purchaseExpanded
              ? Column(
                  children: _purchases.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text('구매 내역이 없습니다',
                              style: GoogleFonts.josefinSans(
                                fontSize: 11, color: _subColor, letterSpacing: 1)),
                          )
                        ]
                      : _purchases.map((item) => _purchaseItem(item)).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _purchaseItem(Wallpaper item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 40, height: 70,
              child: item.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(color: Colors.white.withValues(alpha: 0.05)),
                      errorWidget: (c, u, e) => Container(color: Colors.white.withValues(alpha: 0.05)),
                    )
                  : Container(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                  style: GoogleFonts.josefinSans(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: _contentColor, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(item.priceLabel,
                  style: GoogleFonts.josefinSans(
                    fontSize: 10, fontWeight: FontWeight.w300,
                    color: _subColor, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text('계정',
            style: GoogleFonts.josefinSans(
              fontSize: 10, fontWeight: FontWeight.w300,
              letterSpacing: 3, color: _subColor)),
        ),
        _menuRow('로그아웃', onTap: _signOut),
        _menuRow('문의하기', onTap: () {}),
        _menuRow('앱 버전  1.0.0', showArrow: false),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _menuRow(String label, {VoidCallback? onTap, bool showArrow = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
              style: GoogleFonts.josefinSans(
                fontSize: 12, fontWeight: FontWeight.w600,
                letterSpacing: 2, color: _contentColor)),
            if (showArrow)
              Icon(Icons.arrow_forward_ios, color: _subColor, size: 12),
          ],
        ),
      ),
    );
  }
}
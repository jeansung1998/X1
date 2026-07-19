import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallpaper.dart';
import '../services/purchase_service.dart';
import 'fullscreen_screen.dart';
import 'download_popup.dart';

class PurchaseScreen extends StatefulWidget {
  final Wallpaper item;
  const PurchaseScreen({super.key, required this.item});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _loading = false;
  bool _purchased = false;

  Future<void> _onPurchase() async {
    setState(() => _loading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'test_user';
      final available = await PurchaseService.isAvailable();
      if (!available) {
        _showMessage('결제 서비스를 사용할 수 없습니다');
        return;
      }
      final product = await PurchaseService.getProduct(widget.item.id);
      if (product == null) {
        await PurchaseService.savePurchase(
          userId: userId,
          wallpaperId: widget.item.id,
        );
        setState(() => _purchased = true);
        if (!mounted) return;
        // 다운로드 팝업 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => DownloadPopup(item: widget.item),
        );
        return;
      }
      await PurchaseService.buyProduct(product);
    } catch (e) {
      _showMessage('오류: $e');
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Text('결제',
                    style: GoogleFonts.josefinSans(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      letterSpacing: 4, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 110, height: 196,
                          child: widget.item.thumbnailUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.item.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: const Color(0xFF111111)),
                                  errorWidget: (context, url, error) =>
                                      Container(color: const Color(0xFF111111)),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111111),
                                    border: Border.all(color: Colors.white24))),
                        ),
                      ),
                      Positioned(
                        bottom: 8, right: 8,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullscreenScreen(item: widget.item)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white54),
                            ),
                            child: Text('전체 보기',
                              style: GoogleFonts.josefinSans(
                                fontSize: 9, fontWeight: FontWeight.w300,
                                color: Colors.white, letterSpacing: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(widget.item.title,
                          style: GoogleFonts.josefinSans(
                            fontSize: 16, fontWeight: FontWeight.w600,
                            color: Colors.white, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text('9:16  ·  4K  ·  10s',
                          style: GoogleFonts.josefinSans(
                            fontSize: 11, fontWeight: FontWeight.w300,
                            color: Colors.white70, letterSpacing: 1)),
                        const SizedBox(height: 20),
                        Text(widget.item.priceLabel,
                          style: GoogleFonts.josefinSans(
                            fontSize: 20, fontWeight: FontWeight.w600,
                            color: Colors.white, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text(_purchased ? '구매 완료' : '일회성 구매',
                          style: GoogleFonts.josefinSans(
                            fontSize: 10, fontWeight: FontWeight.w300,
                            color: _purchased ? Colors.greenAccent : Colors.white70,
                            letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _policyText('구매 후 환불은 불가합니다'),
                    _policyText('개인 사용 목적으로만 사용 가능하며 재배포 및 상업적 사용을 금합니다'),
                    _policyText('결제는 Apple App Store / Google Play 정책을 따릅니다'),
                    _policyText('본 콘텐츠의 저작권 및 소유권은 RYKER에 있으며 무단 복제 및 배포를 금합니다'),
                    _policyText('문의: support@ryker.kr'),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading || _purchased ? null : _onPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purchased ? Colors.white24 : Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 16, width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1, color: Colors.black))
                      : Text(_purchased ? '구매 완료' : '구매하기',
                          style: GoogleFonts.josefinSans(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            letterSpacing: 4)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _policyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('· $text',
        style: GoogleFonts.josefinSans(
          fontSize: 10, fontWeight: FontWeight.w300,
          color: Colors.white70, letterSpacing: 0.5, height: 1.6)),
    );
  }
}
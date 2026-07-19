import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallpaper.dart';
import '../services/supabase_service.dart';
import 'purchase_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Wallpaper> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'test_user';
      final items = await SupabaseService.getWishlistWallpapers(userId);
      setState(() => _items = items);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _loading ? _buildLoading() : _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          Text('보관함',
            style: GoogleFonts.josefinSans(
              fontSize: 14, fontWeight: FontWeight.w600,
              letterSpacing: 4, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 1),
    );
  }

  Widget _buildBody() {
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text('찜한 배경화면이 없습니다',
              style: GoogleFonts.josefinSans(
                fontSize: 12, color: Colors.white70, letterSpacing: 1)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 9 / 16,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) => _buildThumbnail(_items[index]),
    );
  }

  Widget _buildThumbnail(Wallpaper item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PurchaseScreen(item: item)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          item.thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl: item.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: const Color(0xFF111111)),
                  errorWidget: (context, url, error) =>
                      Container(color: const Color(0xFF111111)),
                )
              : Container(color: const Color(0xFF111111)),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD000000)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10, left: 12, right: 12,
            child: Text(item.title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.josefinSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
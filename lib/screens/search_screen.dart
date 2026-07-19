import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper.dart';
import '../services/supabase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'purchase_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<Wallpaper> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _results = []; _searched = false; });
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await SupabaseService.searchWallpapers(query);
      setState(() { _results = results; _searched = true; });
    } catch (e) {
      debugPrint('Search error: $e');
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
            _buildSearchBar(),
            const Divider(color: Colors.white24, height: 1),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: _search,
              style: GoogleFonts.josefinSans(
                fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
              decoration: InputDecoration(
                hintText: '제목, 카테고리, 태그 검색...',
                hintStyle: GoogleFonts.josefinSans(
                  fontSize: 13, color: Colors.white54,
                  fontWeight: FontWeight.w300, letterSpacing: 1),
                border: InputBorder.none,
                suffixIcon: _ctrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _ctrl.clear();
                          _search('');
                        },
                        child: const Icon(Icons.close, color: Colors.white54, size: 18),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 1),
      );
    }
    if (!_searched) {
      return Center(
        child: Text('검색어를 입력하세요',
          style: GoogleFonts.josefinSans(
            fontSize: 12, color: Colors.white54, letterSpacing: 2)),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text('검색 결과가 없습니다',
          style: GoogleFonts.josefinSans(
            fontSize: 12, color: Colors.white54, letterSpacing: 2)),
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
      itemCount: _results.length,
      itemBuilder: (context, index) => _buildThumbnail(_results[index]),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.josefinSans(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: Colors.white)),
                Text(item.priceLabel,
                  style: GoogleFonts.josefinSans(
                    fontSize: 11, fontWeight: FontWeight.w300,
                    color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
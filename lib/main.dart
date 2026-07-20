import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/wallpaper.dart';
import 'services/supabase_service.dart';
import 'screens/purchase_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mrekzpvquibgqtnnhkxd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yZWt6cHZxdWliZ3F0bm5oa3hkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzOTgwMjUsImV4cCI6MjA5OTk3NDAyNX0.3ZTCsaW3ZGn34ly8ds9DGjU_l-F9RU3U7r8ddRuPTio',
  );
  await ThemeNotifier().loadTheme();
  runApp(const X1App());
}

class X1App extends StatelessWidget {
  const X1App({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeNotifier(),
      builder: (context, _) {
        return MaterialApp(
          title: 'FOLLOOK',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.transparent,
            textTheme: GoogleFonts.josefinSansTextTheme().apply(
              bodyColor: ThemeNotifier().contentColor,
              displayColor: ThemeNotifier().contentColor,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['All', 'Nature', 'Space', 'City', 'Cyber', '3D'];
  List<Wallpaper> _items = [];
  bool _loading = true;
  Set<String> _wishlistIds = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'test_user';
      final category = _categories[_selectedCategory];
      final results = await Future.wait([
        SupabaseService.getWallpapers(category: category == 'All' ? null : category),
        SupabaseService.getWishlistIds(userId),
      ]);
      setState(() {
        _items = results[0] as List<Wallpaper>;
        _wishlistIds = Set<String>.from(results[1] as List<String>);
      });
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleWishlist(Wallpaper item) async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'test_user';
    final isLiked = _wishlistIds.contains(item.id);
    setState(() {
      if (isLiked) {
        _wishlistIds.remove(item.id);
      } else {
        _wishlistIds.add(item.id);
      }
    });
    try {
      if (isLiked) {
        await SupabaseService.removeWishlist(userId, item.id);
      } else {
        await SupabaseService.addWishlist(userId, item.id);
      }
    } catch (e) {
      setState(() {
        if (isLiked) {
          _wishlistIds.add(item.id);
        } else {
          _wishlistIds.remove(item.id);
        }
      });
    }
  }

  bool get _isLight => ThemeNotifier().current.isLight;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeNotifier(),
      builder: (context, _) {
        final contentColor = ThemeNotifier().contentColor;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: ThemeNotifier().backgroundDecoration,
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(contentColor),
                  _buildCategories(contentColor),
                  Expanded(child: _loading ? _buildLoading() : _buildGrid()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 1),
    );
  }

  Widget _buildHeader(Color contentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('FOLLOOK',
            style: GoogleFonts.josefinSans(
              fontSize: 16, fontWeight: FontWeight.w600,
              letterSpacing: 2, color: contentColor)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: contentColor, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                ),
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: contentColor, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LibraryScreen()),
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined, color: contentColor, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
              ),
              IconButton(
                icon: Icon(Icons.person_outline, color: contentColor, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(Color contentColor) {
    final inactiveColor = _isLight
        ? const Color(0xFF333333)
        : Colors.white70;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final selected = _selectedCategory == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = index);
              _loadAll();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_categories[index],
                    style: GoogleFonts.josefinSans(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: selected ? contentColor : inactiveColor)),
                  const SizedBox(height: 3),
                  Container(height: 1, width: 20,
                    color: selected ? contentColor : Colors.transparent),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    if (_items.isEmpty) {
      return Center(
        child: Text('No items', style: GoogleFonts.josefinSans(
          color: Colors.white54, fontSize: 12, letterSpacing: 2)),
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
    final isLiked = _wishlistIds.contains(item.id);
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
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
                GestureDetector(
                  onTap: () => _toggleWishlist(item),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.redAccent : Colors.white70,
                    size: 18,
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
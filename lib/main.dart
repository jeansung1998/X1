import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const X1App());
}

class X1App extends StatelessWidget {
  const X1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RYKER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF080808),
        textTheme: GoogleFonts.josefinSansTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
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

  final List<Map<String, String>> _items = [
    {'title': 'Deep Tide', 'price': '₩3,900', 'category': 'Nature'},
    {'title': 'Orion Drift', 'price': '₩3,900', 'category': 'Space'},
    {'title': 'Mist Pines', 'price': '₩3,900', 'category': 'Nature'},
    {'title': 'Midnight Spire', 'price': '₩3,900', 'category': 'City'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategories(),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'RYKER',
            style: GoogleFonts.josefinSans(
              fontSize: 16,
              fontWeight: FontWeight.w200,
              letterSpacing: 6,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white54, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white54, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white54, size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final selected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _categories[index],
                    style: GoogleFonts.josefinSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 2,
                      color: selected ? Colors.white : Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (selected)
                    Container(
                      height: 1,
                      width: 20,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 9 / 16,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _buildThumbnail(_items[index]);
      },
    );
  }

  Widget _buildThumbnail(Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseScreen(item: item),
          ),
        );
      },  
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xFF0A0A14)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: GoogleFonts.josefinSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      item['price']!,
                      style: GoogleFonts.josefinSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w200,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.favorite_border, color: Colors.white54, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PurchaseScreen extends StatelessWidget {
  final Map<String, String> item;
  const PurchaseScreen({super.key, required this.item});

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
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white54, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '결제',
                    style: GoogleFonts.josefinSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 178,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: GoogleFonts.josefinSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '9:16  ·  4K  ·  10s',
                            style: GoogleFonts.josefinSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w200,
                              color: Colors.white38,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['price']!,
                            style: GoogleFonts.josefinSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w200,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '일회성 구매',
                            style: GoogleFonts.josefinSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w200,
                              color: Colors.white30,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _policyText('구매 후 환불은 불가합니다'),
                  _policyText('개인 사용 목적으로만 사용 가능하며 재배포 및 상업적 사용을 금합니다'),
                  _policyText('결제는 Apple App Store / Google Play 정책을 따릅니다'),
                  _policyText('본 콘텐츠의 저작권 및 소유권은 RYKER에 있으며 무단 복제 및 배포를 금합니다'),
                  _policyText('문의: support@ryker.kr'),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '구매하기',
                    style: GoogleFonts.josefinSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
                  ),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '· $text',
        style: GoogleFonts.josefinSans(
          fontSize: 10,
          fontWeight: FontWeight.w200,
          color: Colors.white24,
          letterSpacing: 0.5,
          height: 1.6,
        ),
      ),
    );
  }
}
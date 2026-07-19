import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  final String name;
  final Color bgColor;

  const AppTheme({required this.name, required this.bgColor});

  bool get isLight =>
      bgColor == const Color(0xFFFFFFFF) || bgColor == const Color(0xFFFAFAFA);

  Color get contentColor => isLight ? const Color(0xFF080808) : Colors.white;
}

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  int _themeIndex = 0;
  int get themeIndex => _themeIndex;

  static const List<AppTheme> themes = [
    AppTheme(name: 'Pure Black',  bgColor: Color(0xFF080808)),
    AppTheme(name: 'Soft Black',  bgColor: Color(0xFF0D0D0D)),
    AppTheme(name: 'Slate',       bgColor: Color(0xFF0E0E12)),
    AppTheme(name: 'Deep Ocean',  bgColor: Color(0xFF0D1429)),
    AppTheme(name: 'Twilight',    bgColor: Color(0xFF0F0A1A)),
    AppTheme(name: 'Dark Teal',   bgColor: Color(0xFF0A1210)),
    AppTheme(name: 'Ember',       bgColor: Color(0xFF140A08)),
    AppTheme(name: 'White',       bgColor: Color(0xFFFFFFFF)),
    AppTheme(name: 'Snow',        bgColor: Color(0xFFFAFAFA)),
  ];

  AppTheme get current => themes[_themeIndex];
  Color get contentColor => current.contentColor;
  Color get bgColor => current.bgColor;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeIndex = prefs.getInt('theme_index') ?? 0;
    notifyListeners();
  }

  Future<void> setTheme(int index) async {
    _themeIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', index);
    notifyListeners();
  }

  BoxDecoration get backgroundDecoration {
    return BoxDecoration(color: current.bgColor);
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeNotifier _themeNotifier = ThemeNotifier();

  bool get _isLight => _themeNotifier.current.isLight;

  Color get _contentColor => _themeNotifier.contentColor;

  Color get _subColor => _isLight
      ? const Color(0xFF333333)
      : Colors.white70;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeNotifier,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: _themeNotifier.backgroundDecoration,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back_ios, color: _contentColor, size: 18),
                        ),
                        const SizedBox(width: 16),
                        Text('설정',
                          style: GoogleFonts.josefinSans(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            letterSpacing: 4, color: _contentColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('THEME',
                      style: GoogleFonts.josefinSans(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 4, color: _subColor)),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 24,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: ThemeNotifier.themes.length,
                        itemBuilder: (context, index) {
                          final theme = ThemeNotifier.themes[index];
                          final isSelected = _themeNotifier.themeIndex == index;
                          return GestureDetector(
                            onTap: () => _themeNotifier.setTheme(index),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    color: theme.bgColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? _contentColor : _contentColor.withValues(alpha: 0.3),
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(theme.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.josefinSans(
                                    fontSize: 10, fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: _subColor)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
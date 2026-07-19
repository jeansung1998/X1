import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallpaper.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  static Future<List<Wallpaper>> getWallpapers({String? category}) async {
    final response = await _client
        .from('wallpapers')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final list = (response as List)
        .map((json) => Wallpaper.fromJson(json))
        .toList();

    if (category != null && category != 'All') {
      return list.where((w) => w.category == category).toList();
    }
    return list;
  }

  static Future<List<Wallpaper>> searchWallpapers(String query) async {
    if (query.isEmpty) return [];
    final q = query.toLowerCase().trim();

    final response = await _client
        .from('wallpapers')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final list = (response as List)
        .map((json) => Wallpaper.fromJson(json))
        .toList();

    return list.where((w) {
      final title = w.title.toLowerCase();
      final category = w.category.toLowerCase();
      return title.contains(q) ||
          category.contains(q) ||
          w.tags.any((t) => t.toLowerCase().trim().contains(q));
    }).toList();
  }

  static Future<List<Wallpaper>> getPurchasedWallpapers(String userId) async {
    final purchases = await _client
        .from('purchases')
        .select('wallpaper_id')
        .eq('user_id', userId);

    final ids = (purchases as List)
        .map((e) => e['wallpaper_id'] as String)
        .toList();

    if (ids.isEmpty) return [];

    final response = await _client
        .from('wallpapers')
        .select()
        .inFilter('id', ids);

    return (response as List)
        .map((json) => Wallpaper.fromJson(json))
        .toList();
  }

  static Future<List<String>> getWishlistIds(String userId) async {
    final response = await _client
        .from('wishlist')
        .select('wallpaper_id')
        .eq('user_id', userId);

    return (response as List)
        .map((e) => e['wallpaper_id'] as String)
        .toList();
  }

  static Future<List<Wallpaper>> getWishlistWallpapers(String userId) async {
    final ids = await getWishlistIds(userId);
    if (ids.isEmpty) return [];

    final response = await _client
        .from('wallpapers')
        .select()
        .inFilter('id', ids);

    return (response as List)
        .map((json) => Wallpaper.fromJson(json))
        .toList();
  }

  static Future<void> addWishlist(String userId, String wallpaperId) async {
    await _client.from('wishlist').insert({
      'user_id': userId,
      'wallpaper_id': wallpaperId,
    });
  }

  static Future<void> removeWishlist(String userId, String wallpaperId) async {
    await _client
        .from('wishlist')
        .delete()
        .eq('user_id', userId)
        .eq('wallpaper_id', wallpaperId);
  }
}
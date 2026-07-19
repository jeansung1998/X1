import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static final _client = Supabase.instance.client;

  // 결제 가능 여부 확인
  static Future<bool> isAvailable() async {
    return await _iap.isAvailable();
  }

  // 상품 정보 조회
  static Future<ProductDetails?> getProduct(String productId) async {
    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) return null;
    return response.productDetails.first;
  }

  // 구매 시작
  static Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // 구매 내역 Supabase에 저장
  static Future<void> savePurchase({
    required String userId,
    required String wallpaperId,
  }) async {
    await _client.from('purchases').insert({
      'user_id': userId,
      'wallpaper_id': wallpaperId,
    });
  }

  // 내 구매 목록 조회
  static Future<List<String>> getMyPurchases(String userId) async {
    final response = await _client
        .from('purchases')
        .select('wallpaper_id')
        .eq('user_id', userId);
    return (response as List)
        .map((e) => e['wallpaper_id'] as String)
        .toList();
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ReviewService {
  static Future<Map<String, String>> _headers() async {
    final token = await ApiService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // POST /api/review
  Future<Map<String, dynamic>> submitReview({
    required String produkId,
    required int rating,
    String? komentar,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiService.baseUrl}/review'),
      headers: await _headers(),
      body: jsonEncode({
        'produk_id': produkId,
        'rating': rating,
        'komentar': komentar,
      }),
    );
    return jsonDecode(res.body);
  }

  // PATCH /api/review/{produk_id}
  Future<Map<String, dynamic>> updateReview({
    required String produkId,
    required int rating,
    String? komentar,
  }) async {
    final res = await http.patch(
      Uri.parse('${ApiService.baseUrl}/review/$produkId'),
      headers: await _headers(),
      body: jsonEncode({'rating': rating, 'komentar': komentar}),
    );
    return jsonDecode(res.body);
  }

  // GET /api/review/status/{produk_id}
  Future<Map<String, dynamic>> getReviewStatus(String produkId) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/review/status/$produkId'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // GET /api/produk/{produk_id}/reviews
  Future<Map<String, dynamic>> getReviewsByProduk(String produkId) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/produk/$produkId/reviews'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // GET /api/my-reviews
  Future<List<dynamic>> getMyReviews() async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/my-reviews'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

/// S256 price from the explorer's /api/price, which reads it from
/// LiveCoinWatch (the API key stays on the server).
///
/// While no market trades S256 the explorer sends the last traded price and
/// [lastTraded], the time of that price. Then it is not a live price.
class PriceData {
  final double price;

  /// When [price] was last traded, or null when it is a live price.
  final DateTime? lastTraded;

  const PriceData({required this.price, this.lastTraded});

  bool get isLastTrade => lastTraded != null;

  /// Null when the answer has no usable price (missing, zero, negative or
  /// not a number): LiveCoinWatch returns nulls for a coin it has no rate for.
  static PriceData? fromJson(Map<String, dynamic> json) {
    double? number(dynamic v) =>
        v is num && v.isFinite && v > 0 ? v.toDouble() : null;
    final price = number(json['price']);
    if (price == null) return null;
    final ms = number(json['lastTraded']);
    return PriceData(
      price: price,
      lastTraded: ms == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true),
    );
  }

  /// "18 Oct 2026" (UTC).
  static String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = date.toUtc();
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class PriceService {
  /// The current price, or null when there is none or the request failed.
  Future<PriceData?> getS256Price() async {
    try {
      final response = await http
          .get(Uri.parse('${Config.explorerUrl}${Config.priceEndpoint}'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        print('Error fetching price: ${response.statusCode}');
        return null;
      }
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> ? PriceData.fromJson(data) : null;
    } catch (e) {
      print('Exception fetching price: $e');
      return null;
    }
  }
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:s256_web_wallet/services/price_service.dart';

// The explorer's /api/price returns nulls while LiveCoinWatch has no rate for
// S256, and the last traded price with its time while no market trades it.
void main() {
  group('PriceData.fromJson', () {
    test('reads a live price', () {
      final p = PriceData.fromJson({'name': 'SHA256COIN', 'price': 0.0123, 'volume': 1500, 'cap': 2500000.5});
      expect(p!.price, 0.0123);
      expect(p.isLastTrade, isFalse);
      expect(p.change24h, isNull);
    });

    test('reads the 24h change, never for a last traded price', () {
      expect(PriceData.fromJson({'price': 0.05, 'change24h': -2.35})!.change24h, -2.35);
      expect(PriceData.fromJson({'price': 0.05, 'change24h': null})!.change24h, isNull);
      expect(PriceData.fromJson({'price': 0.05, 'change24h': '5'})!.change24h, isNull);
      expect(PriceData.fromJson({'price': 0.05, 'change24h': 3.1, 'lastTraded': 1792295700000})!.change24h, isNull);
    });

    test('a last traded price carries its date', () {
      final p = PriceData.fromJson({'price': 0.0034969, 'volume': null, 'lastTraded': 1792295700000})!;
      expect(p.isLastTrade, isTrue);
      expect(p.lastTraded, DateTime.utc(2026, 10, 18, 3, 55));
      expect(PriceData.formatDate(p.lastTraded!), '18 Oct 2026');
    });

    test('nulls, zero, negative and non-numbers are no price', () {
      expect(PriceData.fromJson({'price': null, 'volume': null, 'cap': null}), isNull);
      expect(PriceData.fromJson({'price': 0}), isNull);
      expect(PriceData.fromJson({'price': -1}), isNull);
      expect(PriceData.fromJson({'price': '1.5'}), isNull);
      expect(PriceData.fromJson({'price': double.nan}), isNull);
      expect(PriceData.fromJson({'price': null, 'lastTraded': 1792295700000}), isNull);
    });
  });

  group('PriceService.getS256Price', () {
    Future<PriceData?> answer(http.Response Function() reply) => http.runWithClient(
        () => PriceService().getS256Price(), () => MockClient((req) async {
              expect(req.method, 'GET');
              expect(req.url.toString(), 'https://explorer.sha256coin.eu/api/price');
              return reply();
            }));

    test('asks the explorer and reads its answer', () async {
      final p = await answer(() => http.Response(jsonEncode({'price': 0.05, 'lastTraded': null}), 200));
      expect(p!.price, 0.05);
    });

    test('a failed request or garbage answer is null', () async {
      expect(await answer(() => http.Response('boom', 500)), isNull);
      expect(await answer(() => http.Response('not json', 200)), isNull);
      expect(await answer(() => http.Response(jsonEncode([1, 2]), 200)), isNull);
    });
  });
}

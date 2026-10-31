import 'package:flutter_test/flutter_test.dart';

import 'package:s256_web_wallet/models/transaction_model.dart';
import 'package:s256_web_wallet/widgets/balance_chart.dart';

TransactionModel tx(String id, double amount, TxDirection dir, int day, {int confirmations = 5}) =>
    TransactionModel(
      txid: id.padRight(64, '0'),
      amount: amount,
      direction: dir,
      confirmations: confirmations,
      timestamp: DateTime.utc(2026, 10, day),
    );

void main() {
  group('BalanceHistory', () {
    test('walks back from the confirmed balance, newest first', () {
      // Oldest to newest: +100, +50, -30 (net, fee included) -> 120.
      final newestFirst = [
        tx('c', 30, TxDirection.sent, 3),
        tx('b', 50, TxDirection.received, 2),
        tx('a', 100, TxDirection.received, 1),
      ];
      final h = BalanceHistory.fromTransactions(newestFirst, confirmedBalance: 120);
      expect(h.start, 0);
      expect(h.points.map((p) => p.balance), [100, 150, 120]);
      expect(h.points.map((p) => p.change), [100, 50, -30]);
      expect(h.points.first.time, DateTime.utc(2026, 10, 1));
      expect(h.pendingTotal, isNull);
    });

    test('with only the newest transactions loaded it starts at the earlier balance', () {
      final newestFirst = [
        tx('b', 25, TxDirection.sent, 9),
        tx('a', 10, TxDirection.received, 8),
      ];
      final h = BalanceHistory.fromTransactions(newestFirst, confirmedBalance: 1000);
      expect(h.start, 1015);
      expect(h.points.map((p) => p.balance), [1025, 1000]);
    });

    test('pending transactions are left out and shown as the pending total', () {
      final newestFirst = [
        tx('p', 5, TxDirection.received, 10, confirmations: 0),
        tx('a', 10, TxDirection.received, 8),
      ];
      final h = BalanceHistory.fromTransactions(newestFirst, confirmedBalance: 10, totalBalance: 15);
      expect(h.points, hasLength(1));
      expect(h.start, 0);
      expect(h.pendingTotal, 15);
    });

    test('no rounding drift over many transactions', () {
      final newestFirst = [for (var i = 0; i < 100; i++) tx('t$i', 0.1, TxDirection.received, 1 + i % 28)];
      final h = BalanceHistory.fromTransactions(newestFirst, confirmedBalance: 10);
      expect(h.start, 0);
    });

    test('a balance never goes below zero', () {
      final h = BalanceHistory.fromTransactions([tx('a', 50, TxDirection.received, 1)], confirmedBalance: 20);
      expect(h.start, 0);
    });
  });

  group('niceRange', () {
    test('round steps around the data', () {
      final r = niceRange(29027.8, 29152.8);
      expect(r.step, 50);
      expect(r.min, 29000);
      expect(r.max, 29200);
    });

    test('a flat series still gets a range', () {
      final r = niceRange(500, 500);
      expect(r.max, greaterThan(r.min));
      expect(r.min, lessThanOrEqualTo(500));
      expect(r.max, greaterThanOrEqualTo(500));
    });

    test('compact labels follow the step', () {
      expect(compactAmount(29050, 50), '29.05K');
      expect(compactAmount(29000, 1000), '29K');
      expect(compactAmount(1250000, 50000), '1.25M');
      expect(compactAmount(350, 50), '350');
      expect(compactAmount(0.5, 0.1), '0.5');
    });
  });
}

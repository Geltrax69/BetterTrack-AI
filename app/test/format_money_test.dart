// Pure-function tests for the Indian-grouping currency formatter.
// Guards the regression where 8150 rendered as "81,50" instead of "8,150".
import 'package:bettertrack/widgets/cards.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups rupees the Indian way (last 3, then 2s)', () {
    expect(formatMoney(0), '₹0');
    expect(formatMoney(180), '₹180');
    expect(formatMoney(8150), '₹8,150');
    expect(formatMoney(12450), '₹12,450');
    expect(formatMoney(1234567), '₹12,34,567');
  });

  test('uses the given symbol and absolute value', () {
    expect(formatMoney(-4300), '₹4,300');
    expect(formatMoney(2500, symbol: r'$'), r'$2,500');
  });
}

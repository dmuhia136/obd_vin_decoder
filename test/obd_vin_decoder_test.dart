import 'package:flutter_test/flutter_test.dart';
import 'package:obd_vin_decoder/obd_vin_decoder.dart'; // Make sure this matches your package name!

void main() {
  group('VIN Decoder Offline Tests', () {
    test('Validates a correct VIN', () {
      final decoder = VIN(number: '1HGCM82633A004XXX');
      expect(decoder.isValid(), isTrue);
    });

    test('Extracts correct offline manufacturer', () {
      final decoder = VIN(number: '1HGCM82633A004XXX');
      expect(decoder.getManufacturer(), 'Honda');
    });

    test('Extracts correct year', () {
      final decoder = VIN(number: '1HGCM82633A004XXX');
      expect(decoder.getYear(), 2003);
    });
  });
}

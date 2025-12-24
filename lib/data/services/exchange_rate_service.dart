import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRateService {
  ExchangeRateService();

  Future<double> getUsdToBrlRate() async {
    try {
      final response = await http
          .get(Uri.parse('https://economia.awesomeapi.com.br/json/last/USD-BRL'))
          .timeout(const Duration(seconds: 8), onTimeout: () => throw Exception('Exchange rate request timeout'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rate = double.parse(data['USDBRL']['bid'].toString());
        print('✓ Exchange rate fetched successfully: R\$ $rate');
        return rate;
      } else {
        throw Exception('Failed to fetch exchange rate: ${response.statusCode}');
      }
    } catch (e) {
      // If the request fails, log and return a fallback rate
      print('✗ Error fetching exchange rate: $e');
      print('⚠ Using fallback rate: R\$ 5.5902');
      // Current fallback rate (updated 2025-12-23)
      return 5.5902;
    }
  }
}

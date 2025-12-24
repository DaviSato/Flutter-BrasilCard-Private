import 'package:brasil_crypto/domain/models/crypto_details.dart';
import 'package:brasil_crypto/domain/models/cryptocurrency.dart';

abstract class CoingeckoRepository {
  Future<List<Cryptocurrency>> searchCryptocurrencies(String query);

  Future<List<Cryptocurrency>> getMarketData({
    List<String> ids = const [],
    String order = 'market_cap_desc',
    int perPage = 50,
    int page = 1,
  });

  Future<CryptoDetails> getCryptocurrencyDetails(String cryptoId);

  Future<List<Cryptocurrency>> getTopCryptocurrencies({int limit = 50});
}

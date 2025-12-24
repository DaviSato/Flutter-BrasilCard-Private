import 'dart:convert';

import 'package:brasil_crypto/core/adapters/http/client_adapter.dart';
import 'package:brasil_crypto/domain/exceptions/repository_exception.dart';
import 'package:brasil_crypto/domain/models/crypto_details.dart';
import 'package:brasil_crypto/domain/models/cryptocurrency.dart';
import 'package:brasil_crypto/domain/repositories/coingecko_repository.dart';

class CoingeckoApiRepository implements CoingeckoRepository {
  final ClientAdapter http;

  CoingeckoApiRepository(this.http);

  @override
  Future<List<Cryptocurrency>> searchCryptocurrencies(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final encodedQuery = Uri.encodeQueryComponent(query.trim());
      final endpoint = '/search?query=$encodedQuery';

      final response = await http.get(endpoint);

      if (response.statusCode != 200) {
        throw RepositoryException.fromStatusCode(response.statusCode, response.body);
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final coins = jsonData['coins'] as List<dynamic>? ?? [];

      return coins
          .map((coin) {
            try {
              return Cryptocurrency.fromJson(coin as Map<String, dynamic>);
            } catch (e) {
              return null;
            }
          })
          .whereType<Cryptocurrency>()
          .toList();
    } on RepositoryException {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        message: 'Failed to search cryptocurrencies: $e',
        code: 'SEARCH_ERROR',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Cryptocurrency>> getMarketData({
    List<String> ids = const [],
    String order = 'market_cap_desc',
    int perPage = 50,
    int page = 1,
  }) async {
    try {
      if (perPage > 250) {
        throw RepositoryException(message: 'Maximum items per page is 250', code: 'INVALID_PARAMS');
      }

      String endpoint =
          '/coins/markets?vs_currency=usd&order=$order'
          '&per_page=$perPage&page=$page&sparkline=false';

      if (ids.isNotEmpty) {
        final idList = ids.join(',');
        endpoint =
            '/coins/markets?vs_currency=usd&ids=$idList'
            '&order=$order&per_page=$perPage&page=$page&sparkline=false';
      }

      final response = await http.get(endpoint);

      if (response.statusCode != 200) {
        throw RepositoryException.fromStatusCode(response.statusCode, response.body);
      }

      final List<dynamic> jsonData = jsonDecode(response.body) as List<dynamic>;

      return jsonData
          .map((coin) {
            try {
              return Cryptocurrency.fromJson(coin as Map<String, dynamic>);
            } catch (e) {
              return null;
            }
          })
          .whereType<Cryptocurrency>()
          .toList();
    } on RepositoryException {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        message: 'Failed to fetch market data: $e',
        code: 'MARKET_DATA_ERROR',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<CryptoDetails> getCryptocurrencyDetails(String cryptoId) async {
    if (cryptoId.trim().isEmpty) {
      throw RepositoryException(message: 'Cryptocurrency ID cannot be empty', code: 'INVALID_ID');
    }

    try {
      final endpoint =
          '/coins/${cryptoId.toLowerCase()}'
          '?localization=false&tickers=false&market_data=true'
          '&community_data=false&developer_data=false';

      final response = await http.get(endpoint);

      if (response.statusCode == 404) {
        throw RepositoryException(message: 'Cryptocurrency not found: $cryptoId', code: 'NOT_FOUND');
      }

      if (response.statusCode != 200) {
        throw RepositoryException.fromStatusCode(response.statusCode, response.body);
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return CryptoDetails.fromJson(jsonData);
    } on RepositoryException {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        message: 'Failed to fetch cryptocurrency details: $e',
        code: 'DETAILS_ERROR',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Cryptocurrency>> getTopCryptocurrencies({int limit = 50}) async {
    try {
      final validLimit = limit > 250 ? 250 : limit;

      final endpoint =
          '/coins/markets?vs_currency=usd'
          '&order=market_cap_desc&per_page=$validLimit&page=1&sparkline=false';

      final response = await http.get(endpoint);

      if (response.statusCode != 200) {
        throw RepositoryException.fromStatusCode(response.statusCode, response.body);
      }

      final List<dynamic> jsonData = jsonDecode(response.body) as List<dynamic>;

      return jsonData
          .map((coin) {
            try {
              return Cryptocurrency.fromJson(coin as Map<String, dynamic>);
            } catch (e) {
              return null;
            }
          })
          .whereType<Cryptocurrency>()
          .toList();
    } on RepositoryException {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        message: 'Failed to fetch top cryptocurrencies: $e',
        code: 'TOP_CRYPTO_ERROR',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }
}

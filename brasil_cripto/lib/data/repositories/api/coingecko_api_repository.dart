import 'package:brasil_cripto/core/adapters/http/client_adapter.dart';
import 'package:brasil_cripto/domain/repositories/coingecko_repository.dart';

class CoingeckoApiRepository implements CoingeckoRepository {
  final ClientAdapter http;

  CoingeckoApiRepository(this.http);
}

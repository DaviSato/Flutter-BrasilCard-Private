import 'package:brasil_cripto/core/adapters/http/client_adapter.dart';
import 'package:brasil_cripto/core/adapters/http/http_client.dart';
import 'package:brasil_cripto/data/repositories/api/coingecko_api_repository.dart';
import 'package:brasil_cripto/domain/repositories/coingecko_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

abstract class DependencyInjector {
  static void load() {
    // Adapters
    getIt.registerLazySingleton<ClientAdapter>(() => HttpClient());

    /// Repositories
    getIt.registerLazySingleton<CoingeckoRepository>(() => CoingeckoApiRepository(getIt<ClientAdapter>()));
  }

  static T get<T extends Object>() {
    return getIt.get<T>();
  }
}

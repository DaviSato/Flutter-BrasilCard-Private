import 'package:brasil_crypto/core/adapters/http/client_adapter.dart';
import 'package:brasil_crypto/core/adapters/http/http_client.dart';
import 'package:brasil_crypto/data/repositories/api/coingecko_api_repository.dart';
import 'package:brasil_crypto/data/repositories/favorites_local_repository.dart';
import 'package:brasil_crypto/data/services/exchange_rate_service.dart';
import 'package:brasil_crypto/domain/repositories/coingecko_repository.dart';
import 'package:brasil_crypto/ui/cubit/crypto_details_cubit.dart';
import 'package:brasil_crypto/ui/cubit/exchange_rate_cubit.dart';
import 'package:brasil_crypto/ui/cubit/favorites_cubit.dart';
import 'package:brasil_crypto/ui/cubit/search_crypto_page_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

abstract class DependencyInjector {
  static Future<void> load() async {
    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Adapters - Register first (no dependencies)
    getIt.registerSingleton<ClientAdapter>(HttpClient());

    // Services
    getIt.registerSingleton<ExchangeRateService>(ExchangeRateService());

    // Repositories - Register after adapters
    getIt.registerSingleton<CoingeckoRepository>(CoingeckoApiRepository(getIt<ClientAdapter>()));

    getIt.registerSingleton<FavoritesLocalRepository>(FavoritesLocalRepository(prefs));

    // CUBITs - Register after repositories
    getIt.registerSingleton<SearchCryptoPageCubit>(SearchCryptoPageCubit(getIt<CoingeckoRepository>()));

    getIt.registerSingleton<CryptoDetailsCubit>(CryptoDetailsCubit(getIt<CoingeckoRepository>()));

    getIt.registerSingleton<FavoritesCubit>(FavoritesCubit(getIt<FavoritesLocalRepository>()));

    getIt.registerSingleton<ExchangeRateCubit>(ExchangeRateCubit(getIt<ExchangeRateService>()));
  }

  static T get<T extends Object>() {
    return getIt.get<T>();
  }
}

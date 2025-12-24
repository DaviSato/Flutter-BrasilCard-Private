import 'package:bloc/bloc.dart';
import 'package:brasil_crypto/core/dependency_injection/dependency_injector.dart';
import 'package:brasil_crypto/data/repositories/favorites_local_repository.dart';
import 'package:brasil_crypto/domain/exceptions/repository_exception.dart';
import 'package:brasil_crypto/domain/models/cryptocurrency.dart';
import 'package:brasil_crypto/domain/repositories/coingecko_repository.dart';

class SearchCryptoPageCubit extends Cubit<SearchCryptoPageState> {
  final CoingeckoRepository repository;

  SearchCryptoPageCubit(this.repository) : super(InitialState());

  void onInit() {
    if (!isClosed) emit(InitialState());
  }

  Future<void> searchCryptocurrencies(String query) async {
    if (query.trim().isEmpty) {
      emit(const SearchSuccessState(cryptoList: []));
      return;
    }

    try {
      emit(SearchLoadingState());

      final results = await repository.searchCryptocurrencies(query);

      if (results.isEmpty) {
        emit(const SearchEmptyState());
      } else {
        emit(SearchSuccessState(cryptoList: results));
      }
    } on RepositoryException catch (e) {
      emit(SearchErrorState(error: e.message));
    } catch (e) {
      emit(SearchErrorState(error: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> loadTopCryptocurrencies({int limit = 50}) async {
    final FavoritesLocalRepository favoritesLocalRepository = DependencyInjector.get<FavoritesLocalRepository>();

    try {
      emit(SearchLoadingState());

      final results = await repository.getTopCryptocurrencies(limit: limit);
      final favorites = await favoritesLocalRepository.getFavorites();

      if (results.isNotEmpty && favorites.isNotEmpty) {
        final favoriteIds = favorites.map((f) => f.id).toSet();

        for (Cryptocurrency cry in results) {
          if (favoriteIds.contains(cry.id)) {
            await favoritesLocalRepository.updateFavorite(cry);
          }
        }
      }

      if (results.isEmpty) {
        emit(const SearchEmptyState());
      } else {
        emit(SearchSuccessState(cryptoList: results));
      }
    } on RepositoryException catch (e) {
      emit(SearchErrorState(error: e.message));
    } catch (e) {
      emit(SearchErrorState(error: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> fetchMarketData({
    List<String> ids = const [],
    String order = 'market_cap_desc',
    int perPage = 50,
  }) async {
    try {
      emit(SearchLoadingState());

      final results = await repository.getMarketData(ids: ids, order: order, perPage: perPage);

      if (results.isEmpty) {
        emit(const SearchEmptyState());
      } else {
        emit(SearchSuccessState(cryptoList: results));
      }
    } on RepositoryException catch (e) {
      emit(SearchErrorState(error: e.message));
    } catch (e) {
      emit(SearchErrorState(error: 'An unexpected error occurred: $e'));
    }
  }
}

sealed class SearchCryptoPageState {
  const SearchCryptoPageState();
}

class InitialState extends SearchCryptoPageState {
  const InitialState();
}

class SearchLoadingState extends SearchCryptoPageState {
  const SearchLoadingState();
}

class SearchSuccessState extends SearchCryptoPageState {
  final List<Cryptocurrency> cryptoList;

  const SearchSuccessState({required this.cryptoList});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchSuccessState && runtimeType == other.runtimeType && cryptoList == other.cryptoList;

  @override
  int get hashCode => cryptoList.hashCode;
}

class SearchEmptyState extends SearchCryptoPageState {
  const SearchEmptyState();
}

class SearchErrorState extends SearchCryptoPageState {
  final String error;

  const SearchErrorState({required this.error});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SearchErrorState && runtimeType == other.runtimeType && error == other.error;

  @override
  int get hashCode => error.hashCode;
}

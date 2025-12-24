import 'package:bloc/bloc.dart';
import 'package:brasil_crypto/data/repositories/favorites_local_repository.dart';
import 'package:brasil_crypto/domain/models/cryptocurrency.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesLocalRepository repository;

  FavoritesCubit(this.repository) : super(FavoritesInitialState());

  Future<void> loadFavorites() async {
    try {
      emit(FavoritesLoadingState());
      final favorites = await repository.getFavorites();

      if (favorites.isEmpty) {
        emit(const FavoritesEmptyState());
      } else {
        emit(FavoritesLoadedState(favorites: favorites));
      }
    } catch (e) {
      emit(FavoritesErrorState(error: 'Erro ao carregar favoritos: $e'));
    }
  }

  Future<void> addFavorite(Cryptocurrency crypto) async {
    try {
      final success = await repository.addFavorite(crypto);

      if (success) {
        await loadFavorites();
      } else {
        emit(FavoritesErrorState(error: 'Cryptomoeda já está nos favoritos'));
      }
    } catch (e) {
      emit(FavoritesErrorState(error: 'Erro ao adicionar aos favoritos: $e'));
    }
  }

  Future<void> removeFavorite(String cryptoId) async {
    try {
      final success = await repository.removeFavorite(cryptoId);

      if (success) {
        await loadFavorites();
      } else {
        emit(FavoritesErrorState(error: 'Cryptomoeda não encontrada nos favoritos'));
      }
    } catch (e) {
      emit(FavoritesErrorState(error: 'Erro ao remover dos favoritos: $e'));
    }
  }

  Future<bool> isFavorite(String cryptoId) async {
    try {
      return await repository.isFavorite(cryptoId);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      final success = await repository.clearAll();

      if (success) {
        emit(const FavoritesEmptyState());
      } else {
        emit(FavoritesErrorState(error: 'Erro ao limpar favoritos'));
      }
    } catch (e) {
      emit(FavoritesErrorState(error: 'Erro ao limpar favoritos: $e'));
    }
  }

  Future<int> getFavoritesCount() async {
    try {
      return await repository.getFavoritesCount();
    } catch (e) {
      return 0;
    }
  }
}

sealed class FavoritesState {
  const FavoritesState();
}

class FavoritesInitialState extends FavoritesState {
  const FavoritesInitialState();
}

class FavoritesLoadingState extends FavoritesState {
  const FavoritesLoadingState();
}

class FavoritesLoadedState extends FavoritesState {
  final List<Cryptocurrency> favorites;

  const FavoritesLoadedState({required this.favorites});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritesLoadedState && runtimeType == other.runtimeType && favorites == other.favorites;

  @override
  int get hashCode => favorites.hashCode;
}

class FavoritesEmptyState extends FavoritesState {
  const FavoritesEmptyState();
}

class FavoritesErrorState extends FavoritesState {
  final String error;

  const FavoritesErrorState({required this.error});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritesErrorState && runtimeType == other.runtimeType && error == other.error;

  @override
  int get hashCode => error.hashCode;
}

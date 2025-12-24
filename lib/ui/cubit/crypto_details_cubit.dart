import 'package:bloc/bloc.dart';
import 'package:brasil_crypto/domain/exceptions/repository_exception.dart';
import 'package:brasil_crypto/domain/models/crypto_details.dart';
import 'package:brasil_crypto/domain/repositories/coingecko_repository.dart';

class CryptoDetailsCubit extends Cubit<CryptoDetailsState> {
  final CoingeckoRepository repository;

  CryptoDetailsCubit(this.repository) : super(CryptoDetailsInitialState());

  Future<void> loadCryptoDetails(String cryptoId) async {
    try {
      emit(CryptoDetailsLoadingState());

      final details = await repository.getCryptocurrencyDetails(cryptoId);
      emit(CryptoDetailsLoadedState(details: details));
    } on RepositoryException catch (e) {
      emit(CryptoDetailsErrorState(error: e.message));
    } catch (e) {
      emit(CryptoDetailsErrorState(error: 'Erro inesperado: $e'));
    }
  }

  void reset() {
    if (!isClosed) emit(CryptoDetailsInitialState());
  }
}

sealed class CryptoDetailsState {
  const CryptoDetailsState();
}

class CryptoDetailsInitialState extends CryptoDetailsState {
  const CryptoDetailsInitialState();
}

class CryptoDetailsLoadingState extends CryptoDetailsState {
  const CryptoDetailsLoadingState();
}

class CryptoDetailsLoadedState extends CryptoDetailsState {
  final CryptoDetails details;

  const CryptoDetailsLoadedState({required this.details});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoDetailsLoadedState && runtimeType == other.runtimeType && details == other.details;

  @override
  int get hashCode => details.hashCode;
}

class CryptoDetailsErrorState extends CryptoDetailsState {
  final String error;

  const CryptoDetailsErrorState({required this.error});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoDetailsErrorState && runtimeType == other.runtimeType && error == other.error;

  @override
  int get hashCode => error.hashCode;
}

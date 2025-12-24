import 'package:bloc/bloc.dart';
import 'package:brasil_crypto/data/services/exchange_rate_service.dart';

class ExchangeRateCubit extends Cubit<ExchangeRateState> {
  final ExchangeRateService _exchangeRateService;

  ExchangeRateCubit(this._exchangeRateService) : super(const ExchangeRateInitialState());

  Future<void> fetchExchangeRate() async {
    try {
      emit(const ExchangeRateLoadingState());
      final rate = await _exchangeRateService.getUsdToBrlRate();
      print('Exchange rate cubit received: $rate');
      emit(ExchangeRateLoadedState(rate));
    } catch (e) {
      print('Error in exchange rate cubit: $e');
      emit(ExchangeRateErrorState(e.toString()));
    }
  }

  Future<void> refreshExchangeRate() async {
    await fetchExchangeRate();
  }
}

abstract class ExchangeRateState {
  const ExchangeRateState();
}

class ExchangeRateInitialState extends ExchangeRateState {
  const ExchangeRateInitialState();
}

class ExchangeRateLoadingState extends ExchangeRateState {
  const ExchangeRateLoadingState();
}

class ExchangeRateLoadedState extends ExchangeRateState {
  final double rate;

  const ExchangeRateLoadedState(this.rate);
}

class ExchangeRateErrorState extends ExchangeRateState {
  final String error;

  const ExchangeRateErrorState(this.error);
}

import 'package:brasil_crypto/core/dependency_injection/dependency_injector.dart';
import 'package:brasil_crypto/domain/models/cryptocurrency.dart';
import 'package:brasil_crypto/ui/cubit/exchange_rate_cubit.dart';
import 'package:brasil_crypto/ui/cubit/search_crypto_page_cubit.dart';
import 'package:brasil_crypto/ui/widgets/search_crypto_page.dart/crypto_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoList extends StatefulWidget {
  final String searchQuery;

  const CryptoList({super.key, required this.searchQuery});

  @override
  State<CryptoList> createState() => _CryptoListState();
}

class _CryptoListState extends State<CryptoList> {
  final SearchCryptoPageCubit _cubit = DependencyInjector.get<SearchCryptoPageCubit>();
  final ExchangeRateCubit _exchangeRateCubit = DependencyInjector.get<ExchangeRateCubit>();

  Future<void> _onRefresh() async {
    await Future.wait([
      widget.searchQuery.isEmpty
          ? _cubit.loadTopCryptocurrencies(limit: 50)
          : _cubit.searchCryptocurrencies(widget.searchQuery),
      _exchangeRateCubit.refreshExchangeRate(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<SearchCryptoPageCubit, SearchCryptoPageState>(
        bloc: _cubit,
        builder: (context, state) {
          return switch (state) {
            InitialState() => initialStateList(),

            SearchLoadingState() => loadingStateList(),

            SearchSuccessState(:final cryptoList) => successStateList(cryptoList),

            SearchEmptyState() => emptyStateList(),

            SearchErrorState(:final error) => errorStateList(error),
          };
        },
      ),
    );
  }

  Widget initialStateList() {
    return Center(child: Text('Digite para buscar cryptomoedas', style: Theme.of(context).textTheme.bodyLarge));
  }

  Widget loadingStateList() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget successStateList(List<Cryptocurrency> cryptocurrencies) {
    final cryptoList = cryptocurrencies;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: cryptoList.length,

        padding: EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final crypto = cryptoList[index];
          final isPositive = (crypto.priceChangePercentage24h ?? 0) >= 0;

          return CryptoCard(crypto: crypto, isPositive: isPositive, onRefreshCryptoList: _onRefresh);
        },
      ),
    );
  }

  Widget emptyStateList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Nenhuma cryptomoeda encontrada', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Tente buscar por outro nome ou símbolo', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget errorStateList(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text('Erro ao buscar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(error, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _cubit.loadTopCryptocurrencies(limit: 50);
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

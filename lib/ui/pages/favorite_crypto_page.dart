import 'package:brasil_crypto/core/dependency_injection/dependency_injector.dart';
import 'package:brasil_crypto/ui/cubit/exchange_rate_cubit.dart';
import 'package:brasil_crypto/ui/cubit/favorites_cubit.dart';
import 'package:brasil_crypto/ui/widgets/search_crypto_page.dart/crypto_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteCryptoPage extends StatefulWidget {
  const FavoriteCryptoPage({super.key});

  @override
  State<FavoriteCryptoPage> createState() => _FavoriteCryptoPageState();
}

class _FavoriteCryptoPageState extends State<FavoriteCryptoPage> {
  late final FavoritesCubit _cubit;
  late final ExchangeRateCubit _exchangeRateCubit;

  @override
  void initState() {
    super.initState();
    _cubit = DependencyInjector.get<FavoritesCubit>();
    _exchangeRateCubit = DependencyInjector.get<ExchangeRateCubit>();
    _cubit.loadFavorites();
  }

  Future<void> _onRefresh() async {
    // Refresh both favorites and exchange rate
    await Future.wait([_cubit.loadFavorites(), _exchangeRateCubit.refreshExchangeRate()]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cryptomoedas Favoritas'),
          elevation: 0,
          actions: [
            BlocBuilder<FavoritesCubit, FavoritesState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state is FavoritesLoadedState && state.favorites.isNotEmpty) {
                  return PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Limpar tudo'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Limpar favoritos?'),
                              content: const Text('Tem certeza que deseja remover todos os favoritos?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                                TextButton(
                                  onPressed: () {
                                    _cubit.clearAllFavorites();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Limpar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Exchange Rate Card
              BlocBuilder<ExchangeRateCubit, ExchangeRateState>(
                bloc: _exchangeRateCubit,
                builder: (context, state) {
                  if (state is ExchangeRateLoadedState) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[700]!, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cotação do Dólar',
                            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'R\$ ${state.rate.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),

              // Favorites List
              Flexible(
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    return _buildContent(state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(FavoritesState state) {
    if (state is FavoritesLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FavoritesEmptyState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Nenhuma cryptomoeda favorita', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Adicione cryptomoedas aos favoritos\npara acompanhá-las aqui',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (state is FavoritesErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('Erro ao carregar favoritos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(state.error, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => _cubit.loadFavorites(), child: const Text('Tentar novamente')),
          ],
        ),
      );
    }

    if (state is FavoritesLoadedState) {
      final favorites = state.favorites;

      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            final isPositive = (favorite.priceChangePercentage24h ?? 0) >= 0;

            return CryptoCard(crypto: favorite, isPositive: isPositive, onRefreshCryptoList: _onRefresh);
          },
        ),
      );
    }

    return Center(child: Text('Estado desconhecido', style: Theme.of(context).textTheme.bodyLarge));
  }
}

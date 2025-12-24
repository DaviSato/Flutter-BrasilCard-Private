import 'package:brasil_crypto/core/dependency_injection/dependency_injector.dart';
import 'package:brasil_crypto/core/utils/currency_formatter.dart';
import 'package:brasil_crypto/domain/models/crypto_details.dart';
import 'package:brasil_crypto/domain/models/cryptocurrency.dart';
import 'package:brasil_crypto/ui/cubit/crypto_details_cubit.dart';
import 'package:brasil_crypto/ui/cubit/favorites_cubit.dart';
import 'package:brasil_crypto/ui/widgets/price_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class CryptoDetailsDialog extends StatefulWidget {
  final String cryptoId;
  final String cryptoName;
  final VoidCallback onRefreshCryptoList;

  const CryptoDetailsDialog({
    super.key,
    required this.cryptoId,
    required this.cryptoName,
    required this.onRefreshCryptoList,
  });

  @override
  State<CryptoDetailsDialog> createState() => _CryptoDetailsDialogState();
}

class _CryptoDetailsDialogState extends State<CryptoDetailsDialog> {
  final ValueNotifier<bool> isFavoriteNotifier = ValueNotifier<bool>(false);

  final CryptoDetailsCubit _detailsCubit = DependencyInjector.get<CryptoDetailsCubit>();
  final FavoritesCubit _favoritesCubit = DependencyInjector.get<FavoritesCubit>();

  void _confirmRemoveFavorite(BuildContext context, CryptoDetails details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover dos favoritos?'),
        content: Text('Tem certeza que deseja remover ${details.name} dos favoritos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeFromFavorites(context, details);
              widget.onRefreshCryptoList();
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _addToFavorites(BuildContext context, CryptoDetails details) async {
    isFavoriteNotifier.value = true;

    final crypto = Cryptocurrency(
      id: details.id,
      name: details.name,
      symbol: details.symbol,
      image: details.image,
      currentPrice: details.currentPrice,
      priceChangePercentage24h: details.priceChangePercentage24h,
    );

    await _favoritesCubit.addFavorite(crypto);

    _showSnackBar(context, 'Adicionado aos favoritos');
  }

  Future<void> _removeFromFavorites(BuildContext context, CryptoDetails details) async {
    isFavoriteNotifier.value = false;

    await _favoritesCubit.removeFavorite(widget.cryptoId);

    _showSnackBar(context, '${details.name} removido dos favoritos');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  void init() async {
    isFavoriteNotifier.value = await _favoritesCubit.isFavorite(widget.cryptoId);
    _detailsCubit.loadCryptoDetails(widget.cryptoId);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _detailsCubit.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,

      child: BlocBuilder<CryptoDetailsCubit, CryptoDetailsState>(
        bloc: _detailsCubit,
        builder: (context, state) {
          if (state is CryptoDetailsLoadingState) {
            return _buildLoadingDialog();
          }

          if (state is CryptoDetailsErrorState) {
            return _buildErrorDialog(state.error);
          }

          if (state is CryptoDetailsLoadedState) {
            return _buildDetailsDialog(state.details);
          }

          return _buildEmptyDialog();
        },
      ),
    );
  }

  Widget _buildLoadingDialog() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carregando...'),
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorDialog(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erro'),
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(error, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _detailsCubit.loadCryptoDetails(widget.cryptoId),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDialog() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(child: Text('Nenhum dado disponível')),
    );
  }

  Widget _buildDetailsDialog(CryptoDetails details) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(details.name),
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context)),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: isFavoriteNotifier,
            builder: (context, value, child) {
              return IconButton(
                icon: Icon(value ? Icons.favorite : Icons.favorite_border, color: value ? Colors.red : null),
                onPressed: () async {
                  if (isFavoriteNotifier.value) {
                    _confirmRemoveFavorite(context, details);
                  } else {
                    await _addToFavorites(context, details);
                    widget.onRefreshCryptoList();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image and basic info
            _buildHeaderSection(details, theme),
            const SizedBox(height: 24),

            // Price section
            _buildPriceSection(details, theme),
            const SizedBox(height: 24),

            // Price chart section
            PriceChartWidget(
              cryptoName: details.name,
              price24h: details.priceChangePercentage24h,
              price7d: details.priceChangePercentage7d,
              price30d: details.priceChangePercentage30d,
              currentPrice: details.currentPrice ?? 0,
            ),
            const SizedBox(height: 24),

            // Market data section
            _buildMarketDataSection(details, theme),
            const SizedBox(height: 24),

            // Performance metrics section
            _buildPerformanceSection(details, theme),
            const SizedBox(height: 24),

            // Supply information section
            _buildSupplySection(details, theme),
            const SizedBox(height: 24),

            // Description section
            if (details.description != null && details.description!.isNotEmpty)
              _buildDescriptionSection(details, theme),
            const SizedBox(height: 24),

            // Additional info section
            _buildAdditionalInfoSection(details, theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(CryptoDetails details, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (details.image != null)
              Image.network(
                details.image!,
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(40)),
                    child: Icon(Icons.currency_bitcoin, color: Colors.grey[700], size: 40),
                  );
                },
              ),
            const SizedBox(height: 16),
            Text(details.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(20)),
              child: Text(details.symbol, style: theme.textTheme.labelLarge),
            ),
            if (details.marketCapRank != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Rank #${details.marketCapRank}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(CryptoDetails details, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.currentPrice != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preço Atual', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  // Preço em Real (destaque principal)
                  Text(
                    CurrencyFormatter.formatBrl(details.currentPrice! * CurrencyFormatter.getExchangeRate()),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Preço em Dólar (menor destaque)
                  Text(
                    'US\$ ${(details.currentPrice ?? 0).toStringAsFixed(2).replaceAll('.', ',')}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    label: 'Alta 24h',
                    value: CurrencyFormatter.formatBoth(details.high24h),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    label: 'Baixa 24h',
                    value: CurrencyFormatter.formatBoth(details.low24h),
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketDataSection(CryptoDetails details, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dados de Mercado', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    label: 'Capitalização de mercado',
                    value: CurrencyFormatter.formatNumberBoth(details.marketCap ?? 0),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    label: 'Volume 24h',
                    value: CurrencyFormatter.formatNumberBoth(details.totalVolume ?? 0),
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(CryptoDetails details, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (details.priceChangePercentage24h != null)
              _buildChangeMetric(label: 'Variação 24h', value: details.priceChangePercentage24h!, theme: theme),
            if (details.priceChangePercentage7d != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildChangeMetric(label: 'Variação 7d', value: details.priceChangePercentage7d!, theme: theme),
              ),
            if (details.priceChangePercentage30d != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildChangeMetric(
                  label: 'Variação 30d',
                  value: details.priceChangePercentage30d!,
                  theme: theme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplySection(CryptoDetails details, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações de Suprimento',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (details.circulatingSupply != null)
              _buildSupplyMetric(
                label: 'Suprimento em Circulação',
                value: _formatNumber(details.circulatingSupply!),
                theme: theme,
              ),
            if (details.totalSupply != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildSupplyMetric(
                  label: 'Suprimento Total',
                  value: _formatNumber(details.totalSupply!),
                  theme: theme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(CryptoDetails details, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sobre', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(details.description ?? 'Sem descrição disponível', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(CryptoDetails details, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informações Adicionais', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (details.genesisDate != null)
              _buildInfoRow(label: 'Data de Gênese', value: details.genesisDate!, theme: theme),
            if (details.websiteUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Website', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(details.websiteUrl!);

                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Não foi possível abrir o site.';
                        }
                      },
                      child: Text(
                        details.websiteUrl!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({required String label, required String value, required ThemeData theme}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChangeMetric({required String label, required double value, required ThemeData theme}) {
    final isPositive = value >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(
            '${isPositive ? '+' : ''}${value.toStringAsFixed(2)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplyMetric({required String label, required String value, required ThemeData theme}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoRow({required String label, required String value, required ThemeData theme}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    } else {
      return number.toStringAsFixed(2);
    }
  }
}

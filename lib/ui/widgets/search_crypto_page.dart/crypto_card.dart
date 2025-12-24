import 'package:brasil_crypto/core/dependency_injection/dependency_injector.dart';
import 'package:brasil_crypto/core/utils/currency_formatter.dart';
import 'package:brasil_crypto/domain/models/cryptocurrency.dart';
import 'package:brasil_crypto/ui/cubit/favorites_cubit.dart';
import 'package:brasil_crypto/ui/widgets/crypto_details_dialog.dart/crypto_details_dialog.dart';
import 'package:flutter/material.dart';

class CryptoCard extends StatefulWidget {
  final Cryptocurrency crypto;
  final bool isPositive;
  final VoidCallback onRefreshCryptoList;
  const CryptoCard({super.key, required this.crypto, required this.isPositive, required this.onRefreshCryptoList});

  @override
  State<CryptoCard> createState() => _CryptoCardState();
}

class _CryptoCardState extends State<CryptoCard> {
  final ValueNotifier<bool> _isFavorite = ValueNotifier<bool>(false);
  final FavoritesCubit _favoritesCubit = DependencyInjector.get<FavoritesCubit>();

  void init() async {
    _isFavorite.value = await _favoritesCubit.isFavorite(widget.crypto.id);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: .only(bottom: 8),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey[900],

        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: widget.crypto.image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.crypto.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.currency_bitcoin, color: Colors.grey[700], size: 28);
                    },
                  ),
                )
              : Icon(Icons.currency_bitcoin, color: Colors.grey[700], size: 28),
        ),
        title: Text(widget.crypto.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(widget.crypto.symbol.toUpperCase(), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: Row(
          mainAxisSize: .min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.crypto.currentPrice != null)
                  Text(
                    CurrencyFormatter.formatUsdToBrl(widget.crypto.currentPrice!),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                if (widget.crypto.priceChangePercentage24h != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.isPositive
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${widget.isPositive ? '+' : ''}${widget.crypto.priceChangePercentage24h!.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: widget.isPositive ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isFavorite,
              builder: (context, value, child) {
                return IconButton(
                  icon: Icon(value ? Icons.favorite : Icons.favorite_border, color: value ? Colors.red : null),
                  onPressed: () async {
                    if (_isFavorite.value) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remover dos favoritos?'),
                          content: Text('Tem certeza que deseja remover ${widget.crypto.name} dos favoritos?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () {
                                _isFavorite.value = !value;
                                _favoritesCubit.removeFavorite(widget.crypto.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${widget.crypto.name} removido dos favoritos'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text('Remover', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      _isFavorite.value = !value;
                      await _favoritesCubit.addFavorite(widget.crypto);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Adicionado aos favoritos'), duration: const Duration(seconds: 2)),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
        onTap: () {
          showDialog(
            fullscreenDialog: true,
            useSafeArea: false,
            context: context,
            builder: (context) => CryptoDetailsDialog(
              cryptoId: widget.crypto.id,
              cryptoName: widget.crypto.name,
              onRefreshCryptoList: widget.onRefreshCryptoList,
            ),
          );
        },
      ),
    );
  }
}

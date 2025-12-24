import 'package:brasil_crypto/core/dependency_injection/dependency_injector.dart';
import 'package:brasil_crypto/ui/cubit/search_crypto_page_cubit.dart';
import 'package:brasil_crypto/ui/widgets/search_crypto_page.dart/crypto_list.dart';
import 'package:brasil_crypto/ui/widgets/search_crypto_page.dart/exchange_rate_container.dart';
import 'package:flutter/material.dart';

class SearchCryptoPage extends StatefulWidget {
  const SearchCryptoPage({super.key});

  @override
  State<SearchCryptoPage> createState() => _SearchCryptoPageState();
}

class _SearchCryptoPageState extends State<SearchCryptoPage> {
  final SearchCryptoPageCubit _cubit = DependencyInjector.get<SearchCryptoPageCubit>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _cubit.onInit();
    _cubit.loadTopCryptocurrencies(limit: 50);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _cubit.loadTopCryptocurrencies(limit: 50);
    } else {
      _cubit.searchCryptocurrencies(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou símbolo',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[900],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 16),
          ExchangeRateContainer(),
          const SizedBox(height: 8),

          CryptoList(searchQuery: _searchController.text),
        ],
      ),
    );
  }
}

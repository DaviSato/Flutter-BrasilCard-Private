import 'package:brasil_crypto/core/dependency_injection/dependency_injector.dart';
import 'package:brasil_crypto/ui/cubit/exchange_rate_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExchangeRateContainer extends StatefulWidget {
  const ExchangeRateContainer({super.key});

  @override
  State<ExchangeRateContainer> createState() => _ExchangeRateContainerState();
}

class _ExchangeRateContainerState extends State<ExchangeRateContainer> {
  final ExchangeRateCubit _exchangeRateCubit = DependencyInjector.get<ExchangeRateCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeRateCubit, ExchangeRateState>(
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
    );
  }
}

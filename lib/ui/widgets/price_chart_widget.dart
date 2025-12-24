import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PriceChartWidget extends StatelessWidget {
  final String cryptoName;
  final double? price24h;
  final double? price7d;
  final double? price30d;
  final double currentPrice;

  const PriceChartWidget({
    super.key,
    required this.cryptoName,
    this.price24h,
    this.price7d,
    this.price30d,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Debug: Print dos valores recebidos
    print('PriceChartWidget - price24h: $price24h, price7d: $price7d, price30d: $price30d');

    final prices = [price24h ?? 0, price7d ?? 0, price30d ?? 0];
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final isPositive = (price30d ?? 0) >= 0;

    // Se todos os preços são zero ou nulos, mostrar mensagem
    if (maxPrice == 0 && minPrice == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Text(
          'Dados de histórico de preço indisponíveis',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título e badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'Histórico de Preço',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Variação de preço nos últimos 30 dias, 7 dias e 24 horas',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${price30d?.toStringAsFixed(2) ?? 'N/A'}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Gráfico
          SizedBox(
            height: 280,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      // Invertido: 30d, 7d, 24h (do passado para o presente)
                      spots: [FlSpot(0, price30d ?? 0), FlSpot(1, price7d ?? 0), FlSpot(2, price24h ?? 0)],
                      isCurved: true,
                      color: isPositive ? const Color(0xFF34A853) : const Color(0xFFEA4335),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      shadow: Shadow(
                        color: (isPositive ? const Color(0xFF34A853) : const Color(0xFFEA4335)).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: isPositive ? const Color(0xFF34A853) : const Color(0xFFEA4335),
                            strokeColor: Colors.black,
                            strokeWidth: 2,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (isPositive ? const Color(0xFF34A853) : const Color(0xFFEA4335)).withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          // Invertido: 30d, 7d, 24h
                          const titles = ['30d', '7d', '24h'];
                          final index = value.toInt();
                          if (index >= 0 && index < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                titles[index],
                                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          // Mostrar valores reais de preço
                          return Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w400),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxPrice - minPrice) / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[800]!.withValues(alpha: 0.2),
                        strokeWidth: 0.8,
                        dashArray: [4, 4],
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.grey[800]!, width: 0.8),
                      bottom: BorderSide(color: Colors.grey[800]!, width: 0.8),
                    ),
                  ),
                  minX: -0.5,
                  maxX: 2.5,
                  // Usar os preços reais como minY e maxY
                  minY: (minPrice * 0.98).toDouble(),
                  maxY: (maxPrice * 1.02).toDouble(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend com cards
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildLegendCards(context)),
        ],
      ),
    );
  }

  Widget _buildLegendCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendCard(context, '30 dias', price30d),
        _buildLegendCard(context, '7 dias', price7d),
        _buildLegendCard(context, '24 horas', price24h),
      ],
    );
  }

  Widget _buildLegendCard(BuildContext context, String period, double? value) {
    final isPositive = (value ?? 0) >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[800]!, width: 0.8),
        ),
        child: Column(
          children: [
            Text(
              period,
              style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              '${isPositive ? '+' : ''}${value?.toStringAsFixed(2) ?? 'N/A'}%',
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

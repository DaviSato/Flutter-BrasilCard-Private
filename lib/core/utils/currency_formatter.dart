class CurrencyFormatter {
  static double _usdToBrlRate = 5.5902;

  static void setExchangeRate(double rate) {
    _usdToBrlRate = rate;
  }

  static double getExchangeRate() => _usdToBrlRate;

  static String _formatBrValue(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decimalPart = parts[1];

    // Add thousands separator (dot)
    String formatted = '';
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = '.$formatted';
      }
      formatted = intPart[i] + formatted;
      count++;
    }

    return '$formatted,$decimalPart';
  }

  static double usdToBrl(double usd) {
    return usd * _usdToBrlRate;
  }

  static String formatUsd(double? value) {
    if (value == null) return 'N/A';
    return 'US\$ ${value.toStringAsFixed(2)}';
  }

  static String formatBrl(double? value) {
    if (value == null) return 'N/A';
    return 'R\$ ${_formatBrValue(value)}';
  }

  static String formatUsdToBrl(double? value) {
    if (value == null) return 'N/A';
    final converted = usdToBrl(value);
    return 'R\$ ${_formatBrValue(converted)}';
  }

  static String formatBoth(double? value) {
    if (value == null) return 'N/A';
    final brl = usdToBrl(value);
    return 'R\$ ${_formatBrValue(brl)} / US\$ ${value.toStringAsFixed(2)}';
  }

  static String formatNumberBrl(double number) {
    if (number >= 1000000000) {
      return 'R\$ ${_formatBrValue(number / 1000000000)}B';
    } else if (number >= 1000000) {
      return 'R\$ ${_formatBrValue(number / 1000000)}M';
    } else if (number >= 1000) {
      return 'R\$ ${_formatBrValue(number / 1000)}K';
    } else {
      return 'R\$ ${_formatBrValue(number)}';
    }
  }

  static String formatNumberBoth(double number) {
    final brl = usdToBrl(number);
    if (brl >= 1000000000) {
      final brlFormatted = _formatBrValue(brl / 1000000000);
      final usdFormatted = (number / 1000000000).toStringAsFixed(2);
      return 'R\$ ${brlFormatted}B / US\$ ${usdFormatted}B';
    } else if (brl >= 1000000) {
      final brlFormatted = _formatBrValue(brl / 1000000);
      final usdFormatted = (number / 1000000).toStringAsFixed(2);
      return 'R\$ ${brlFormatted}M / US\$ ${usdFormatted}M';
    } else if (brl >= 1000) {
      final brlFormatted = _formatBrValue(brl / 1000);
      final usdFormatted = (number / 1000).toStringAsFixed(2);
      return 'R\$ ${brlFormatted}K / US\$ ${usdFormatted}K';
    } else {
      return 'R\$ ${_formatBrValue(brl)} / US\$ ${number.toStringAsFixed(2)}';
    }
  }
}

class Cryptocurrency {
  final String id;
  final String name;
  final String symbol;
  final String? image;
  final double? currentPrice;
  final double? marketCapRank;
  final double? marketCap;
  final double? totalVolume;
  final double? priceChangePercentage24h;
  final double? high24h;
  final double? low24h;

  Cryptocurrency({
    required this.id,
    required this.name,
    required this.symbol,
    this.image,
    this.currentPrice,
    this.marketCapRank,
    this.marketCap,
    this.totalVolume,
    this.priceChangePercentage24h,
    this.high24h,
    this.low24h,
  });

  factory Cryptocurrency.fromJson(Map<String, dynamic> json) {
    final image = (json['image'] as String?) ?? (json['large'] as String?) ?? (json['thumb'] as String?);

    return Cryptocurrency(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      image: image,
      currentPrice: _parseDouble(json['current_price']),
      marketCapRank: _parseDouble(json['market_cap_rank']),
      marketCap: _parseDouble(json['market_cap']),
      totalVolume: _parseDouble(json['total_volume']),
      priceChangePercentage24h: _parseDouble(json['price_change_percentage_24h']),
      high24h: _parseDouble(json['high_24h']),
      low24h: _parseDouble(json['low_24h']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'image': image,
      'current_price': currentPrice,
      'market_cap_rank': marketCapRank,
      'market_cap': marketCap,
      'total_volume': totalVolume,
      'price_change_percentage_24h': priceChangePercentage24h,
      'high_24h': high24h,
      'low_24h': low24h,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cryptocurrency &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          symbol == other.symbol;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ symbol.hashCode;

  @override
  String toString() => 'Cryptocurrency(id: $id, name: $name, symbol: $symbol, price: \$$currentPrice)';

  Cryptocurrency copyWith({
    String? id,
    String? name,
    String? symbol,
    String? image,
    double? currentPrice,
    double? marketCapRank,
    double? marketCap,
    double? totalVolume,
    double? priceChangePercentage24h,
    double? high24h,
    double? low24h,
  }) {
    return Cryptocurrency(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      image: image ?? this.image,
      currentPrice: currentPrice ?? this.currentPrice,
      marketCapRank: marketCapRank ?? this.marketCapRank,
      marketCap: marketCap ?? this.marketCap,
      totalVolume: totalVolume ?? this.totalVolume,
      priceChangePercentage24h: priceChangePercentage24h ?? this.priceChangePercentage24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
    );
  }
}

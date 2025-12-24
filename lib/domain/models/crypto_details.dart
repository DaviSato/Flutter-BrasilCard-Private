class CryptoDetails {
  final String id;
  final String name;
  final String symbol;
  final String? image;
  final String? description;
  final double? currentPrice;
  final double? marketCap;
  final int? marketCapRank;
  final double? totalVolume;
  final double? high24h;
  final double? low24h;
  final double? priceChangePercentage24h;
  final double? priceChangePercentage7d;
  final double? priceChangePercentage30d;
  final double? circulatingSupply;
  final double? totalSupply;
  final String? websiteUrl;
  final String? genesisDate;

  CryptoDetails({
    required this.id,
    required this.name,
    required this.symbol,
    this.image,
    this.description,
    this.currentPrice,
    this.marketCap,
    this.marketCapRank,
    this.totalVolume,
    this.high24h,
    this.low24h,
    this.priceChangePercentage24h,
    this.priceChangePercentage7d,
    this.priceChangePercentage30d,
    this.circulatingSupply,
    this.totalSupply,
    this.websiteUrl,
    this.genesisDate,
  });

  factory CryptoDetails.fromJson(Map<String, dynamic> json) {
    return CryptoDetails(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      image: _extractImageUrl(json['image']),
      description: _extractDescription(json['description']),
      currentPrice: _parseDouble(json['market_data']?['current_price']?['usd']),
      marketCap: _parseDouble(json['market_data']?['market_cap']?['usd']),
      marketCapRank: json['market_cap_rank'] as int?,
      totalVolume: _parseDouble(json['market_data']?['total_volume']?['usd']),
      high24h: _parseDouble(json['market_data']?['high_24h']?['usd']),
      low24h: _parseDouble(json['market_data']?['low_24h']?['usd']),
      priceChangePercentage24h: _parseDouble(json['market_data']?['price_change_percentage_24h']),
      priceChangePercentage7d: _parseDouble(json['market_data']?['price_change_percentage_7d']),
      priceChangePercentage30d: _parseDouble(json['market_data']?['price_change_percentage_30d']),
      circulatingSupply: _parseDouble(json['market_data']?['circulating_supply']),
      totalSupply: _parseDouble(json['market_data']?['total_supply']),
      websiteUrl: _extractWebsiteUrl(json['links']),
      genesisDate: json['genesis_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'image': image,
      'description': description,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'total_volume': totalVolume,
      'high_24h': high24h,
      'low_24h': low24h,
      'price_change_percentage_24h': priceChangePercentage24h,
      'price_change_percentage_7d': priceChangePercentage7d,
      'price_change_percentage_30d': priceChangePercentage30d,
      'circulating_supply': circulatingSupply,
      'total_supply': totalSupply,
      'website_url': websiteUrl,
      'genesis_date': genesisDate,
    };
  }

  static String? _extractImageUrl(dynamic imageData) {
    if (imageData == null) return null;
    if (imageData is Map) {
      return imageData['large'] as String? ?? imageData['small'] as String? ?? imageData['thumb'] as String?;
    }
    return null;
  }

  static String? _extractDescription(dynamic descriptionData) {
    if (descriptionData == null) return null;
    if (descriptionData is Map) {
      return descriptionData['en'] as String?;
    }
    return null;
  }

  static String? _extractWebsiteUrl(dynamic linksData) {
    if (linksData == null) return null;
    if (linksData is Map) {
      final homepage = linksData['homepage'] as List?;
      if (homepage != null && homepage.isNotEmpty) {
        return homepage.first as String?;
      }
    }
    return null;
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
      identical(this, other) || other is CryptoDetails && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CryptoDetails(id: $id, name: $name, symbol: $symbol, price: \$$currentPrice)';

  CryptoDetails copyWith({
    String? id,
    String? name,
    String? symbol,
    String? image,
    String? description,
    double? currentPrice,
    double? marketCap,
    int? marketCapRank,
    double? totalVolume,
    double? high24h,
    double? low24h,
    double? priceChangePercentage24h,
    double? priceChangePercentage7d,
    double? priceChangePercentage30d,
    double? circulatingSupply,
    double? totalSupply,
    String? websiteUrl,
    String? genesisDate,
  }) {
    return CryptoDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      image: image ?? this.image,
      description: description ?? this.description,
      currentPrice: currentPrice ?? this.currentPrice,
      marketCap: marketCap ?? this.marketCap,
      marketCapRank: marketCapRank ?? this.marketCapRank,
      totalVolume: totalVolume ?? this.totalVolume,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      priceChangePercentage24h: priceChangePercentage24h ?? this.priceChangePercentage24h,
      priceChangePercentage7d: priceChangePercentage7d ?? this.priceChangePercentage7d,
      priceChangePercentage30d: priceChangePercentage30d ?? this.priceChangePercentage30d,
      circulatingSupply: circulatingSupply ?? this.circulatingSupply,
      totalSupply: totalSupply ?? this.totalSupply,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      genesisDate: genesisDate ?? this.genesisDate,
    );
  }
}

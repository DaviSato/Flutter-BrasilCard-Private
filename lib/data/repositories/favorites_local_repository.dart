import 'dart:convert';

import 'package:brasil_crypto/domain/models/cryptocurrency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocalRepository {
  static const String _favoritesKey = 'favorite_cryptocurrencies';
  final SharedPreferences _prefs;

  FavoritesLocalRepository(this._prefs);

  Future<List<Cryptocurrency>> getFavorites() async {
    try {
      final jsonString = _prefs.getString(_favoritesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final favorites = jsonList
          .map((item) {
            try {
              return Cryptocurrency.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              return null;
            }
          })
          .whereType<Cryptocurrency>()
          .toList();

      return favorites;
    } catch (e) {
      return [];
    }
  }

  Future<bool> addFavorite(Cryptocurrency crypto) async {
    try {
      final favorites = await getFavorites();

      if (favorites.any((fav) => fav.id == crypto.id)) {
        return false;
      }

      favorites.add(crypto);
      final jsonString = jsonEncode(favorites.map((fav) => fav.toJson()).toList());

      await _prefs.setString(_favoritesKey, jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(String cryptoId) async {
    try {
      final favorites = await getFavorites();
      final initialLength = favorites.length;

      favorites.removeWhere((fav) => fav.id == cryptoId);

      if (favorites.length == initialLength) {
        return false;
      }

      final jsonString = jsonEncode(favorites.map((fav) => fav.toJson()).toList());

      await _prefs.setString(_favoritesKey, jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isFavorite(String cryptoId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((fav) => fav.id == cryptoId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateFavorite(Cryptocurrency crypto) async {
    try {
      final favorites = await getFavorites();
      final index = favorites.indexWhere((fav) => fav.id == crypto.id);

      if (index == -1) {
        return false;
      }

      favorites[index] = crypto.copyWith();
      final jsonString = jsonEncode(favorites.map((fav) => fav.toJson()).toList());

      await _prefs.setString(_favoritesKey, jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      await _prefs.setString(_favoritesKey, jsonEncode([]));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getFavoritesCount() async {
    try {
      final favorites = await getFavorites();
      return favorites.length;
    } catch (e) {
      return 0;
    }
  }
}

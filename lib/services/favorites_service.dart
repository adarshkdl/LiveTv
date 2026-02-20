import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorite_channel_ids';

  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> addFavorite(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (!list.contains(channelId)) {
      list.add(channelId);
      await prefs.setStringList(_key, list);
    }
  }

  Future<void> removeFavorite(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(channelId);
    await prefs.setStringList(_key, list);
  }

  Future<bool> isFavorite(String channelId) async {
    final list = await getFavorites();
    return list.contains(channelId);
  }
}

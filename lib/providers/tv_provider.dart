import 'package:flutter/foundation.dart';
import '../models/channel.dart';
import '../models/stream_model.dart';
import '../models/country.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

enum LoadState { idle, loading, loaded, error }

class TvProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final FavoritesService _favSvc = FavoritesService();

  List<Channel> _allChannels = [];
  List<Country> _allCountries = [];
  Set<String> _favorites = {};

  LoadState _loadState = LoadState.idle;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCountry;
  String? _selectedCategory;

  // ── Getters ────────────────────────────────────────────────────────────────

  LoadState get loadState => _loadState;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCountry => _selectedCountry;
  String? get selectedCategory => _selectedCategory;

  List<Channel> get filteredChannels {
    var result = _allChannels.where((c) => c.hasStream && !c.isNsfw).toList();

    if (_selectedCountry != null) {
      result = result.where((c) => c.country == _selectedCountry).toList();
    }
    if (_selectedCategory != null) {
      result =
          result.where((c) => c.categories.contains(_selectedCategory)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.altNames.any((n) => n.toLowerCase().contains(q)))
          .toList();
    }
    return result;
  }

  List<Channel> get favoriteChannels =>
      _allChannels.where((c) => _favorites.contains(c.id)).toList();

  List<Country> get availableCountries {
    final codes =
        _allChannels.where((c) => c.hasStream).map((c) => c.country).toSet();
    return _allCountries
        .where((c) => codes.contains(c.code))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<String> get availableCategories {
    return _allChannels
        .where((c) => c.hasStream)
        .expand((c) => c.categories)
        .toSet()
        .toList()
      ..sort();
  }

  int channelCountForCountry(String code) =>
      _allChannels.where((c) => c.hasStream && c.country == code).length;

  bool isFavorite(String id) => _favorites.contains(id);

  List<Channel> getChannelsForCountry(String code) {
    return _allChannels
        .where((c) => c.hasStream && !c.isNsfw && c.country == code)
        .toList();
  }

  Country? getCountry(String code) {
    try {
      return _allCountries.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _loadState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.fetchChannels(),
        _api.fetchStreams(),
        _api.fetchCountries(),
        _favSvc.getFavorites(),
      ]);

      final channels = results[0] as List<Channel>;
      final streams = results[1] as List<StreamModel>;
      final countries = results[2] as List<Country>;
      final favList = results[3] as List<String>;

      // Map first valid stream URL to each channel
      final streamMap = <String, StreamModel>{};
      for (final s in streams) {
        if (s.channelId != null && !streamMap.containsKey(s.channelId)) {
          streamMap[s.channelId!] = s;
        }
      }
      for (final ch in channels) {
        final s = streamMap[ch.id];
        if (s != null) {
          ch.streamUrl = s.url;
          ch.userAgent = s.userAgent;
          ch.referrer = s.referrer;
        }
      }

      _allChannels = channels;
      _allCountries = countries;
      _favorites = favList.toSet();
      _loadState = LoadState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _loadState = LoadState.error;
    }

    notifyListeners();
  }

  // ── Filters ────────────────────────────────────────────────────────────────

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCountry(String? code) {
    _selectedCountry = code;
    _selectedCategory = null;
    notifyListeners();
  }

  void setCategory(String? cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCountry = null;
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  Future<void> toggleFavorite(String channelId) async {
    if (_favorites.contains(channelId)) {
      _favorites.remove(channelId);
      await _favSvc.removeFavorite(channelId);
    } else {
      _favorites.add(channelId);
      await _favSvc.addFavorite(channelId);
    }
    notifyListeners();
  }
}

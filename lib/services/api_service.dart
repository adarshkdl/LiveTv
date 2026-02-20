import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/channel.dart';
import '../models/stream_model.dart';
import '../models/country.dart';

class ApiService {
  static const String _base = 'https://iptv-org.github.io/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<List<Channel>> fetchChannels() async {
    final response = await http.get(Uri.parse('$_base/channels.json'));
    if (response.statusCode == 200) {
      return compute(_parseChannels, response.body);
    }
    throw Exception('Failed to load channels (${response.statusCode})');
  }

  Future<List<StreamModel>> fetchStreams() async {
    final response = await http.get(Uri.parse('$_base/streams.json'));
    if (response.statusCode == 200) {
      return compute(_parseStreams, response.body);
    }
    throw Exception('Failed to load streams (${response.statusCode})');
  }

  Future<List<Country>> fetchCountries() async {
    final response = await http.get(Uri.parse('$_base/countries.json'));
    if (response.statusCode == 200) {
      return compute(_parseCountries, response.body);
    }
    throw Exception('Failed to load countries (${response.statusCode})');
  }
}

List<Channel> _parseChannels(String body) {
  final List<dynamic> data = json.decode(body) as List;
  return data
      .map((e) => Channel.fromJson(e as Map<String, dynamic>))
      .where((c) => c.id.isNotEmpty && c.name.isNotEmpty)
      .toList();
}

List<StreamModel> _parseStreams(String body) {
  final List<dynamic> data = json.decode(body) as List;
  return data
      .map((e) => StreamModel.fromJson(e as Map<String, dynamic>))
      .where((s) => s.isValid)
      .toList();
}

List<Country> _parseCountries(String body) {
  final List<dynamic> data = json.decode(body) as List;
  return data
      .map((e) => Country.fromJson(e as Map<String, dynamic>))
      .where((c) => c.code.isNotEmpty && c.name.isNotEmpty)
      .toList();
}

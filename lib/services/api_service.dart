import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station.dart';

class ApiService {
  static Future<List<RadioStation>> searchStations(String query) async {
    final url = Uri.parse('https://de1.api.radio-browser.info/json/stations/search?name=$query&country=Poland&limit=20');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RadioStation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stations');
    }
  }
}
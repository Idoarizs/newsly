import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class NewsService {
  final String baseUrl = 'https://newsapi.org/v2';
  late String apiKey;

  NewsService() {
    apiKey = dotenv.env['API_KEY'] ?? '';
  }

  Future<List<dynamic>> fetchData({String query = ''}) async {
    final encodedQuery = Uri.encodeComponent(query);
    String url = '$baseUrl/everything?q=$encodedQuery&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articles'] ?? [];
    } else {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  }
}

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class NewsService {
  final String baseUrl = 'https://newsapi.org/v2';
  late String apiKey;

  NewsService() {
    apiKey = dotenv.env['API_KEY'] ?? '';
  }

  // Fetch news articles with an optional query for search
  Future<List<dynamic>> fetchData({String query = ''}) async {
    if (apiKey.isEmpty) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    // URL for top headlines in the US
    String url = '$baseUrl/top-headlines?country=us&apiKey=$apiKey';

    // Append the query if search is active
    if (query.isNotEmpty) {
      // Ensure query is URL-encoded to handle spaces or special characters
      final encodedQuery = Uri.encodeComponent(query);
      url += '&q=$encodedQuery';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articles'] ?? [];
    } else {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  }
}

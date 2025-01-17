import 'package:flutter/material.dart';

// Services
import 'package:news_app/services/news_service.dart';

// Widgets
import 'package:news_app/widgets/article_list.dart';
import 'package:news_app/widgets/search_bar.dart' as CustomSearchBar;
import 'package:news_app/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _newsService = NewsService();
  List<dynamic> _articles = [];
  bool _isLoading = true;
  String _currentCategory = 'general';

  void _fetchNews([String query = '']) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articles = await _newsService.fetchData(query: query);
      setState(() {
        _articles = articles;
      });
    } catch (e) {
      print('Error fetching news: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _currentCategory = category;
    });
    _fetchNews(category);
  }

  @override
  void initState() {
    super.initState();
    _fetchNews(_currentCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: Column(
          children: [
            CustomSearchBar.SearchBar(onSearch: _fetchNews),
            const SizedBox(height: 32.0),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ))
                  : ArticleList(articles: _articles),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentCategory: _currentCategory,
        onCategorySelected: _onCategorySelected,
      ),
    );
  }
}

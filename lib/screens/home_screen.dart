import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for shared_preferences
import 'dart:convert'; // For JSON encoding/decoding

// Services
import 'package:news_app/services/news_service.dart'; // Import your NewsService

// Screen
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _newsService = NewsService(); // Initialize the NewsService
  List<dynamic> _articles = [];
  List<dynamic> _bookmarkedArticles = [];
  bool _isLoading = true;
  bool _showBookmarks = false; // Toggle between articles and bookmarks
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNews(); // Fetch top headlines on load
    _loadBookmarks(); // Load bookmarks on init
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch news based on the query or get all top headlines if the query is empty
  void _fetchNews({String query = ''}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articles = await _newsService.fetchData(query: query); // Fetch from NewsService
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching news: $e');
    }
  }

  // Check if an article is bookmarked by comparing article title
  bool _isBookmarked(dynamic article) {
    return _bookmarkedArticles.any((bookmark) => bookmark['title'] == article['title']);
  }

  // Save an article to the bookmarks
  void _saveBookmark(dynamic article) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String articleString = jsonEncode(article); // Convert article to JSON string
    List<String> bookmarkStrings = prefs.getStringList('bookmarks') ?? [];

    // Add the bookmark if it's not already saved
    if (!_isBookmarked(article)) {
      bookmarkStrings.add(articleString);
      await prefs.setStringList('bookmarks', bookmarkStrings);
    }

    _loadBookmarks(); // Refresh the bookmarks list
  }

  // Remove an article from the bookmarks
  void _removeBookmark(dynamic article) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarkStrings = prefs.getStringList('bookmarks') ?? [];

    // Remove the article from bookmarks
    bookmarkStrings.removeWhere((str) {
      var decodedArticle = jsonDecode(str);
      return decodedArticle['title'] == article['title'];
    });

    await prefs.setStringList('bookmarks', bookmarkStrings);
    _loadBookmarks(); // Refresh the bookmarks list
  }

  // Load bookmarks from shared_preferences
  void _loadBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? bookmarkStrings = prefs.getStringList('bookmarks') ?? [];

    setState(() {
      _bookmarkedArticles = bookmarkStrings
          .map((str) => jsonDecode(str)) // Convert JSON back to article objects
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showBookmarks ? Icons.article : Icons.bookmark),
            color: Colors.grey[900],
            onPressed: () {
              setState(() {
                _showBookmarks = !_showBookmarks; // Toggle between articles and bookmarks
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16.0),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _showBookmarks
                      ? _buildBookmarkList() // Show bookmarked articles
                      : _buildArticleList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for the search bar
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search News',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            _fetchNews(query: _searchController.text); // Search for articles based on query
          },
        ),
      ],
    );
  }

  // Widget to build article list
  Widget _buildArticleList() {
    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        final isBookmarked = _isBookmarked(article); // Check if the article is bookmarked
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(article['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(article['description'] ?? 'No description available'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(article: article),
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked
                    ? Colors.grey[900]
                    : Colors.grey, // Change color based on bookmark state
              ),
              onPressed: () {
                setState(() {
                  if (isBookmarked) {
                    _removeBookmark(article); // Remove if already bookmarked
                  } else {
                    _saveBookmark(article); // Add to bookmarks if not bookmarked
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  // Widget to build bookmark list
  Widget _buildBookmarkList() {
    return ListView.builder(
      itemCount: _bookmarkedArticles.length,
      itemBuilder: (context, index) {
        final article = _bookmarkedArticles[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(article['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(article: article),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete), // Trash icon
              color: Colors.red, // Change color to indicate deletion
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text('Are you sure you want to delete this bookmark?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            setState(() {
                              _removeBookmark(article); // Remove the bookmark
                            });
                            Navigator.of(context).pop(); // Close the dialog

                            // Show a SnackBar to confirm deletion
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Bookmark deleted successfully!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

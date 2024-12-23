import 'package:flutter/material.dart';
import 'package:share/share.dart'; // Don't forget to add this dependency in pubspec.yaml
import 'package:url_launcher/url_launcher.dart'; // Ensure this is added for launching URLs

class DetailScreen extends StatelessWidget {
  final dynamic article;

  const DetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.share), // Share icon
            onPressed: () {
              // Implement share functionality
              Share.share(article['url'], subject: 'Check out this article: ${article['title']}');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Enable scrolling for longer articles
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                article['title'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                article['publishedAt'] != null
                    ? 'Published on: ${article['publishedAt']}'
                    : 'Published on: Unknown',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                article['content'] ?? 'No content available',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Source: ${article['source']['name']}',
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await launchUrl(Uri.parse(article['url']));
                    // Optionally show a success SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Launching ${article['title']}...')),
                    );
                  } catch (e) {
                    // Show an error SnackBar if the URL cannot be launched
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Read Full Article'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

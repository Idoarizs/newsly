import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final void Function(String) onSearch;

  const SearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.black, width: 0.1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search News',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.0),
              ),
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final query = _controller.text.trim();
              if (query.isNotEmpty) {
                onSearch(query); // Memastikan hanya mengirimkan String
              }
            },
          ),
        ],
      ),
    );
  }
}

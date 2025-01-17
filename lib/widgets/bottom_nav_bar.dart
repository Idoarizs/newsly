import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final String currentCategory;
  final Function(String) onCategorySelected;

  int _getSelectedIndex() {
    switch (currentCategory) {
      case 'business':
        return 1;
      case 'sports':
        return 2;
      case 'science':
        return 3;
      default:
        return 0;
    }
  }

  String _getCategoryByIndex(int index) {
    switch (index) {
      case 1:
        return 'business';
      case 2:
        return 'sports';
      case 3:
        return 'science';
      default:
        return 'general';
    }
  }

  const BottomNavBar({
    super.key,
    required this.currentCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[500],
      iconSize: 16,
      currentIndex: _getSelectedIndex(),
      onTap: (index) => onCategorySelected(_getCategoryByIndex(index)),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: 'General',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports),
          label: 'Sports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.science),
          label: 'Science',
        ),
      ],
    );
  }
}

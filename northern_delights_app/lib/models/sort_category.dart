// gastropub_screen.dart
import 'package:flutter/material.dart';
import 'package:northern_delights_app/widgets/category_button.dart';
import 'package:northern_delights_app/widgets/gastropub_card.dart';

class CategorizedScreen extends StatefulWidget {
  @override
  _CategorizedScreenState createState() => _CategorizedScreenState();
}

class _CategorizedScreenState extends State<CategorizedScreen> {
  // State to track the currently selected category
  String _selectedCategory = 'Most Viewed';

  // Method to update the selected category
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category; // Update the selected category
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pass the callback to update the selected category
        CategoryButton(onCategorySelected: _onCategorySelected, selectedCategory: _selectedCategory),

        // Pass the selected category to GastropubCards
        Expanded(
          child: GastropubCards(selectedCategory: _selectedCategory),
        ),
      ],
    );
  }
}

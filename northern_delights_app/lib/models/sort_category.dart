import 'package:flutter/material.dart';
import 'package:northern_delights_app/widgets/category_button.dart';
import 'package:northern_delights_app/widgets/gastropub_card.dart';

class CategorizedScreen extends StatefulWidget {
  @override
  _CategorizedScreenState createState() => _CategorizedScreenState();
}

class _CategorizedScreenState extends State<CategorizedScreen> {
  String _selectedCategory = 'Most Viewed';

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
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

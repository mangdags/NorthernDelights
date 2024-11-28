// gastropub_screen.dart
import 'package:flutter/material.dart';
import 'package:northern_delights_app/widgets/category_button.dart';
import 'package:northern_delights_app/widgets/gastropub_card.dart';

class CategorizedScreen extends StatefulWidget {
  const CategorizedScreen({super.key});

  @override
  _CategorizedScreenState createState() => _CategorizedScreenState();
}

class _CategorizedScreenState extends State<CategorizedScreen> {
  String _selectedCategory = 'Most Viewed';

  // Update selected category
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategoryButton(onCategorySelected: _onCategorySelected, selectedCategory: _selectedCategory),

        Expanded(
          child: GastropubCards(isRegular: true, selectedCategory: _selectedCategory),
        ),
      ],
    );
  }
}

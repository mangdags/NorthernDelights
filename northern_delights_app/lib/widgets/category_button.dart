import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String selectedCategory;

  const CategoryButton({
    super.key,
    required this.onCategorySelected,
    required this.selectedCategory,
  });

  Widget buildCategoryButton(String label, Color bgColor, Color textColor) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          selectedCategory == label ? Colors.black : bgColor,
        ),
      ),
      onPressed: () {
        onCategorySelected(label); // Notify parent about selected category

      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: selectedCategory == label ? Colors.white : textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildCategoryButton('Most Viewed', Color(0xFFFBFBFB), Color(0xFFC5C5C5)),
        //buildCategoryButton('Nearby', Color(0xFFFBFBFB), Color(0xFFC5C5C5)),
        buildCategoryButton('Latest', Color(0xFFFBFBFB), Color(0xFFC5C5C5)),
      ],
    );
  }
}

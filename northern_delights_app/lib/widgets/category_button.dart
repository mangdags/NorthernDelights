import 'package:flutter/material.dart';

class CategoryButton extends StatefulWidget {
  const CategoryButton({super.key});

  @override
  _CategoryButtonState createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  // Variable to track the currently selected button
  String selectedCategory = 'Most Viewed';

  // Function to build each category button
  Widget buildCategoryButton(String label, Color bgColor, Color textColor) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          selectedCategory == label ? Colors.black : bgColor,
        ), // Changes background color based on the selected button
        padding: WidgetStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(
            vertical: 10, // Adjust for vertical space
            horizontal: 20, // Adjust for horizontal space
          ),
        ),
        elevation: WidgetStateProperty.resolveWith<double?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return 5;
            }
            return 2; // Default elevation
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.focused)) {
              return Colors.red.withOpacity(0.2);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.green.withOpacity(0.2);
            }
            if (states.contains(WidgetState.pressed)) {
              return Colors.blue.withOpacity(0.2);
            }
            return null;
          },
        ),
      ),
      onPressed: () {
        setState(() {
          // Update the selected category when this button is clicked
          selectedCategory = label;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16, // Larger text size for better readability
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
        buildCategoryButton('Nearby', Color(0xFFFBFBFB), Color(0xFFC5C5C5)),
        buildCategoryButton('Latest', Color(0xFFFBFBFB), Color(0xFFC5C5C5)),
      ],
    );
  }
}

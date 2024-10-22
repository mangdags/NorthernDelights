import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/widgets/gastropub_card.dart';
import 'package:northern_delights_app/widgets/restaurant_card.dart';
import 'package:northern_delights_app/widgets/category_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State to track the currently selected category
  String _selectedCategory = 'Most Viewed'; // Default category

  // Method to update the selected category when a button is pressed
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Northern',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Roboto'
                  ),
                ),
                Text(
                  ' Delights',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montez'
                  ),
                ),
              ],
            ),
          ),
          centerTitle: false,
          backgroundColor: const Color.fromARGB(255, 0, 85, 255),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, MangDags',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 15, left: 20, right: 20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.11),
                            blurRadius: 40,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                            prefixIcon: Opacity(
                              opacity: 0.5,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset('assets/icons/search.svg'),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30,),

                CategoryButton(
                  onCategorySelected: _onCategorySelected, // Pass the callback
                  selectedCategory: _selectedCategory, // Pass the current state
                ),

                const SizedBox(height: 20),
                // Limit the height of the ListView to prevent overflow
                const Text('Gastropub',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  )),

                const SizedBox(height: 20),

                SizedBox(
                  height: 320, // Set a fixed height for the horizontal list
                  child: GastropubCards(selectedCategory: _selectedCategory,),
                ),

                SizedBox(height: 5,),

                Text('Restaurants',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  )),

                const SizedBox(height: 10,),

                SizedBox(
                  height: 320, // Set a fixed height for the horizontal list
                  child: RestaurantsCard(selectedCategory: _selectedCategory,),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
          BottomNavigationBar(
            backgroundColor: Colors.blue,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                backgroundColor: Colors.blue,
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.blue,
                icon: Icon(Icons.history),
                label: 'Recent',
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.blue,
                icon: Icon(Icons.bookmark),
                label: 'Liked',
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.blue,
                icon: Icon(Icons.account_circle_rounded),
                label: 'Profile',
              ),
            ],
          ),

      ),
    );
  }

 Widget buildCategoryButton(String label, Color bgColor, Color textColor) {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(bgColor), // Background color
      padding: WidgetStateProperty.all<EdgeInsets>(
        EdgeInsets.symmetric(
          vertical: 5, // Adjust for vertical space
          horizontal: 20, // Adjust for horizontal space
        ),
      ), // Padding to make space for the text
      elevation: WidgetStateProperty.resolveWith<double?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return 10;
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
      onPressed: () {},
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16, // Larger text size for better readability
          color: textColor, // Use dynamic text color
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

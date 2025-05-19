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
  // Track currently selected sort
  String _selectedCategory = 'Most Viewed'; // Default category

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
                const Text('Gastropub',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  )),

                const SizedBox(height: 20),

                SizedBox(
                  height: 320,
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
                  height: 320,
                  child: RestaurantsCard(selectedCategory: _selectedCategory,),
                ),
              ],
            ),
          ),
        ),
        /**
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
         **/
      ),
    );
  }

<<<<<<< Updated upstream
 Widget buildCategoryButton(String label, Color bgColor, Color textColor) {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(bgColor),
      padding: WidgetStateProperty.all<EdgeInsets>(
        EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
      ),
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
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
=======
  Future<void> _searchMenu(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResult = '';
      });

      return;
    } else {
      _searchKeyword = keyword;
    }

    QuerySnapshot gastropubsSnapshot = await FirebaseFirestore.instance
        .collection('gastropubs')
        .where('name', isGreaterThanOrEqualTo: keyword)
        .where('name', isLessThanOrEqualTo: '${keyword}\uf8ff')
        .get();

    QuerySnapshot restaurantsSnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('name', isGreaterThanOrEqualTo: keyword)
        .where('name', isLessThanOrEqualTo: '${keyword}\uf8ff')
        .get();

    setState(() {
      _searchResult = keyword;
    });
  }


  Future<void> fetchUserData() async {
    String? role = await fetchRole();

    if (role == 'admin'){
      userData = await getUserByID('users');

      setState(() {
        firstName = userData?['first_name'] ?? '';
        lastName = userData?['last_name'] ?? '';
        shopName = userData?['shop_name'] ?? '';
        isAdmin = true;
        isSeller = false;
      });
    } else if (role == 'seller'){

      userData = await getSellerByID('gastropubs');
      if (userData == null) {
        userData = await getSellerByID('restaurants');
        storeType = 'restaurants';
      }else{
        storeType = 'gastropubs';
      }

      if (userData != null) {
        setState(() {
          firstName = userData?['first_name'] ?? '';
          lastName = userData?['last_name'] ?? '';
          shopName = userData?['shop_name'] ?? '';
          points = userData?['points'] ?? 0;
        });
      } else {
        setState(() {
          firstName = '';
          lastName = '';
          shopName = '';
          points = 0;

          return;
        });
      }
      isAdmin = false;
      isSeller = true;
    } else {
      userData = await getUserByID('users');

      setState(() {
        firstName = userData?['first_name'] ?? '';
        lastName = userData?['last_name'] ?? '';
        points = userData?['points'] ?? 0;
        isAdmin = false;

      });
    }
  }

//helper methods for querying Firestore
  Future<Map<String, dynamic>?> getGastropubInfoByID() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('gastropubs')
          .doc(userID)
          .get();

      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching gastropub data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRestaurantInfoByID() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(userID)
          .get();

      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching restaurant data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSellerByID(String collect) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(collect)
          .doc(userID)
          .get();

      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;

    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByID(String collect) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(collect)
          .doc(userID)
          .get();

      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;

    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }


  Future<String> fetchRole() async {
    try {
      if (userID!.isEmpty) {
        print('Error: userId is empty.');
        return 'err: invalid_userID';
      }

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data['isAdmin'] == true) {
          return 'admin';
        } else if (data['isSeller'] == true) {
          return 'seller';
        } else {
          return 'regular';
        }
      } else {
        return 'regular';
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return 'err: no_role';
    }
  }

  Future<void> signOut() async {
    bool confirmLogout = await showConfirmationDialog(context, "Logout", "Are you sure you want to logout?");

    if(confirmLogout) {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SigninScreen()));
    }
  }

  Future<bool> showConfirmationDialog(BuildContext context, String title, String content) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), //cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), //confirm
              child: Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false; //return false if dialog is dismissed
>>>>>>> Stashed changes
  }
}

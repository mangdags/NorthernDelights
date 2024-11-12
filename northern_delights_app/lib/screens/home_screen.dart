import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/screens/seller_management_screen.dart';
import 'package:northern_delights_app/screens/signin_screen.dart';
import 'package:northern_delights_app/screens/signup_screen.dart';
import 'package:northern_delights_app/screens/user_management_screen.dart';
import 'package:northern_delights_app/widgets/gastropub_card.dart';
import 'package:northern_delights_app/widgets/restaurant_card.dart';
import 'package:northern_delights_app/widgets/category_button.dart';

import 'menu_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Most Viewed';
  String firstName = '';
  String lastName = '';
  String selectedPage = '';
  String shopName = '';
  String email = '';
  bool isAdmin = true;
  bool isSeller = false;
  Map<String, dynamic>? gastropubData;
  Map<String, dynamic>? restaurantData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

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
          centerTitle: true,
          automaticallyImplyLeading: true,
          backgroundColor: const Color.fromARGB(255, 0, 85, 255),
          elevation: 0.0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Northern',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 35,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Roboto',
                ),
              ),
              Text(
                ' Delights',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montez',
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                CategoryButton(
                  onCategorySelected: _onCategorySelected,
                  selectedCategory: _selectedCategory,
                ),
                const SizedBox(height: 20),
                const Text('Gastropubs',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 20),
                SizedBox(
                  height: 320,
                  child: GastropubCards(selectedCategory: _selectedCategory),
                ),
                SizedBox(height: 5),
                Text('Restaurants',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 10),
                SizedBox(
                  height: 320,
                  child: RestaurantsCard(selectedCategory: _selectedCategory),
                ),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: firstName.isNotEmpty
                    ? Text(
                  'Hi, $firstName $lastName',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                )
                    : Text(''),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Profile'),
                onTap: () {
                  setState(() {
                    selectedPage = 'Profile';
                  });
                },
              ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.supervisor_account),
                  title: const Text('View Users'),
                  onTap: () {
                    setState(() {
                      selectedPage = 'View Users';
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => UserManagementScreen()));
                    });
                  },
                ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text('View Sellers'),
                  onTap: () {
                    setState(() {
                      selectedPage = 'View Sellers';
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SellerManagementScreen()));
                    });
                  },
                ),
              if(isSeller)
                ListTile(
                  leading: Icon(Icons.menu_book),
                  title: Text('Manage Content'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuManagementScreen(email: email,),
                      ),
                    );
                  },
                ),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  setState(() {
                    selectedPage = 'Settings';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      email = user.email!;
      gastropubData = await getGastropubInfoByEmail(email);

      if (gastropubData != null) {
        // Use gastropub data
        setState(() {
          firstName = gastropubData?['first_name'] ?? '';
          lastName = gastropubData?['last_name'] ?? '';
          shopName = gastropubData?['shop_name'] ?? '';
          isSeller = true;
        });
      } else {
        // If not found in gastropubs, search restaurants
        restaurantData = await getRestaurantInfoByEmail(email);
        if (restaurantData != null) {
          setState(() {
            firstName = restaurantData?['first_name'] ?? '';
            lastName = restaurantData?['last_name'] ?? '';
            shopName = restaurantData?['shop_name'] ?? '';
            isSeller = true;
          });
        }
      }
    }
  }

// Helper methods for querying Firestore
  Future<Map<String, dynamic>?> getGastropubInfoByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('gastropubs')
          .where('email_address', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching gastropub data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRestaurantInfoByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('email_address', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching restaurant data: $e");
      return null;
    }
  }
/*
  Future<bool> isUserAdmin(String email) async{
    try{
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc()
          .where('email_address', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty ? snapshot.data['isAdmin'];
    } catch (e){
      print('Error fetching user role: $e');
      return false;
    }
  }
*/
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SigninScreen()));
  }
}

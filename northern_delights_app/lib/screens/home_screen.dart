import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/models/gastropub_doc_data.dart';
import 'package:northern_delights_app/models/restaurant_doc_data.dart';
import 'package:northern_delights_app/models/update_points.dart';
import 'package:northern_delights_app/screens/establishments_map_screen.dart';
import 'package:northern_delights_app/screens/reviews_screen.dart';
import 'package:northern_delights_app/screens/seller_management_screen.dart';
import 'package:northern_delights_app/screens/signin_screen.dart';
import 'package:northern_delights_app/screens/user_management_screen.dart';
import 'package:northern_delights_app/screens/user_profile_screen.dart';
import 'package:northern_delights_app/widgets/gastropub_card.dart';
import 'package:northern_delights_app/widgets/restaurant_card.dart';
import 'package:northern_delights_app/widgets/category_button.dart';
import 'package:northern_delights_app/widgets/restaurant_card_search.dart';
import 'package:northern_delights_app/widgets/sinanglao_empanada_card.dart';

import '../models/update_average_rating.dart';
import '../widgets/gastropub_card_search.dart';
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
  String storeType = '';
  double points = 0;

  bool isAdmin = false;
  bool isSeller = false;
  Map<String, dynamic>? userData;
  TextEditingController _searchController = TextEditingController();
  String _searchResult = '';
  late String _searchKeyword;

  String? userID = FirebaseAuth.instance.currentUser?.uid;
  RestaurantSearch restaurantSearch = RestaurantSearch();
  GastropubSearch gastropubSearch = GastropubSearch();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    updateAllRatings('gastropubs');
    updateAllRatings('restaurants');
    _updatePoints();

  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<void> _updatePoints() async {
    double updatedPoints = await getUserPoints();
    setState(() {
      points = updatedPoints;
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
                'Vigan',
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
                        controller: _searchController,
                        onChanged: _searchMenu,
                        decoration: InputDecoration(
                          hintText: 'Search by name or menu',
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
          _searchResult.isEmpty ? Text('') : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<bool>(
                future: hasRestoResult(_searchKeyword),
                builder: (context, snapshot) {
                  return Offstage(
                    offstage: !(snapshot.hasData && snapshot.data!),
                    child: RestaurantsCardSearch(
                      searchKeyword: _searchKeyword,
                      isRegular: true,
                      isAdmin: false,
                    ),
                  );
                },
              ),

              FutureBuilder<bool>(
                future: hasGastroResult(_searchKeyword),
                builder: (context, snapshot) {
                  return Offstage(
                    offstage: !(snapshot.hasData && snapshot.data!),
                    child: GastropubCardSearch(searchKeyword: _searchKeyword, isRegular: true, isAdmin: false,),
                  );
                },
              )
              ],
          )

          ]
                ),
                const SizedBox(height: 30),
                CategoryButton(
                  onCategorySelected: _onCategorySelected,
                  selectedCategory: _selectedCategory,
                ),
                const SizedBox(height: 20),
                Offstage(
                  offstage: (_selectedCategory == 'Empanada' || _selectedCategory == 'Sinanglao'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gastropubs',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 10),

                      SizedBox(
                        height: 320,
                        child: GastropubCards(isRegular: !isSeller, isAdmin: isAdmin, selectedCategory: _selectedCategory),
                      ),
                    ],
                  )
                ),

                SizedBox(height: 20),
                Offstage(
                  offstage: (_selectedCategory == 'Empanada' || _selectedCategory == 'Sinanglao'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Restaurants',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          )),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 320,
                        child: RestaurantsCard(isRegular: !isSeller, isAdmin: isAdmin, selectedCategory: _selectedCategory),
                      ),
                    ],
                  )
                ),
                Offstage(
                  offstage: (_selectedCategory == 'Most Viewed' || _selectedCategory == 'Latest'),
                  child: SizedBox(
                    height: 320,
                    child: SinanglaoEmpanadaCards(selectedCategory: _selectedCategory, isRegular: !isSeller, isAdmin: isAdmin),
                  ),
                )
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    firstName.isNotEmpty
                        ? Text(
                      'Hi, $firstName $lastName',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    )
                        : Text('Unknown User'),
                    const SizedBox(height: 10),

                    Text(
                      'Points: ${points.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),


                  ],
                )
              ),
              if(!isSeller)
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Profile'),
                  onTap: () {
                    setState(() {
                      selectedPage = 'Profile';
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UserProfileScreen(userId: userID!,)),
                      );

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
                        builder: (context) => MenuManagementScreen(userId: userID!,),
                      ),
                    );
                  },
                ),
              if(isSeller)
                ListTile(
                  leading: Icon(Icons.reviews),
                  title: Text('Reviews'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewsScreen(userId: userID!, storeType: storeType,),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Map'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EstablishmentsMap(),
                    ),
                  );
                },
              ),
              /*
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  setState(() {
                    selectedPage = 'Settings';
                  });
                },
              ),
              */
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
        onDrawerChanged: (drawerOpen) {
          if (drawerOpen) {
            setState(() {
              _updatePoints();
              fetchUserData();
            });
          }
        },

      ),
    );
  }

  Future<void> _searchMenu(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResult = '';
      });

      return;
    } else {
      _searchKeyword = keyword;
    }

    // Query both gastropubs and restaurants collections
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

// Helper methods for querying Firestore
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
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed
  }
}

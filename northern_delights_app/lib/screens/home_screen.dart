import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/screens/seller_management_screen.dart';
import 'package:northern_delights_app/screens/signin_screen.dart';
import 'package:northern_delights_app/screens/signup_screen.dart';
import 'package:northern_delights_app/screens/user_management_screen.dart';
import 'package:northern_delights_app/screens/user_profile_screen.dart';
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
  bool isAdmin = false;
  bool isSeller = false;
  Map<String, dynamic>? userData;
  String userID = '';
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  late String _searchKeyword;

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
    // Filter the results based on the keyword
    final filteredResults = _searchResults.where((doc) {
      final name = doc['name']?.toLowerCase() ?? '';
      final location = doc['location']?.toLowerCase() ?? '';
      final keyword = _searchKeyword.toLowerCase();  // Hold search keyword

      return name.contains(keyword) || location.contains(keyword);
    }).toList();

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
                        controller: _searchController,
                        onChanged: _searchMenu,
                        decoration: InputDecoration(
                          hintText: 'Search by name or location',
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
          _searchResults.isEmpty
              ? Text('')
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_searchResults.any((doc) => doc.reference.parent.id == 'gastropubs')) ...[
                Text(
                  'Gastropubs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                for (var doc in _searchResults.where((doc) => doc.reference.parent.id == 'gastropubs'))
                  //GastropubCards(data: doc.data() as Map<String, dynamic>, selectedCategory: ''),
                const SizedBox(height: 20),
              ],
    if (_searchResults.any((doc) => doc.reference.parent.id == 'restaurants')) ...[
      Text(
        'Restaurants',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
                    // Show the filtered results
          if (filteredResults.isNotEmpty) ...[
          for (var doc in filteredResults.where((doc) => doc.reference.parent.id == 'restaurants'))
          RestaurantsCard(data: doc.data() as Map<String, dynamic>, selectedCategory: ''),
          ] else ...[
        Center(child: Text('No restaurants found for this keyword')),
      ],
    ]

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
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserProfileScreen(userId: userID,))
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
                        builder: (context) => MenuManagementScreen(email: email,),
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
      ),
    );
  }

  Future<void> _searchMenu(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResults.clear();
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
      _searchResults = [...gastropubsSnapshot.docs, ...restaurantsSnapshot.docs];
    });
  }


  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userID = user.uid;
      email = user.email!;
      if (await fetchRole(email) == 'admin'){
        userData = await getUserByEmail(email, 'users');

        setState(() {
          firstName = userData?['first_name'] ?? '';
          lastName = userData?['last_name'] ?? '';
          shopName = userData?['shop_name'] ?? '';
          isAdmin = true;
          isSeller = false;
        });
      } else if (await fetchRole(email) == 'seller'){
        userData = await getSellerByEmail(email, 'gastropubs');
        userData ??= await getSellerByEmail(email, 'restaurants');

        if (userData != null) {
          // Update UI with the fetched data
          setState(() {
            firstName = userData?['first_name'] ?? '';
            lastName = userData?['last_name'] ?? '';
            shopName = userData?['shop_name'] ?? '';
            isSeller = true;
            isAdmin = false;
          });
        } else {
          // Handle case where no user data was found
          setState(() {
            firstName = '';
            lastName = '';
            shopName = '';
            isSeller = false;
            isAdmin = false;
          });
        }
      } else {
        userData = await getUserByEmail(email, 'users');

        setState(() {
          firstName = userData?['first_name'] ?? '';
          lastName = userData?['last_name'] ?? '';
          isAdmin = false;
        });
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

  Future<Map<String, dynamic>?> getSellerByEmail(String email, String collect) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collect)
          .where('email_address', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email, String collect) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collect)
          .where('email_address', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }


  Future<String> fetchRole(String email) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email_address', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        if (data['isAdmin'] == true) {
          return 'admin';
        } else if (data['isSeller'] == true) {
          return 'seller';
        } else {
          return 'regular';
        }
      }
      return 'no_role';
    } catch (e) {
      print('Error fetching user role: $e');
      return 'no_role';
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SigninScreen()));
  }
}

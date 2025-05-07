import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:northern_delights_app/models/menu_doc_data.dart';

class MenuDetails extends StatefulWidget {
  const MenuDetails({
    required this.foodPlaceID,
    required this.foodPlaceCategory,
    super.key,
  });

  final String foodPlaceID;
  final String foodPlaceCategory;

  @override
  State<MenuDetails> createState() => _MenuDetailsState();
}

class _MenuDetailsState extends State<MenuDetails> {
  final MenuDocData _menuDocData = MenuDocData();
  final value = new NumberFormat("#,##0.00", "en_US");

  Future<List<Map<String, dynamic>>>? initialMenuData;
  Future<List<Map<String, dynamic>>>? initialSideData;

  @override
  void initState() {
    super.initState();
    initialMenuData = fetchInitialMenuData();
    initialSideData = fetchInitialSideData();
  }

  Future<List<Map<String, dynamic>>> fetchInitialMenuData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(widget.foodPlaceCategory)
        .doc(widget.foodPlaceID)
        .collection('menu')
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> fetchInitialSideData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(widget.foodPlaceCategory)
        .doc(widget.foodPlaceID)
        .collection('sidedish')
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            FutureBuilder<List<Map<String, dynamic>>>(
              future: initialMenuData,
              builder: (context, snapshot) {

                if (!snapshot.hasData) {

                  return Center(child: CircularProgressIndicator());
                }
                var initialMenuList = snapshot.data!;

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _menuDocData.fetchMenuData(widget.foodPlaceID, widget.foodPlaceCategory),
                  builder: (context, streamSnapshot) {
                    var menuList = streamSnapshot.hasData
                        ? streamSnapshot.data!
                        : initialMenuList;

                    return Column(
                      children: [
                        Offstage(
                          offstage: initialMenuList.isEmpty,
                          child: Column(
                            children: [
                            const SizedBox(height: 15,),
                            const Text('Main Dish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                            const SizedBox(height: 5,),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: menuList.map((menu) {
                              return IntrinsicHeight(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                                  ),
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    top: 15,
                                    right: 10,
                                    bottom: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: Colors.blue.shade50,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        offset: Offset(0.0, 4),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon and Title Column
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Food Icon
                                              Icon(
                                                Icons.fastfood_rounded,
                                                color: Colors.yellow.shade800,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 5),
                                              // Title Text
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.5,
                                                child: Text(
                                                  menu['name'] ?? 'No name',
                                                  textAlign: TextAlign.start,
                                                  softWrap: true,
                                                  overflow: TextOverflow.visible,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Peso symbol aligned with icon
                                              FaIcon(FontAwesomeIcons.pesoSign,
                                                color: Colors.yellow.shade800,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              // Price Text
                                              Text(
                                                menu['price'].toStringAsFixed(2),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                softWrap: true,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),

                                          Text('*Prices may vary',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            softWrap: true,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.redAccent,
                                            ),
                                          ),

                                          const SizedBox(height: 10,),
                                          const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),),
                                          const SizedBox(height: 5,),

                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: (MediaQuery.of(context).size.width * 0.78) -90,
                                              maxHeight: 150, // set a reasonable max height for scrolling
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: Text(
                                                  menu['description'] ?? 'No description',
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Spacer(), // Pushes the image to the far right
                                      // Image
                                      menu['photo'] != null && menu['photo'].toString().isNotEmpty
                                          ? CachedNetworkImage(imageUrl: menu['photo'],
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        width: 100,
                                        height: 100,
                                        errorWidget: (context, url, error) {
                                          return Container(
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.error,
                                              size: 50,
                                              color: Colors.red,
                                            ),
                                          );
                                        },
                                      ) : Image.asset('assets/images/meal-menu.png', fit: BoxFit.contain, width: 60, height: 60,),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );


                  },
                );
              },
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: initialSideData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var initialSideList = snapshot.data!;

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _menuDocData.fetchSideData(widget.foodPlaceID, widget.foodPlaceCategory),
                  builder: (context, streamSnapshot) {
                    var sideList = streamSnapshot.hasData
                        ? streamSnapshot.data!
                        : initialSideList;

                    return Column(
                      children: [
                        Offstage(
                          offstage: initialSideList.isEmpty,
                          child: Column(
                            children: [
                              const SizedBox(height: 15,),
                              const Text('Side Dish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                              const SizedBox(height: 5,),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: sideList.map((menu) {
                              return IntrinsicHeight(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                                  ),
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    top: 15,
                                    right: 10,
                                    bottom: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: Colors.blue.shade50,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        offset: Offset(0.0, 4),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon and Title Column
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Food Icon
                                              Icon(
                                                Icons.fastfood_rounded,
                                                color: Colors.yellow.shade800,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 5),
                                              // Title Text
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.5,
                                                child: Text(
                                                  menu['name'] ?? 'No name',
                                                  textAlign: TextAlign.start,
                                                  softWrap: true,
                                                  overflow: TextOverflow.visible,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Peso symbol aligned with icon
                                              FaIcon(FontAwesomeIcons.pesoSign,
                                                color: Colors.yellow.shade800,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              // Price Text
                                              Text(
                                                menu['price'].toStringAsFixed(2),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                softWrap: true,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),

                                          Text('*Prices may vary',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            softWrap: true,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.redAccent,
                                            ),
                                          ),

                                          const SizedBox(height: 10,),
                                          const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),),
                                          const SizedBox(height: 5,),

                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: (MediaQuery.of(context).size.width * 0.78) -90,
                                              maxHeight: 150, // set a reasonable max height for scrolling
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: Text(
                                                  menu['description'] ?? 'No description',
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Spacer(), // Pushes the image to the far right
                                      // Image
                                      menu['photo'] != null && menu['photo'].toString().isNotEmpty
                                          ? CachedNetworkImage(imageUrl: menu['photo'],
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        width: 100,
                                        height: 100,
                                        errorWidget: (context, url, error) {
                                          return Container(
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.error,
                                              size: 50,
                                              color: Colors.red,
                                            ),
                                          );
                                        },
                                      ) : Image.asset('assets/images/meal-menu.png', fit: BoxFit.contain, width: 60, height: 60,),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final utc8Date = date.add(Duration(hours: 8));
    return DateFormat('yyyy-MM-dd hh:mm a').format(utc8Date);
  }
}


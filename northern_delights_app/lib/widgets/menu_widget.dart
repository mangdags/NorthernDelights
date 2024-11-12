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

  @override
  void initState() {
    super.initState();
    initialMenuData = fetchInitialMenuData();
  }

  Future<List<Map<String, dynamic>>> fetchInitialMenuData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(widget.foodPlaceCategory)
        .doc(widget.foodPlaceID)
        .collection('menu')
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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

            return SingleChildScrollView(
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
                                      menu['title'] ?? 'No title',
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
                              // Price Row (aligns the peso symbol vertically with the icon)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Peso symbol aligned with icon
                                  FaIcon(FontAwesomeIcons.pesoSign, // Assuming this icon represents the peso
                                    color: Colors.yellow.shade800,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  // Price Text
                                  Text(
                                    value.format(int.parse((menu['price'].toString()))),
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
                            ],
                          ),
                          const Spacer(), // Pushes the image to the far right
                          // Image
                          Image.network(
                            menu['photo'],
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.error,
                                  size: 50,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );


          },
        );
      },
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final utc8Date = date.add(Duration(hours: 8));
    return DateFormat('yyyy-MM-dd hh:mm a').format(utc8Date);
  }
}


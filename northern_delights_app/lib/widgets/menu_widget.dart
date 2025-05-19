import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true; // If more data is available
  List<QueryDocumentSnapshot> menu = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMenu(); // Initial fetch
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && hasMore) {
        fetchMenu();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchMenu() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection(widget.foodPlaceCategory)
        .doc(widget.foodPlaceID)
        .collection('menu')
        .limit(50); // Set limit for pagination

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
      setState(() {
        menu.addAll(snapshot.docs);
      });
    } else {
      hasMore = false;
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    return ListView.builder(
      controller: _scrollController,
      itemCount: menu.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == menu.length) {
          return Center(child: CircularProgressIndicator());
        }
        var menuData = menu[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text('${menuData['title']}'),
          subtitle: Text('Price: ${menuData['price']}'),
        );
      },
=======
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
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.fastfood_rounded,
                                                color: Colors.yellow.shade800,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 5),
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
                                              FaIcon(FontAwesomeIcons.pesoSign,
                                                color: Colors.yellow.shade800,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
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
                                              maxHeight: 150,
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

                                      const Spacer(),
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
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.fastfood_rounded,
                                                color: Colors.yellow.shade800,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 5),
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
                                              FaIcon(FontAwesomeIcons.pesoSign,
                                                color: Colors.yellow.shade800,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
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
                                              maxHeight: 150,
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

                                      const Spacer(),
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

>>>>>>> Stashed changes
    );
  }
}

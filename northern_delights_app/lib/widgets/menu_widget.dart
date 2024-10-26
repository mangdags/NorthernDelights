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
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuManagementScreen extends StatefulWidget {
  final String userId;

  const MenuManagementScreen({required this.userId, super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<Map<String, dynamic>> menuItems = [];
  String? collectionType;

  @override
  void initState() {
    super.initState();
    _fetchMenuData();
  }

  Future<void> _fetchMenuData() async {
    final gastropubData = await _getCollectionData('gastropubs');
    final restaurantData = await _getCollectionData('restaurants');

    if (gastropubData != null) {
      setState(() {
        collectionType = 'gastropubs';
        menuItems = gastropubData;
      });
    } else {
      if (restaurantData != null) {
        setState(() {
          collectionType = 'restaurants';
          menuItems = restaurantData;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>?> _getCollectionData(String collection) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection).doc(widget.userId)
          .get();

      if (snapshot.exists) {
        final docId = snapshot.id;
        final menuSnapshot = await FirebaseFirestore.instance
            .collection(collection)
            .doc(docId)
            .collection('menu')
            .get();

        // Include 'id' in each menu item for future reference
        return menuSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Add the document ID
          return data;
        }).toList();
      }
    } catch (e) {
      print('Error fetching $collection data: $e');
    }
    return null;
  }


  Future<void> _addMenuItem(String name, double price) async {
    if (collectionType == null) return;

    final collectionRef = FirebaseFirestore.instance.collection(collectionType!);
    final docRef = await collectionRef.doc(widget.userId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final docId = docSnapshot.id;
      final menuCollectionRef = collectionRef.doc(docId).collection('menu');
      await menuCollectionRef.add({'name': name, 'price': price});

      _fetchMenuData(); // Refresh menu data
    }
  }

  Future<void> _updateMenuItem(String itemId, String name, double price) async {
    if (collectionType == null) return;

    final collectionRef = FirebaseFirestore.instance.collection(collectionType!);
    final docRef = await collectionRef.doc(widget.userId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final docId = docSnapshot.id;
      final menuItemRef = collectionRef.doc(docId).collection('menu').doc(itemId);
      await menuItemRef.update({'name': name, 'price': price});

      _fetchMenuData();
    }
  }

  Future<void> _deleteMenuItem(String itemId) async {
    if (collectionType == null) return;

    final collectionRef = FirebaseFirestore.instance.collection(collectionType!);
    final docRef = await collectionRef.doc(widget.userId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final docId = docSnapshot.id;
      final menuItemRef = collectionRef.doc(docId).collection('menu').doc(itemId);
      await menuItemRef.delete();

      _fetchMenuData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Menu")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final menuItem = menuItems[index];
                return ListTile(
                  title: Text(menuItem['name'] ?? 'No Name'),
                  subtitle: Text("Price: Php${menuItem['price'] ?? 0.0}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          print('Menu Item: $menuItem');
                          _showEditDialog(menuItem);
                          },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteMenuItem(menuItem['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAddDialog(),
            child: const Text("Add Menu Item"),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    String name = '';
    double price = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Menu Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                onChanged: (value) => price = double.tryParse(value) ?? 0.0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _addMenuItem(name, price);
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> menuItem) {
    String name = menuItem['name'] ?? 'No Item Name';
    double price = menuItem['price'] ?? 0.00;

    print('EDIT: $menuItem, $menuItem\[\'name\'\]');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Menu Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (value) => name = value,
                controller: TextEditingController(text: name),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                onChanged: (value) => price = double.tryParse(value) ?? price,
                controller: TextEditingController(text: price.toString()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateMenuItem(menuItem['id'], name, price);
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}

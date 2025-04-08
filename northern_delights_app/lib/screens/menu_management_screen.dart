import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/gastropub_doc_data.dart';
import '../models/restaurant_doc_data.dart';

class MenuManagementScreen extends StatefulWidget {
  final String userId;

  const MenuManagementScreen({required this.userId, super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> menuItems = [];
  String? collectionType;
  String? _imageName;
  String? _storeName;

  File? _selectedImage;
  String? _imageURL;
  bool isUploading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchMenuData();
    _initializeShop();
  }

  Future<void> _fetchMenuData() async {
    final gastropubData = await _getCollectionData('gastropubs');
    final restaurantData = await _getCollectionData('restaurants');

    if(gastropubData != null && restaurantData != null) {
      setState(() {
        collectionType = 'both';
        menuItems = [...gastropubData, ...restaurantData];
      });
    } else if (restaurantData == null && gastropubData != null) {
      setState(() {
        collectionType = 'gastropubs';
        menuItems = gastropubData;
      });
    } else if (restaurantData != null && gastropubData == null) {
      setState(() {
        collectionType = 'restaurants';
        menuItems = restaurantData;
      });
    }
  }

  Future<void> _initializeShop() async{
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionType!).doc(widget.userId)
          .get();

      if (snapshot.exists) {
        _storeName = snapshot.data()?['name'];
      }
    } catch (e) {
      print('Error initializing $collectionType! data: $e');
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

        _storeName = snapshot.data()?['name'];

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
    if (_selectedImage != null) {
      final fileSize = await _selectedImage?.length();
      if(fileSize! > 3000000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size exceeds 3MB')),
        );
        return;
      }
      if(collectionType == 'gastropubs')
      {
        await _addMenuOnCollection(FirebaseFirestore.instance.collection('gastropubs'), name, price);

      } else if(collectionType == 'restaurants') {

        await _addMenuOnCollection(FirebaseFirestore.instance.collection('restaurants'), name, price);

      } else {
        await _addMenuOnCollection(FirebaseFirestore.instance.collection('gastropubs'), name, price);
        await _addMenuOnCollection(FirebaseFirestore.instance.collection('restaurants'), name, price);
      }

    }
  }

  Future<void> _addMenuOnCollection(CollectionReference<Map<String, dynamic>> collectionRef, String name, double price) async
  {
    if(collectionType == 'both')
    {
      //resto
      final restoCollectionRef = FirebaseFirestore.instance.collection('restaurants');
      final restoDocRef = await restoCollectionRef.doc(widget.userId);
      final restoDocSnapshot = await restoDocRef.get();

      if (restoDocSnapshot.exists) {
        final restoDocId = restoDocSnapshot.id;
        final restoMenuCollectionRef = restoCollectionRef.doc(restoDocId).collection('menu');

        // Add item and get its document reference
        final restoNewMenuItemRef = await restoMenuCollectionRef.add({'name': name, 'price': price, 'photo': ''});
        final restoMenuItemId = restoNewMenuItemRef.id;

        await _uploadImage(restoMenuItemId);
      }

        //gastro
        final gastroCollectionRef = FirebaseFirestore.instance.collection('gastropubs');
        final gastroDocRef = await gastroCollectionRef.doc(widget.userId);
        final gastroDocSnapshot = await gastroDocRef.get();

        if (gastroDocSnapshot.exists) {
          final gastroDocId = gastroDocSnapshot.id;
          final gastroMenuCollectionRef = gastroCollectionRef.doc(gastroDocId).collection('menu');

          // Add item and get its document reference
          final gastroNewMenuItemRef = await gastroMenuCollectionRef.add({'name': name, 'price': price, 'photo': ''});
          final gastroMenuItemId = gastroNewMenuItemRef.id;

          await _uploadImage(gastroMenuItemId);
        }
    } else {
      final docRef = await collectionRef.doc(widget.userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final docId = docSnapshot.id;
        final menuCollectionRef = collectionRef.doc(docId).collection('menu');

        // Add item and get its document reference
        final newMenuItemRef = await menuCollectionRef.add({'name': name, 'price': price, 'photo': ''});
        final menuItemId = newMenuItemRef.id;

        await _uploadImage(menuItemId);
      }
    }


    // Refresh menu items
    _fetchMenuData();

    // Add keywords for searching
    if(collectionType == 'restaurants') {
      updateKeywordsResto(widget.userId, _storeName!, await fetchMenuKeywordsResto(widget.userId));
    } else if(collectionType == 'gastropubs') {
      updateKeywordsGastro(widget.userId, _storeName!, await fetchMenuKeywordsGastro(widget.userId));
    } else {
      updateKeywordsResto(widget.userId, _storeName!, await fetchMenuKeywordsResto(widget.userId));
      updateKeywordsGastro(widget.userId, _storeName!, await fetchMenuKeywordsGastro(widget.userId));
    }
  }


  Future<void> _updateMenuItem(String itemId, String name, double price) async {

    if(collectionType == 'both') {
      //gastro
      final gastroCollectionRef = FirebaseFirestore.instance.collection('gastropubs');
      final gastroDocRef = await gastroCollectionRef.doc(widget.userId);
      final gastroDocSnapshot = await gastroDocRef.get();

      if (gastroDocSnapshot.exists) {
        final docId = gastroDocSnapshot.id;
        final menuItemRef = gastroCollectionRef.doc(docId).collection('menu').doc(itemId);
        await menuItemRef.update({'name': name, 'price': price});

        _fetchMenuData();
      }

      //resto
      final restoCollectionRef = FirebaseFirestore.instance.collection('restaurants');
      final restoDocRef = await restoCollectionRef.doc(widget.userId);
      final restoDocSnapShot = await restoDocRef.get();

      if (restoDocSnapShot.exists) {
        final docId = restoDocSnapShot.id;
        final menuItemRef = restoCollectionRef.doc(docId).collection('menu').doc(itemId);
        await menuItemRef.update({'name': name, 'price': price});

        _fetchMenuData();
      }
    } else {
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
  }

  Future<void> _deleteMenuItem(String itemId) async {
    if (collectionType == null) return;

    final collectionRef = FirebaseFirestore.instance.collection(collectionType!);
    final docRef = await collectionRef.doc(widget.userId);
    final docSnapshot = await docRef.get();

    if(collectionType == 'both') {
      //gastro
      if (docSnapshot.exists) {
        final docId = docSnapshot.id;
        final menuItemRef = collectionRef.doc(docId).collection('menu').doc(itemId);
        await menuItemRef.delete();

        _fetchMenuData();
      }

      //resto
      if (docSnapshot.exists) {
        final docId = docSnapshot.id;
        final menuItemRef = collectionRef.doc(docId).collection('menu').doc(itemId);
        await menuItemRef.delete();

        _fetchMenuData();
      }
    } else {
      if (docSnapshot.exists) {
        final docId = docSnapshot.id;
        final menuItemRef = collectionRef.doc(docId).collection('menu').doc(itemId);
        await menuItemRef.delete();

        _fetchMenuData();
      }
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
    _imageName = '';
    double price = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setStateDialog) {
            return AlertDialog(
              title: const Text("Add Menu Item"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setStateDialog(() {});
                    },
                    child: CircleAvatar(
                      key: ValueKey(_selectedImage?.path),
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_imageURL != null ? NetworkImage(_imageURL!) : null),
                      child: _selectedImage == null && _imageURL == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Name"),
                    onChanged: (value) => _imageName = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Price"),
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
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : (){
                        _addMenuItem(_imageName!, price);
                        Navigator.of(context).pop();
                      },
                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }


  Future<void> _uploadImage(String menuItemId) async {
    print('UPLOADING... $_selectedImage, $_imageName, $_storeName, $collectionType, $menuItemId');
    if (_selectedImage == null || isUploading) return;

    setState(() {
      isUploading = true;
    });


    try {
      print('INSIDE TRY');
      // Upload Image
      if(collectionType == 'both')
      {
        print('COLLECTION TYPE: both');

         final fileName = '$_imageName.png';

         print('FILENAME: $fileName');

         await uploadToGastro(fileName, menuItemId);
         //await uploadToResto(fileName, menuItemId);

      } else {

        print('COLLECTION TYPE: else');
        final fileName = '$_imageName.png';
        final storageRef = _storage.ref().child('$collectionType/menu/$_storeName/$fileName');

        final uploadTask = await storageRef.putFile(_selectedImage!);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        setState(() {
          _imageURL = imageUrl;
        });

        await _firestore
          .collection(collectionType!)
          .doc(widget.userId)
          .collection('menu')
          .doc(menuItemId)
          .update({'photo': _imageURL});

      }


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    } finally{
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> uploadToGastro(String fileName, String menuItemId) async {
    final gastroStorageRef = _storage.ref().child('gastropubs/menu/$_storeName/$fileName');

    final gastroUploadTask = await gastroStorageRef.putFile(_selectedImage!);
    final gastroImageURL = await gastroUploadTask.ref.getDownloadURL();

    // setState(() {
    //   _imageURL = gastroImageURL;
    // });

    await _firestore
        .collection('gastropubs')
        .doc(widget.userId)
        .collection('menu')
        .doc(menuItemId)
        .update({'photo': gastroImageURL});
  }


  void _showEditDialog(Map<String, dynamic> menuItem) {
    _imageName = menuItem['name'] ?? 'No Item Name';
    double price = menuItem['price'] ?? 0.00;

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
                onChanged: (value) => _imageName = value,
                controller: TextEditingController(text: _imageName),
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
                _updateMenuItem(menuItem['id'], _imageName!, price);
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

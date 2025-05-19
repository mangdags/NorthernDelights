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
  List<Map<String, dynamic>> sideItem = [];
  String? collectionType;
  String? _imageName;
  late String _storeName;
  late String _storeType;

  File? _selectedImage;
  String? _imageURL;
  bool isUploading = false;

  final ImagePicker _imagePicker = ImagePicker();


  final TextEditingController _descController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _initializeUser();
    await _initializeShop();
    await _fetchMenuData();
  }

  Future<void> _fetchMenuData() async {
    final gastropubData = await _getCollectionData('gastropubs', false);
    final gastropubSideData = await _getCollectionData('gastropubs', true);

    final restaurantData = await _getCollectionData('restaurants', false);
    final restaurantSideData = await _getCollectionData('restaurants', true);

    if(_storeType == 'gastropubs') {
      setState(() {
        collectionType = 'gastropubs';
        menuItems = gastropubData ?? [];
        sideItem = gastropubSideData ?? [];
      });
    }

    if (_storeType == 'restaurants') {
      setState(() {
        collectionType = 'restaurants';
        menuItems = restaurantData ?? [];
        sideItem = restaurantSideData ?? [];
      });
    } else if (_storeType == 'restaurants') {
      setState(() {
        menuItems = restaurantData ?? [];
      });
    }

  }

  Future<void> _initializeShop() async{
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_storeType)
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        setState(() {
          _storeName = doc['name'];
        });
      }
    } catch (e) {
      print('Error initializing $_storeType! data: $e');
    }
  }

  Future<void> _initializeUser() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users').doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          _storeType = snapshot.data()?['store_type'];
        });
      }
    } catch (e) {
      print('Error initializing user data: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> _getCollectionData(String collection, bool isSideDish) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection).doc(widget.userId)
          .get();

      if (snapshot.exists && !isSideDish) {
        final docId = snapshot.id;
        final menuSnapshot = await FirebaseFirestore.instance
            .collection(collection)
            .doc(docId)
            .collection('menu')
            .get();

        return menuSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      } else if(snapshot.exists && isSideDish) {
        final docId = snapshot.id;
        final menuSnapshot = await FirebaseFirestore.instance
            .collection(collection)
            .doc(docId)
            .collection('sidedish')
            .get();

        return menuSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      }
    } catch (e) {
      print('Error fetching $collection data: $e');
    }
    return null;
  }


  Future<void> _addMainDishItem(String name, double price, String description) async
  {
    if (_selectedImage != null) {
      final fileSize = await _selectedImage?.length();
      if(fileSize! > 3000000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size exceeds 3MB')),
        );
        return;
      }
      if(_storeType == 'gastropubs')
      {
        await _addMenuOnCollection(FirebaseFirestore.instance.collection('gastropubs'), name, price, description, false);

      } else if(_storeType == 'restaurants') {
        await _addMenuOnCollection(FirebaseFirestore.instance.collection('restaurants'), name, price, description, false);
      }

    }
  }

  Future<void> _addSideDishItem(String name, double price, String description) async
  {
    if (_selectedImage != null) {
      final fileSize = await _selectedImage?.length();
      if(fileSize! > 3000000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size exceeds 3MB')),
        );
        return;
      }
      if(_storeType == 'gastropubs')
      {
        await _addMenuOnCollection(FirebaseFirestore.instance.collection('gastropubs'), name, price, description, true);

      } else if(_storeType == 'restaurants') {
        await _addMenuOnCollection(FirebaseFirestore.instance.collection('restaurants'), name, price, description, true);
      }

    }
  }

  Future<void> _addMenuOnCollection(CollectionReference<Map<String, dynamic>> collectionRef, String name, double price, String description, bool isSideDish) async
  {
    final docRef = await collectionRef.doc(widget.userId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final docId = docSnapshot.id;
      final menuCollectionRef = collectionRef.doc(docId).collection('menu');
      final sideDishCollectionRef = collectionRef.doc(docId).collection('sidedish');

      //add item and get its document reference
      final newMenuItemRef = isSideDish ?  await sideDishCollectionRef.add({'name': name, 'price': price, 'photo': '', 'description': description})
      : await menuCollectionRef.add({'name': name, 'price': price, 'photo': '', 'description': description});
      final menuItemId = newMenuItemRef.id;

      await _uploadImage(menuItemId, isSideDish);

      print('ADD: $isSideDish, $sideDishCollectionRef');
    }
    //refresh menu items

    _fetchMenuData();

    //add keywords for searching
    if(_storeType == 'restaurants') {
      updateKeywordsResto(widget.userId, _storeName, await fetchMenuKeywordsResto(widget.userId));
    } else if(_storeType == 'gastropubs') {
      updateKeywordsGastro(widget.userId, _storeName, await fetchMenuKeywordsGastro(widget.userId));
    }
  }


  Future<void> _updateMenuItem(String itemId, String name, double price, String description) async
  {
    final collectionRef = FirebaseFirestore.instance.collection(_storeType);
    final docRef = await collectionRef.doc(widget.userId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final docId = docSnapshot.id;
      final menuItemRef = collectionRef.doc(docId).collection('menu').doc(itemId);
      await menuItemRef.update({'name': name, 'price': price, 'description': description});

      _fetchMenuData();
    }
  }

  Future<void> _deleteMenuItem(String itemId) async {
    final collectionRef = FirebaseFirestore.instance.collection(_storeType);
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Main Dish', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), //prevent conflict with parent scroll
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
                        onPressed: () => _showEditDialog(menuItem),
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Side Dish', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sideItem.length,
              itemBuilder: (context, index) {
                final menuItem = sideItem[index];
                return ListTile(
                  title: Text(menuItem['name'] ?? 'No Name'),
                  subtitle: Text("Price: Php${menuItem['price'] ?? 0.0}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(menuItem),
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
            SizedBox(height: 100), // extra padding so FAB doesn’t overlap last item
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              _showAddMainDishDialog();
            },
            icon: Icon(Icons.add),
            label: Text('Main Dish'),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            onPressed: () {
              _showAddSideDishDialog();
            },
            icon: Icon(Icons.add),
            label: Text('Side Dish'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddMainDishDialog() {
    _imageName = '';
    double price = 0.0;
    String description = '';

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
                      radius: 25,
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

                  Container(
                    height: 150,
                    padding: EdgeInsets.all(8),
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: TextField(
                          controller: _descController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 5,
                          onChanged: (value) => description = value,
                          decoration: InputDecoration(
                            labelText: "Description",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  )

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
                        if(_imageName == null) {
                          print('NO IMAGE');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please add image first!')),
                          );
                        } else {
                          _addMainDishItem(_imageName!, price, description);
                          Navigator.of(context).pop();
                        }


                      },
                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Main Dish'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showAddSideDishDialog() {
    _imageName = '';
    double price = 0.0;
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setStateDialog) {
            return AlertDialog(
              title: const Text("Add Side Dish"),
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
                      radius: 25,
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

                  Container(
                    height: 150,
                    padding: EdgeInsets.all(8),
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: TextField(
                          controller: _descController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 5,
                          onChanged: (value) => description = value,
                          decoration: InputDecoration(
                            labelText: "Description",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  )

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
                        if(_imageName == null) {
                          print('NO IMAGE');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please add image first!')),
                          );
                        } else {
                          _addSideDishItem(_imageName!, price, description);
                          Navigator.of(context).pop();
                        }
                  },
                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Side Dish'),
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


  Future<void> _uploadImage(String menuItemId, bool isSideDish) async {
    if (_selectedImage == null || isUploading) return;

    setState(() {
      isUploading = true;
    });


    try {
      final fileName = '$_imageName.png';
      final storageRef = _storage.ref().child('$_storeType/menu/$_storeName/$fileName');
      final sideDishRef = _storage.ref().child('$_storeType/sidedish/$_storeName/$fileName');

      final uploadTask = isSideDish ? await sideDishRef.putFile(_selectedImage!) : await storageRef.putFile(_selectedImage!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        _imageURL = imageUrl;
      });

      isSideDish ?
        await _firestore
          .collection(_storeType)
          .doc(widget.userId)
          .collection('sidedish')
          .doc(menuItemId)
          .update({'photo': _imageURL})
      : await _firestore
        .collection(_storeType)
        .doc(widget.userId)
        .collection('menu')
        .doc(menuItemId)
        .update({'photo': _imageURL});

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


  void _showEditDialog(Map<String, dynamic> menuItem) {
    _imageName = menuItem['name'] ?? 'No Item Name';
    double price = menuItem['price'] ?? 0.00;
    String description = menuItem['description'] ?? '';

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

              Container(
                height: 150,
                padding: EdgeInsets.all(8),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: TextField(
                      controller: _descController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 5,
                      onChanged: (value) => description = value,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              )
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
                _updateMenuItem(menuItem['id'], _imageName!, price, description);
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

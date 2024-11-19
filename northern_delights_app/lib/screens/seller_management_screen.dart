import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellerManagementScreen extends StatefulWidget {
  const SellerManagementScreen({Key? key}) : super(key: key);

  @override
  State<SellerManagementScreen> createState() => _SellerManagementScreenState();
}

class _SellerManagementScreenState extends State<SellerManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String storeType;

  Stream<QuerySnapshot> _getSellersStream() {
    return _firestore.collection('users').where('isSeller', isEqualTo: true).snapshots();
  }

  // Update seller information
  Future<void> _editSeller(String sellerId, String firstName, String lastName, String shopName, String emailAddress) async {
    await _firestore.collection('users').doc(sellerId).update({
      'first_name': firstName,
      'last_name': lastName,
      'shop_name': shopName,
      'email_address': emailAddress,
    });

    _editStore(sellerId, firstName, lastName, shopName, emailAddress, storeType);
  }

  // Update seller information under gastro/resto
  Future<void> _editStore(String sellerId, String firstName, String lastName, String shopName, String emailAddress, String storeType) async {
    await _firestore.collection(storeType).doc(sellerId).update({
      'first_name': firstName,
      'last_name': lastName,
      'name': shopName,
      'email_address': emailAddress,
    });
  }

  // Delete a seller from Firestore
  Future<void> _deleteSeller(String sellerId) async {
    await _firestore.collection('users').doc(sellerId).delete();
  }

  // Edit seller information
  void _showEditSellerDialog(String sellerId, String firstName, String lastName, String shopName, String emailAddress) {
    final TextEditingController firstNameController = TextEditingController(text: firstName);
    final TextEditingController lastNameController = TextEditingController(text: lastName);
    final TextEditingController shopNameController = TextEditingController(text: shopName);
    final TextEditingController emailAddressController = TextEditingController(text: emailAddress);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Seller'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopNameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
              ),
              TextField(
                controller: emailAddressController,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _editSeller(
                    sellerId,
                    firstNameController.text,
                    lastNameController.text,
                    shopNameController.text,
                    emailAddressController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getSellersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sellers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index];
              final sellerId = seller.id;
              final shopName = seller['shop_name'] ?? '';
              final firstName = seller['first_name'] ?? '';
              final lastName = seller['last_name'] ?? '';
              final emailAddress = seller['email_address'] ?? '';
              storeType = seller['store_type'];

              return ListTile(
                leading: Icon(Icons.store),
                title: Text('$shopName'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditSellerDialog(
                          sellerId,
                          firstName,
                          lastName,
                          shopName,
                          emailAddress,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Delete User'),
                          content: const Text('Are you sure you want to delete the user?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteSeller(sellerId);
                                Navigator.pop(context, 'Yes');
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete User'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Would you like to delete the seller?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:northern_delights_app/screens/menu_management_screen.dart';
import 'package:northern_delights_app/screens/new_seller.dart';
import 'package:northern_delights_app/screens/signup_screen.dart';
import 'package:northern_delights_app/screens/user_profile_screen.dart';

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

  Future<void> _editSeller(String sellerId, String firstName, String lastName, String shopName, String emailAddress) async {
    await _firestore.collection('users').doc(sellerId).update({
      'first_name': firstName,
      'last_name': lastName,
      'shop_name': shopName,
      'email_address': emailAddress,
    });

    await _editStore(sellerId, firstName, lastName, shopName, emailAddress, storeType);
  }

  Future<void> _editStore(String sellerId, String firstName, String lastName, String shopName, String emailAddress, String storeType) async {
    await _firestore.collection(storeType).doc(sellerId).update({
      'first_name': firstName,
      'last_name': lastName,
      'name': shopName,
      'email_address': emailAddress,
    });
  }

  Future<void> _deleteSeller(String sellerId) async {
    bool confirmDeleteSeller = await showConfirmationDialog(context, "Delete Seller", "Are you sure you want to delete the seller?");
    if(confirmDeleteSeller) {
      await _firestore.collection('users').doc(sellerId).delete();
      await _firestore.collection('restaurants').doc(sellerId).delete();
      await _firestore.collection('gastropubs').doc(sellerId).delete();
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
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false; //return false if dialog is dismissed
  }

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
          content: SingleChildScrollView(
            child: Column(
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
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No sellers found.'));
          }

          final sellers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (BuildContext context, int index) {
              final seller = sellers[index];
              final sellerId = seller.id;
              final firstName = seller['first_name'] ?? '';
              final lastName = seller['last_name'] ?? '';
              final shopName = seller['shop_name'] ?? '';
              final emailAddress = seller['email_address'] ?? '';

              return ListTile(
                title: Text(shopName),
                subtitle: Text(emailAddress),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MenuManagementScreen(userId: sellerId),));

                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => UserProfileScreen(userId: sellerId,))
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteSeller(sellerId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewSellerScreen( isSeller: true)),
          );
        },
        child: const Icon(Icons.add),
      ),

    );
  }
}

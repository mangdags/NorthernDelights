import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:northern_delights_app/models/gastropub_doc_data.dart';
import 'package:northern_delights_app/models/restaurant_doc_data.dart';
import 'package:northern_delights_app/screens/home_screen.dart';
import 'package:northern_delights_app/screens/pin_location_screen.dart';
import 'package:northern_delights_app/screens/seller_management_screen.dart';
import 'package:northern_delights_app/screens/signin_screen.dart';

class NewSellerScreen extends StatefulWidget {
  const NewSellerScreen({super.key, required this.isSeller});

  final bool isSeller;

  @override
  State<NewSellerScreen> createState() => _NewSellerScreenState();
}

class _NewSellerScreenState extends State<NewSellerScreen> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();

  String? firstName;
  String? lastName;
  String? _email;
  String _selectedType = 'Empanadaan';
  String? shop_name;
  final String _image_url = '';

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vigan',
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 35,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Roboto'
                    ),
                  ),
                  Text(
                    ' Delights',
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montez'
                    ),
                  ),
                ],
              ),
                const SizedBox(height: 50),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _firstNameController,
                    textAlign: TextAlign.center,
                    onChanged: (value){
                      firstName = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _lastNameController,
                    textAlign: TextAlign.center,
                    onChanged: (value){
                      lastName = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                if (widget.isSeller) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextField(
                      controller: _shopNameController,
                      textAlign: TextAlign.center,
                      onChanged: (value){
                        shop_name = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Shop Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                //if(!widget.isSeller) ...[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      onChanged: (value){
                        _email = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                const SizedBox(height: 20),
                const SizedBox(height: 15,),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RadioListTile<String>(
                        title: Text('Gastropubs', style: TextStyle(fontSize: 16),),
                        value: 'gastropubs',
                        groupValue: _selectedType,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: Text('Restaurants', style: TextStyle(fontSize: 16),),
                        value: 'restaurants',
                        groupValue: _selectedType,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () async {
                    try{
                        signUpWithEmailPassword(
                            isAdmin: false,
                            firstName: _firstNameController.text.trim(),
                            lastName: _lastNameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: '123456',
                            isSeller: widget.isSeller,
                            imageURL: _image_url,
                            isDualStore: _selectedType == 'both' ? true : false,
                            shopName: _shopNameController.text.trim());
                        Navigator.of(context).pop();

                    } catch (e){
                      print(e);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(300, 50),
                  ),
                  child: Text('Add Seller'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        )
            ),
      );
  }


  Future<void> signUpWithEmailPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool isAdmin,
    required bool isSeller,
    required bool isDualStore,
    required String shopName,
    required String imageURL,
  }) async {
    try {
      // Create the user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: '123456');
          //.createUserWithEmailAndPassword(email: '${shopName.trim().toLowerCase().replaceAll(' ', '')}@email.com', password: '123456');

      // Get the user ID
      User? user = userCredential.user;

      if (user != null) {
        // Store additional details in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'isAdmin': false,
          'isSeller': isSeller,
          'first_name': firstName,
          'last_name': lastName,
          'email_address': _email,//'${shopName.trim().toLowerCase().replaceAll(' ', '')}@email.com',
          'shop_name' : shopName,
          'store_type' : _selectedType.isNotEmpty ? _selectedType == 'both' ? 'gastropubs' : _selectedType : '',
          'image_url': _image_url,
          'createdAt': FieldValue.serverTimestamp(),
        });


        _createStoreAccount(
              firstName: firstName,
              lastName: lastName,
              email: email, //'${shopName.trim().toLowerCase().replaceAll(' ', '')}@email.com',
              password: '123456',
              isAdmin: isAdmin,
              isSeller: isSeller,
              isDualStore: isDualStore,
              uid: user.uid,
              storeType: _selectedType,
              shopName: shopName);

        //Navigator.push(context, MaterialPageRoute(builder: (context)=> SigninScreen()));
        //await user.updateDisplayName('$firstName $lastName');


        // Add keywords for searching
        if(_selectedType == 'restaurants') {
          updateKeywordsResto(user.uid, _shopNameController.text.trim(), await fetchMenuKeywordsResto(user.uid));
        } else if(_selectedType == 'gastropubs') {
          updateKeywordsGastro(user.uid, _shopNameController.text.trim(), await fetchMenuKeywordsGastro(user.uid));
        } else {
          updateKeywordsGastro(user.uid, _shopNameController.text.trim(), await fetchMenuKeywordsGastro(user.uid));
        }

      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _createStoreAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool isAdmin,
    required bool isSeller,
    required bool isDualStore,
    required String uid,
    required String storeType,
    required String shopName,
  }) async {
    try {
      print('STORE: $storeType, $uid');

      await FirebaseFirestore.instance.collection(storeType == 'both' ? 'gastropubs' : storeType).doc(uid).set({
        'first_name': firstName,
        'last_name': lastName,
        'name': shopName,
        'email_address': _email, //'${shopName.trim().toLowerCase().replaceAll(' ', '')}@email.com',
        'geopoint': GeoPoint(0.0, 0.0),
        'open_time': Timestamp.now(),
        'close_time': Timestamp.now(),
        'rating': 0.0,
        'view_count': 0,
        'date_added': FieldValue.serverTimestamp(),
        'overview': '',
        'location': '',
        'isDualStore': storeType == 'both' ? true : false,
        'image_url': _image_url,
      });

      FirebaseFirestore.instance.collection(storeType).doc(uid).collection('menu');

      Navigator.push(context, MaterialPageRoute(builder: (context)=> SellerManagementScreen()));

        } catch (e) {
      print("Error: $e");
    }
  }

}

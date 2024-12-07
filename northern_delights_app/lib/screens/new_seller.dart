import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:northern_delights_app/screens/home_screen.dart';
import 'package:northern_delights_app/screens/pin_location_screen.dart';
import 'package:northern_delights_app/screens/signin_screen.dart';

class NewSellerScreen extends StatefulWidget {
  const NewSellerScreen({super.key, required this.isSeller});

  final bool isSeller;

  @override
  State<NewSellerScreen> createState() => _NewSellerScreenState();
}

class _NewSellerScreenState extends State<NewSellerScreen> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();

  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmPassword;
  String? _passwordMismatchWarning;
  String _selectedType = 'Empanadaan';
  String? shop_name;

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
                    'Northern',
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
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value){
                      email = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Email Address',
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _passwordController,
                    textAlign: TextAlign.center,
                    onChanged: (value){
                      password = value;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
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
                    controller: _confirmPasswordController,
                    textAlign: TextAlign.center,
                    onChanged: (_){
                      _validatePasswords();
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Repeat Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                if (_passwordMismatchWarning != null)
                  Text(
                    _passwordMismatchWarning!,
                    style: TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 15,),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RadioListTile<String>(
                        title: Text('Empanadaan', style: TextStyle(fontSize: 16),),
                        value: 'gastropubs',
                        groupValue: _selectedType,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: Text('Sinanglao\'n', style: TextStyle(fontSize: 16),),
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
                      if (_passwordMismatchWarning == null) {
                        signUpWithEmailPassword(
                            isAdmin: false,
                            firstName: _firstNameController.text.trim(),
                            lastName: _lastNameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            isSeller: widget.isSeller,
                            shopName: _shopNameController.text.trim());
                      }
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

  void _validatePasswords() {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordMismatchWarning = "Passwords do not match";
      });
    } else {
      setState(() {
        _passwordMismatchWarning = null;
      });
    }
  }

  Future<void> signUpWithEmailPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool isAdmin,
    required bool isSeller,
    required String shopName,
  }) async {
    try {
      // Create the user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Get the user ID
      User? user = userCredential.user;

      if (user != null) {
        // Store additional details in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'isAdmin': false,
          'isSeller': isSeller,
          'first_name': firstName,
          'last_name': lastName,
          'email_address': email,
          'shop_name' : shopName,
          'store_type' : _selectedType.isNotEmpty ? _selectedType : '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        _createStoreAccount(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            isAdmin: isAdmin,
            isSeller: isSeller,
            uid: user.uid,
            storeType: _selectedType,
            shopName: shopName);

        Navigator.push(context, MaterialPageRoute(builder: (context)=> SigninScreen()));
        await user.updateDisplayName('$firstName $lastName');
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
    required String uid,
    required String storeType,
    required String shopName,
  }) async {
    try {

      await FirebaseFirestore.instance.collection(storeType).doc(uid).set({
        'first_name': firstName,
        'last_name': lastName,
        'name': shopName,
        'email_address': email,
        'geopoint': GeoPoint(0.0, 0.0),
        'open_time': Timestamp.now(),
        'close_time': Timestamp.now(),
        'rating': 0.0,
        'view_count': 0,
        'date_added': FieldValue.serverTimestamp(),
        'overview': '',
        'location': '',
        'image_url': '',
      });

      Navigator.push(context, MaterialPageRoute(builder: (context)=> SigninScreen()));

        } catch (e) {
      print("Error: $e");
    }
  }

}

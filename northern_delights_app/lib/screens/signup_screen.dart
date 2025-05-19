import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:northern_delights_app/screens/home_screen.dart';
import 'package:northern_delights_app/screens/signin_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.isSeller});

  final bool isSeller;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
  String? _passwordRequirementWarning;
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
                if(widget.isSeller)
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

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    try{
                      if (_passwordMismatchWarning == null) {
                        if(!isPasswordRequirementMet(_passwordController.text)) {
                          setState(() {
                            _passwordMismatchWarning = "Password must have at least 1 uppercase and 1 number";
                          });
                        } else {
                          signUpWithEmailPassword(
                              isAdmin: false,
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              isSeller: widget.isSeller,
                              image_url: '',
                              shopName: _shopNameController.text.trim());
                        }
                      }
                    } catch (e){
                      print(e);
                    }
                    },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(300, 50),
                  ),
                  child: Text('Signup'),
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    TextButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SigninScreen(),
                            ),
                          );
                        },
                        child: Text('Sign in'),),
                  ],
                ),
                const SizedBox(height: 5,),
                if(!widget.isSeller) ...[
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text('Are you a seller?'),
                  //     TextButton(
                  //       onPressed: (){
                  //         Navigator.push(context,
                  //             MaterialPageRoute(builder: (context)=> SignupScreen(isSeller: true)));
                  //       },
                  //       child: Text('Signup as Seller'),),
                  //   ],
                  // ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Signup as user?'),
                      TextButton(
                        onPressed: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context)=> SignupScreen(isSeller: false)));
                        },
                        child: Text('Signup as User'),),
                    ],
                  ),
                ],
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
    }
    else {
      setState(() {
        _passwordMismatchWarning = null;
      });
    }
  }

  bool isPasswordRequirementMet(String password){
    RegExp regex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');
    if(!regex.hasMatch(_passwordController.text)){
      return false;
    }
    else {
      return true;
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
    required String image_url,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'isAdmin': false,
          'isSeller': isSeller,
          'first_name': firstName,
          'last_name': lastName,
          'email_address': email,
          'shop_name' : shopName,
          'store_type' : _selectedType.isNotEmpty ? _selectedType : '',
          'image_url': image_url,
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
            image_url: image_url,
            shopName: shopName);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Signup Successful'),
              content: Text('Go to your email and verify your account'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );

        await user.sendEmailVerification();

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
    required String image_url,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:northern_delights_app/screens/home_screen.dart';
import 'package:northern_delights_app/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  late bool isEmailVerified = true;
  late bool isCredentialsCorrect = true;

  void showEmailVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents tapping outside to close
      builder: (context) => AlertDialog(
        title: Text("Email Not Verified"),
        content: Text("Please verify your email address. Didn't receive the email?"),
        actions: [
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && !user.emailVerified) {
                await user.sendEmailVerification();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Verification email sent to ${user.email}")),
                );
              }
            },
            child: Text("Resend Verification"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Dismiss"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
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
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    email = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Username',
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
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  try
                  {
                    final userLoggedIn = await _auth.signInWithEmailAndPassword(email: email, password: password);
                    final result = userLoggedIn.user;

                    setState(() {
                      isEmailVerified = result!.emailVerified;
                    });

                    //TODO: Check if the user is verified

                    if(userLoggedIn != null && isEmailVerified){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
                    }

                    await result?.reload();

                    if(userLoggedIn != null && !isEmailVerified)
                    {
                      showEmailVerificationDialog(context);
                    }
                  } catch (e)
                  {
                    isCredentialsCorrect = false;

                    setState(() {
                      isCredentialsCorrect;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(300, 50),
                ),
                child: Text('Sign In'),
              ),
              const SizedBox(height: 20,),
              Visibility(
                  visible: !isEmailVerified,
                  child: Text('Please verify your email first!',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
              ),
              Visibility(
                visible: !isCredentialsCorrect,
                child: Text('Invalid credentials, please try again!',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _auth.sendPasswordResetEmail(email: email);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Password Reset'),
                        content: Text('A password reset link has been sent to your email.'),
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
                },
                child: Text('Forgot Password'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> SignupScreen(isSeller: false)));
                    },
                    child: Text('Signup'),),
                ],
              ),

              const SizedBox(height: 5),
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
            ],
          ),
        ),
        ),
      ),
    );
  }
}

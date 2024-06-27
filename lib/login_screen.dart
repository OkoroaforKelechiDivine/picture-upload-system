import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'image_uploader.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  signInWithGoogle() async {
    // begin interactive sign-in process
    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
    // obtain auth details from request
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
    // create a new credential for user
    final AuthCredential googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    // sign in with credential
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(googleAuthCredential);
    // return user
    return userCredential.user;
  }

  saveUserInfo(User user) async {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;
    DocumentReference userRef = fireStore.collection('users').doc(user.uid);
    // Check if the user exists, if not create a new document
    userRef.get().then((doc) {
      if (!doc.exists) {
        userRef.set({
          'name': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                User? user = await signInWithGoogle();
                if (user != null) {
                  await saveUserInfo(user);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ImageUploadScreen(user: user)));
                } else {
                  // Handle the case when the user cancels the sign-in
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sign-in cancelled')),
                  );
                }
              },
              child: const Text('Click to login with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
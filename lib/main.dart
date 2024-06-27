import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid || Platform.isIOS) {
    Firebase.initializeApp(options: const FirebaseOptions(
        apiKey: "AIzaSyDBwllsghqF3_wvDFWGZu4qF9CPgz3O8Ng",
        appId: "1:475534787542:android:9c80b90921e4bcda435a77",
        projectId: "picture-sharing-system-c0d8b",
        storageBucket: "picture-sharing-system-c0d8b.appspot.com",
        messagingSenderId: '475534787542'));
  }
  else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picture Sharing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}
